import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/activity_log_cubit.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../../../widgets/responsive_layout.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'icon': Icons.select_all, 'color': Colors.blueGrey},
    {'key': 'auth', 'icon': Icons.lock, 'color': Colors.indigo},
    {'key': 'pos', 'icon': Icons.point_of_sale, 'color': Colors.green},
    {'key': 'inventory', 'icon': Icons.inventory, 'color': Colors.orange},
    {'key': 'customers', 'icon': Icons.people, 'color': Colors.blue},
    {'key': 'suppliers', 'icon': Icons.local_shipping, 'color': Colors.purple},
    {'key': 'cashier', 'icon': Icons.calculate, 'color': Colors.teal},
    {'key': 'returns', 'icon': Icons.assignment_return, 'color': Colors.red},
    {'key': 'settings', 'icon': Icons.settings, 'color': Colors.grey},
  ];

  // Map logged category values to filter chip keys (handles singular/plural)
  static const Map<String, String> _categoryAliases = {
    'customer': 'customers',
    'supplier': 'suppliers',
    'pos': 'pos',
    'auth': 'auth',
    'inventory': 'inventory',
    'cashier': 'cashier',
    'settings': 'settings',
    'returns': 'returns',
  };

  @override
  void initState() {
    super.initState();
    context.read<ActivityLogCubit>().loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    final normalizedCat = _categoryAliases[category] ?? category;
    final cat = _categories.firstWhere(
      (c) => c['key'] == normalizedCat,
      orElse: () => {'color': Colors.blueGrey},
    );
    return cat['color'] as Color;
  }

  IconData _getCategoryIcon(String category) {
    final normalizedCat = _categoryAliases[category] ?? category;
    final cat = _categories.firstWhere(
      (c) => c['key'] == normalizedCat,
      orElse: () => {'icon': Icons.info},
    );
    return cat['icon'] as IconData;
  }

  String _getActionLabel(String action, bool isArabic) {
    // Map action keys to readable labels
    final Map<String, Map<String, String>> actionLabels = {
      // Auth
      'login': {'ar': 'تسجيل دخول', 'en': 'Login'},
      'logout': {'ar': 'تسجيل خروج', 'en': 'Logout'},
      // POS
      'sale_completed': {'ar': 'عملية بيع', 'en': 'Sale Completed'},
      'clear_cart': {'ar': 'مسح السلة', 'en': 'Cart Cleared'},
      // Inventory
      'product_added': {'ar': 'إضافة منتج', 'en': 'Product Added'},
      'product_edited': {'ar': 'تعديل منتج', 'en': 'Product Edited'},
      'product_deleted': {'ar': 'حذف منتج', 'en': 'Product Deleted'},
      // Customers
      'customer_added': {'ar': 'إضافة عميل', 'en': 'Customer Added'},
      'customer_edited': {'ar': 'تعديل عميل', 'en': 'Customer Edited'},
      'customer_deleted': {'ar': 'حذف عميل', 'en': 'Customer Deleted'},
      // Suppliers
      'supplier_added': {'ar': 'إضافة مورد', 'en': 'Supplier Added'},
      'supplier_edited': {'ar': 'تعديل مورد', 'en': 'Supplier Edited'},
      'supplier_deleted': {'ar': 'حذف مورد', 'en': 'Supplier Deleted'},
      // Cashier
      'shift_opened': {'ar': 'فتح وردية', 'en': 'Shift Opened'},
      'shift_closed': {'ar': 'إغلاق وردية', 'en': 'Shift Closed'},
      'expense_added': {'ar': 'إضافة مصروف', 'en': 'Expense Added'},
      'expense_deleted': {'ar': 'حذف مصروف', 'en': 'Expense Deleted'},
      // Returns
      'sales_return': {'ar': 'مرتجع مبيعات', 'en': 'Sales Return'},
      'purchase_return': {'ar': 'مرتجع مشتريات', 'en': 'Purchase Return'},
      // Settings & Users
      'add_user': {'ar': 'إضافة مستخدم', 'en': 'User Added'},
      'update_user': {'ar': 'تعديل مستخدم', 'en': 'User Updated'},
      'delete_user': {'ar': 'حذف مستخدم', 'en': 'User Deleted'},
      'settings_updated': {'ar': 'تحديث الإعدادات', 'en': 'Settings Updated'},
      'logo_updated': {'ar': 'تحديث الشعار', 'en': 'Logo Updated'},
      // Backup
      'database_backup': {'ar': 'نسخ احتياطي', 'en': 'Database Backup'},
      'database_restore': {'ar': 'استعادة البيانات', 'en': 'Database Restored'},
    };

    final label = actionLabels[action];
    if (label != null) {
      return isArabic ? label['ar']! : label['en']!;
    }
    return action;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';

    return ResponsiveLayout(
      title: 'activity_log'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'refresh'.tr(),
          onPressed: () {
            _selectedCategory = 'all';
            context.read<ActivityLogCubit>().loadAll();
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16.h),
          // Category Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 42.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['key'];
                  final color = cat['color'] as Color;

                  return FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : color,
                    ),
                    label: Text(
                      (cat['key'] as String).tr(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.sp,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                    onSelected: (_) {
                      final key = cat['key'] as String;
                      setState(() => _selectedCategory = key);
                      context.read<ActivityLogCubit>().filterByCategory(key);
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          SizedBox(height: 12.h),

          // Data Table
          Expanded(
            child: BlocBuilder<ActivityLogCubit, ActivityLogState>(
              builder: (context, state) {
                if (state is ActivityLogLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ActivityLogError) {
                  return Center(
                    child: Text(state.message, style: TextStyle(color: theme.colorScheme.error)),
                  );
                }

                if (state is ActivityLogLoaded) {
                  List<ActivityLogEntity> logs = state.logs;

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    logs = logs.where((log) {
                      return log.description.toLowerCase().contains(_searchQuery) ||
                          log.action.toLowerCase().contains(_searchQuery) ||
                          log.userId.toLowerCase().contains(_searchQuery) ||
                          log.category.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_toggle_off, size: 64, color: theme.disabledColor),
                          SizedBox(height: 12.h),
                          Text(
                            'no_data'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.disabledColor),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          theme.colorScheme.primary.withValues(alpha: 0.06),
                        ),
                        columnSpacing: 24,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 60,
                        columns: [
                          DataColumn(label: Text('date'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('time'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('user'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('category'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('action'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('details'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: logs.map((log) {
                          final normalizedCat = _categoryAliases[log.category] ?? log.category;
                          final catColor = _getCategoryColor(log.category);

                          return DataRow(cells: [
                            DataCell(Text(
                              DateFormat('yyyy-MM-dd').format(log.timestamp),
                              style: TextStyle(fontSize: 12.sp),
                            )),
                            DataCell(Text(
                              DateFormat('HH:mm:ss').format(log.timestamp),
                              style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            )),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  child: Text(
                                    log.userId.isNotEmpty ? log.userId[0].toUpperCase() : '?',
                                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(log.userId, style: TextStyle(fontSize: 12.sp)),
                              ],
                            )),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getCategoryIcon(log.category), size: 14, color: catColor),
                                  SizedBox(width: 4.w),
                                  Text(
                                    normalizedCat.tr(),
                                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: catColor),
                                  ),
                                ],
                              ),
                            )),
                            DataCell(Text(
                              _getActionLabel(log.action, isArabic),
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: catColor),
                            )),
                            DataCell(
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 300),
                                child: Text(
                                  log.description,
                                  style: TextStyle(fontSize: 12.sp),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
