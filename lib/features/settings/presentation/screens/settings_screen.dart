import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../bloc/settings_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../widgets/responsive_layout.dart';
import '../../../../widgets/language_toggle.dart';
import '../../../../widgets/app_logo.dart';
import '../../../../core/di/di.dart';
import '../../../../services/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/db/hive_config.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../suppliers/data/models/supplier_model.dart';
import '../../../inventory/data/models/product_model.dart';
import '../../../pos/data/models/sale_model.dart';
import '../../../cashier/data/models/expense_model.dart';
import '../../../activity_log/data/models/activity_log_model.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../suppliers/presentation/bloc/supplier_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../cashier/presentation/bloc/cashier_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _companyController = TextEditingController();
  final _taxController = TextEditingController();
  final _printerController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _distributorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedTheme;
  String? _selectedMode;

  // Add User controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _userRole = 'cashier';

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
    context.read<AuthBloc>().add(AuthLoadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final user = context.read<AuthBloc>().currentUser;
    final isAdmin = user?.isAdmin ?? false;

    return ResponsiveLayout(
      title: 'settings'.tr(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsLoaded) {
            if (_companyController.text.isEmpty) {
              _companyController.text = state.companyName;
              _taxController.text = state.taxPercent.toString();
              _printerController.text = state.printerIp;
              _addressController.text = state.companyAddress;
              _phoneController.text = state.companyPhone;
              _distributorController.text = state.companyDistributor;
            }
            _selectedTheme ??= state.themeType;
            _selectedMode ??= state.themeMode;

            return SingleChildScrollView(
              padding: EdgeInsets.all(20.0.r),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // System Settings
                    Text(
                      '${'company_name'.tr()} & System Config',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0.r),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _companyController,
                              enabled: isAdmin,
                              decoration: InputDecoration(
                                labelText: 'company_name'.tr(),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'no_data'.tr()
                                  : null,
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _taxController,
                                    enabled: isAdmin,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: 'tax_percent'.tr(),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (v) =>
                                        v == null || double.tryParse(v) == null
                                        ? 'no_data'.tr()
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: TextFormField(
                                    controller: _printerController,
                                    enabled: isAdmin,
                                    decoration: InputDecoration(
                                      labelText: 'printer_ip'.tr(),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'no_data'.tr()
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                             SizedBox(height: 12.h),
                            TextFormField(
                              controller: _addressController,
                              enabled: isAdmin,
                              decoration: InputDecoration(
                                labelText: 'company_address'.tr(),
                                prefixIcon: const Icon(
                                  Icons.location_on_outlined,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'no_data'.tr()
                                  : null,
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _phoneController,
                              enabled: isAdmin,
                              decoration: InputDecoration(
                                labelText: 'company_phone'.tr(),
                                prefixIcon: const Icon(
                                  Icons.phone_android_outlined,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'no_data'.tr()
                                  : null,
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _distributorController,
                              enabled: isAdmin,
                              decoration: InputDecoration(
                                labelText: 'company_distributor'.tr(),
                                prefixIcon: const Icon(Icons.business_outlined),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'no_data'.tr()
                                  : null,
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'language'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const LanguageToggle(),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'theme_color_label'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    border: Border.all(
                                      color: theme.dividerColor.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedTheme,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                      dropdownColor: theme.cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'copper',
                                          child: Text(
                                            'copper_orange_default'.tr(),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'logo_blue',
                                          child: Text(
                                            'logo_blue_official'.tr(),
                                          ),
                                        ),
                                      ],
                                      onChanged: !isAdmin
                                          ? null
                                          : (val) {
                                              if (val != null) {
                                                setState(() {
                                                  _selectedTheme = val;
                                                });
                                                context.read<SettingsBloc>().add(
                                                  SaveSettings(
                                                    companyName:
                                                        _companyController.text,
                                                    taxPercent:
                                                        double.tryParse(
                                                          _taxController.text,
                                                        ) ??
                                                        0.0,
                                                    printerIp:
                                                        _printerController.text,
                                                    themeType: val,
                                                    themeMode:
                                                        _selectedMode ??
                                                        'light',
                                                    whatsappPhone:
                                                        state.whatsappPhone,
                                                    companyAddress:
                                                        _addressController.text,
                                                    companyPhone:
                                                        _phoneController.text,
                                                    companyDistributor:
                                                        _distributorController
                                                            .text,
                                                  ),
                                                );
                                              }
                                            },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'theme_mode_label'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    border: Border.all(
                                      color: theme.dividerColor.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedMode,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                      dropdownColor: theme.cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'light',
                                          child: Text('light_mode'.tr()),
                                        ),
                                        DropdownMenuItem(
                                          value: 'dark',
                                          child: Text('dark_mode'.tr()),
                                        ),
                                        DropdownMenuItem(
                                          value: 'system',
                                          child: Text('system_mode'.tr()),
                                        ),
                                      ],
                                      onChanged: !isAdmin
                                          ? null
                                          : (val) {
                                              if (val != null) {
                                                setState(() {
                                                  _selectedMode = val;
                                                });
                                                context.read<SettingsBloc>().add(
                                                  SaveSettings(
                                                    companyName:
                                                        _companyController.text,
                                                    taxPercent:
                                                        double.tryParse(
                                                          _taxController.text,
                                                        ) ??
                                                        0.0,
                                                    printerIp:
                                                        _printerController.text,
                                                    themeType:
                                                        _selectedTheme ??
                                                        'copper',
                                                    themeMode: val,
                                                    whatsappPhone:
                                                        state.whatsappPhone,
                                                    companyAddress:
                                                        _addressController.text,
                                                    companyPhone:
                                                        _phoneController.text,
                                                    companyDistributor:
                                                        _distributorController
                                                            .text,
                                                  ),
                                                );
                                              }
                                            },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isAdmin) ...[
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<SettingsBloc>().add(
                                      SaveSettings(
                                        companyName: _companyController.text,
                                        taxPercent: double.parse(
                                          _taxController.text,
                                        ),
                                        printerIp: _printerController.text,
                                        themeType: _selectedTheme ?? 'copper',
                                        themeMode: _selectedMode ?? 'light',
                                        whatsappPhone: state.whatsappPhone,
                                        companyAddress: _addressController.text,
                                        companyPhone: _phoneController.text,
                                        companyDistributor:
                                            _distributorController.text,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'saved_successfully'.tr(),
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'save'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // User Management Panel
                    Text(
                      'user_management'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (!isAdmin)
                      Card(
                        color: Colors.amber.withOpacity(0.1),
                        child: Padding(
                          padding: EdgeInsets.all(16.0.r),
                          child: Text(
                            'user_mgmt_admin_only'.tr(),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'active_users'.tr(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _showAddUserDialog(context),
                                    icon: const Icon(
                                      Icons.person_add,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'add_user'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, authState) {
                                  if (authState is AuthLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (authState is AuthUsersLoaded) {
                                    final users = authState.users;
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: users.length,
                                      itemBuilder: (context, index) {
                                        final u = users[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: theme
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            child: const Icon(Icons.person),
                                          ),
                                          title: Text(u.name),
                                          subtitle: Text(
                                            '${u.username} • ${u.role}',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () =>
                                                    _showEditUserDialog(
                                                      context,
                                                      u,
                                                    ),
                                              ),
                                              if (u.username != 'admin')
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      _showConfirmDeleteUserDialog(
                                                        context,
                                                        u,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                  return Text('no_data'.tr());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isAdmin) ...[
                      SizedBox(height: 24.h),
                      Text(
                        'logo_management'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                isArabic
                                    ? 'تغيير شعار التطبيق المعروض في شاشة تسجيل الدخول، القائمة الجانبية، الفواتير، وتقارير Z-Report.'
                                    : 'Change the application logo displayed in the login screen, sidebar, invoice templates, and Z-Reports.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 100.h,
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.dividerColor.withOpacity(
                                          0.2,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    padding: EdgeInsets.all(8.r),
                                    child: const AppLogo(fit: BoxFit.contain),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _handleChangeLogo(context),
                                          icon: const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            isArabic
                                                ? 'تغيير الشعار'
                                                : 'Change Logo',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                          ),
                                        ),
                                        if (state.logoPath != null) ...[
                                          SizedBox(height: 8.h),
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _handleResetLogo(context),
                                            icon: const Icon(
                                              Icons.refresh,
                                              color: Colors.red,
                                            ),
                                            label: Text(
                                              isArabic
                                                  ? 'استعادة الشعار الافتراضي'
                                                  : 'Reset to Default',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              side: const BorderSide(
                                                color: Colors.red,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'backup_restore'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                isArabic
                                    ? 'يمكنك أخذ نسخة احتياطية من جميع البيانات محلياً (ملف قاعدة البيانات Realm) أو استعادة نسخة سابقة. يرجى أخذ الحذر عند استعادة البيانات حيث سيتم استبدال البيانات الحالية بالكامل.'
                                    : 'You can create a local backup copy of all data (Realm database file) or restore a previous one. Please be careful when restoring as it will completely overwrite current data.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _handleBackup(context),
                                      icon: const Icon(
                                        Icons.backup,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        'create_backup'.tr(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _handleRestore(context),
                                      icon: const Icon(
                                        Icons.restore,
                                        color: Colors.red,
                                      ),
                                      label: Text(
                                        'restore_backup'.tr(),
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('cloud_backup_gdrive'.tr()),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isArabic
                                                ? 'لطريقة النسخ الاحتياطي السحابي السريعة:'
                                                : 'For a quick cloud backup method:',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            isArabic
                                                ? '١. اضغط على "أخذ نسخة احتياطية" لحفظ قاعدة البيانات محلياً.\n\n'
                                                      '٢. إذا كان لديك تطبيق Google Drive للكمبيوتر (Google Drive Desktop)، يمكنك حفظ النسخة مباشرة داخل مجلد المزامنة وسيتم رفعها تلقائياً.\n\n'
                                                      '٣. أو يمكنك فتح موقع Google Drive في المتصفح وسحب وإسقاط ملف النسخة (.realm) هناك لتخزينه سحابياً.'
                                                : '1. Click "Create Backup" to save the database file locally.\n\n'
                                                      '2. If you have Google Drive Desktop installed, you can save the backup file directly inside your synced Google Drive folder and it will upload automatically.\n\n'
                                                      '3. Alternatively, open drive.google.com in your browser and drag & drop the backup (.realm) file there.',
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('confirm'.tr()),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.cloud_upload,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        isArabic
                                            ? 'هل تريد الرفع على Google Drive؟ اضغط للتوجيهات'
                                            : 'Want to upload to Google Drive? Click for instructions',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12.sp,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        isArabic ? 'إدارة البيانات' : 'Data Management',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                isArabic
                                    ? 'حذف البيانات الانتقائي. تحذير: هذه العملية لا يمكن التراجع عنها وسيتم حذف البيانات المحددة بشكل نهائي.'
                                    : 'Selective data deletion. Warning: This action is irreversible and selected data will be deleted permanently.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        _handleClearData(context, 'customers'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      isArabic
                                          ? 'حذف العملاء'
                                          : 'Clear Customers',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _handleClearData(context, 'suppliers'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      isArabic
                                          ? 'حذف الموردين'
                                          : 'Clear Suppliers',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _handleClearData(context, 'products'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      isArabic
                                          ? 'حذف المنتجات'
                                          : 'Clear Products',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _handleClearData(context, 'sales'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      isArabic
                                          ? 'حذف فواتير المبيعات'
                                          : 'Clear Sales Invoices',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _handleClearData(
                                      context,
                                      'shifts_expenses',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      isArabic
                                          ? 'حذف الورديات والمصاريف'
                                          : 'Clear Shifts & Expenses',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _handleClearData(
                                      context,
                                      'activity_logs',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      isArabic
                                          ? 'حذف سجل العمليات'
                                          : 'Clear Activity Logs',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _handleClearData(context, 'all'),
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                label: Text(
                                  isArabic
                                      ? 'حذف جميع البيانات بالكامل'
                                      : 'Clear All Data (Factory Reset)',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          return Center(child: Text('no_data'.tr()));
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    _nameController.clear();
    _usernameController.clear();
    _passwordController.clear();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('add_new_user'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'name'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'username'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'password'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    initialValue: _userRole,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    dropdownColor: theme.cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    items: [
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('admin'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'cashier',
                        child: Text('cashier_role'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'viewer',
                        child: Text('viewer'.tr()),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _userRole = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'role'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgContext),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _usernameController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      final u = UserEntity(
                        id: '',
                        name: _nameController.text,
                        username: _usernameController.text,
                        role: _userRole,
                        isActive: true,
                      );
                      context.read<AuthBloc>().add(
                        AuthAddUserRequested(u, _passwordController.text),
                      );
                      Navigator.pop(dlgContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Text('confirm'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleChangeLogo(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null) {
        if (kIsWeb) {
          final bytes = result.files.single.bytes;
          if (bytes != null) {
            final extension = result.files.single.name
                .split('.')
                .last
                .toLowerCase();
            final base64String = base64Encode(bytes);
            final dataUri = 'data:image/$extension;base64,$base64String';
            if (context.mounted) {
              context.read<SettingsBloc>().add(SaveLogo(dataUri));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('logo_updated_success'.tr()),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } else if (result.files.single.path != null) {
          final selectedPath = result.files.single.path!;

          // Copy to app documents directory
          final appDocDir = await getApplicationDocumentsDirectory();
          final fileName =
              'app_logo_${DateTime.now().millisecondsSinceEpoch}.${selectedPath.split('.').last}';
          final newPath = '${appDocDir.path}/$fileName';

          // Copy the file
          final file = File(selectedPath);
          await file.copy(newPath);

          if (context.mounted) {
            context.read<SettingsBloc>().add(SaveLogo(newPath));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('logo_updated_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleResetLogo(BuildContext context) {
    context.read<SettingsBloc>().add(SaveLogo(null));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('logo_reset_success'.tr()),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleBackup(BuildContext context) async {
    final isArabic = context.locale.languageCode == 'ar';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('creating_backup'.tr()),
        duration: const Duration(seconds: 1),
      ),
    );

    final backupService = Gravity.find<BackupService>();
    final result = await backupService.backupLocal();

    if (!context.mounted) return;

    if (result != null && result.startsWith('success:')) {
      final path = result.substring(8);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('backup_successful'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic
                    ? 'تم حفظ النسخة الاحتياطية بنجاح في المسار التالي:'
                    : 'The backup has been saved successfully at:',
              ),
              SizedBox(height: 8.h),
              SelectableText(
                path,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                isArabic
                    ? 'نصيحة: يمكنك رفع هذا الملف يدويًا إلى Google Drive الخاص بك لحمايته سحابيًا.'
                    : 'Tip: You can manually upload this file to your Google Drive to keep a cloud copy.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('confirm'.tr()),
            ),
          ],
        ),
      );
    } else if (result == 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('backup_cancelled'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      final err = result ?? 'unknown';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('backup_failed'.tr()),
          content: Text(
            isArabic
                ? 'حدث خطأ أثناء محاولة حفظ النسخة الاحتياطية:\n$err'
                : 'An error occurred while creating backup:\n$err',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('confirm'.tr()),
            ),
          ],
        ),
      );
    }
  }

  void _handleRestore(BuildContext context) async {
    final isArabic = context.locale.languageCode == 'ar';

    // First confirm action
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('restore_confirm'.tr()),
        content: Text(
          isArabic
              ? 'تحذير: سيتم مسح جميع البيانات الحالية بالكامل واستبدالها بالبيانات الموجودة في ملف النسخة الاحتياطية. هل أنت متأكد؟'
              : 'Warning: This will completely delete all current data and replace it with data from the backup file. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('restoring_data'.tr()),
        duration: const Duration(seconds: 1),
      ),
    );

    final backupService = Gravity.find<BackupService>();
    final result = await backupService.restoreLocal();

    if (!context.mounted) return;

    if (result == 'success') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('restore_successful'.tr()),
          content: Text(
            isArabic
                ? 'تمت استعادة قاعدة البيانات بنجاح. يرجى تسجيل الدخول مرة أخرى لتحديث البيانات.'
                : 'Database has been restored successfully. Please log in again to refresh loaded data.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Logout and navigate to login to refresh all blocs
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.pop(context);
              },
              child: Text('confirm'.tr()),
            ),
          ],
        ),
      );
    } else if (result == 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('restore_cancelled'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('restore_failed'.tr()),
          content: Text(
            isArabic
                ? 'حدث خطأ أثناء محاولة استعادة البيانات:\n$result'
                : 'An error occurred while restoring database:\n$result',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('confirm'.tr()),
            ),
          ],
        ),
      );
    }
  }

  void _showConfirmDeleteUserDialog(BuildContext context, UserEntity user) {
    final isArabic = context.locale.languageCode == 'ar';
    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        title: Text('delete_user_confirm'.tr()),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف المستخدم ${user.name}؟'
              : 'Are you sure you want to delete user ${user.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgContext),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthDeleteUserRequested(user.id));
              Navigator.pop(dlgContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserEntity user) {
    _nameController.text = user.name;
    _usernameController.text = user.username;
    _passwordController.clear();
    _userRole = user.role;

    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('edit_user_change_password'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'name'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _usernameController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'username'.tr(),
                      border: const OutlineInputBorder(),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'new_password_optional'.tr(),
                      hintText: 'leave_empty_keep_current'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    initialValue: _userRole,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    dropdownColor: theme.cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    items: [
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('admin'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'cashier',
                        child: Text('cashier_role'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'viewer',
                        child: Text('viewer'.tr()),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _userRole = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'role'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgContext),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      final updatedUser = UserEntity(
                        id: user.id,
                        name: _nameController.text,
                        username: user.username,
                        role: _userRole,
                        isActive: user.isActive,
                      );

                      final pass = _passwordController.text.trim().isEmpty
                          ? null
                          : _passwordController.text;

                      context.read<AuthBloc>().add(
                        AuthUpdateUserRequested(updatedUser, password: pass),
                      );
                      Navigator.pop(dlgContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Text('confirm'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleClearData(BuildContext context, String type) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final user = context.read<AuthBloc>().currentUser;
    if (user == null) return;

    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          title: Text(
            isArabic
                ? 'تأكيد الحذف والرمز السري'
                : 'Confirm Deletion & Password',
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isArabic
                      ? 'الرجاء إدخال الرقم السري الخاص بالمسؤول لتأكيد عملية الحذف.'
                      : 'Please enter the administrator password to confirm the deletion action.',
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'password'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'no_data'.tr() : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final authRepo = Gravity.find<AuthRepository>();
                  final navigator = Navigator.of(dlgContext);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final currentContext = context;
                  final verified = await authRepo.login(
                    user.username,
                    passwordController.text,
                  );
                  if (verified != null) {
                    navigator.pop();
                    if (currentContext.mounted) {
                      _executeClearData(currentContext, type);
                    }
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic
                              ? 'كلمة المرور غير صحيحة'
                              : 'Incorrect password',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                isArabic ? 'حذف نهائي' : 'Delete Permanently',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _executeClearData(BuildContext context, String type) async {
    final isArabic = context.locale.languageCode == 'ar';

    final customerBloc = context.read<CustomerBloc>();
    final supplierBloc = context.read<SupplierBloc>();
    final inventoryBloc = context.read<InventoryBloc>();
    final cashierBloc = context.read<CashierBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      if (type == 'customers' || type == 'all') {
        await HiveConfig.customersBox.clear();
        // Re-seed default Cash Customer
        final custId = generateId();
        await HiveConfig.customersBox.put(custId, {
          'id': custId,
          'name': 'عميل نقدي / Cash Customer',
          'phone': '0000000000',
          'address': 'Local Store',
          'totalPurchases': 0.0,
          'balance': 0.0,
          'createdAt': DateTime.now().toIso8601String(),
          'priceLevel': 'retail',
        });
        customerBloc.add(LoadCustomers());
      }

      if (type == 'suppliers' || type == 'all') {
        await HiveConfig.suppliersBox.clear();
        supplierBloc.add(LoadSuppliers());
      }

      if (type == 'products' || type == 'all') {
        await HiveConfig.productsBox.clear();
        inventoryBloc.add(LoadInventory());
      }

      if (type == 'sales' || type == 'all') {
        await HiveConfig.salesBox.clear();
        // Reset customer totalPurchases and balance
        final customerBox = HiveConfig.customersBox;
        for (final key in customerBox.keys.toList()) {
          final data = customerBox.get(key) as Map<dynamic, dynamic>;
          final updated = Map<String, dynamic>.from(data);
          updated['totalPurchases'] = 0.0;
          updated['balance'] = 0.0;
          await customerBox.put(key, updated);
        }
        customerBloc.add(LoadCustomers());
      }

      if (type == 'shifts_expenses' || type == 'all') {
        await HiveConfig.expensesBox.clear();
        // Clear shift variables in shared prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_shift_open', false);
        await prefs.remove('starting_cash');
        await prefs.remove('active_shift_id');
        cashierBloc.add(LoadCashier());
      }

      if (type == 'activity_logs' || type == 'all') {
        await HiveConfig.activityLogsBox.clear();
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'تم مسح البيانات بنجاح' : 'Data cleared successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'حدث خطأ أثناء مسح البيانات' : 'Error clearing data: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
