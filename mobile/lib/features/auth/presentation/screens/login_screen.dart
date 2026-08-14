import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../../../../widgets/language_toggle.dart';
import '../../../../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _companyNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCompany();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadSavedCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('company_name');
    if (savedName != null && savedName.isNotEmpty) {
      _companyNameController.text = savedName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    SizedBox(width: 10.w),
                    Text('saved_successfully'.tr()),
                  ],
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            context.go('/pos');
          } else if (state is AuthFailure) {
            final String errorText;
            if (state.message == 'COMPANY_NOT_FOUND') {
              errorText = 'company_not_found'.tr();
            } else if (state.message == 'COMPANY_INACTIVE') {
              errorText = 'company_inactive_support'.tr();
            } else {
              errorText = 'error_occurred'.tr();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white),
                    SizedBox(width: 10.w),
                    Expanded(child: Text(errorText)),
                  ],
                ),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Ambient background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.4,
                    colors: isDark
                        ? [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            const Color(0xFF0B111E),
                          ]
                        : [
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                            const Color(0xFFF8FAFC),
                          ],
                  ),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                child: Container(
                  width: 440.w,
                  padding: EdgeInsets.all(32.0.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.07),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Language switcher
                        const Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: LanguageToggle(),
                        ),
                        SizedBox(height: 12.h),

                        // Logo Card
                        Center(
                          child: Container(
                            height: 85.h,
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: const AppLogo(fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        Text(
                          'login'.tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Al-Mohandis Point of Sale',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Company Name Input
                        TextFormField(
                          controller: _companyNameController,
                          decoration: InputDecoration(
                            labelText: 'company_name'.tr(),
                            prefixIcon: const Icon(Icons.business_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'enter_company_name'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 14.h),

                        // Username Input
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'username'.tr(),
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'no_data'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 14.h),

                        // Password Input
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'password'.tr(),
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'no_data'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 22.h),

                        // Submit button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withValues(alpha: 0.88),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          final company = _companyNameController.text.trim();
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.setString('company_name', company);

                                          if (context.mounted) {
                                            context.read<AuthBloc>().add(
                                              AuthLoginRequested(
                                                _usernameController.text.trim(),
                                                _passwordController.text,
                                                companyName: company,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(vertical: 15.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: 20.h,
                                        width: 20.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'login'.tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 18.h),

                        // Quick Test Login Chips
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Demo Accounts:',
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 8.h),
                                        side: BorderSide(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      onPressed: () {
                                        _usernameController.text = 'admin';
                                        _passwordController.text = 'admin123';
                                      },
                                      child: const Text('Admin'),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 8.h),
                                        side: BorderSide(
                                          color: theme.colorScheme.outlineVariant,
                                        ),
                                      ),
                                      onPressed: () {
                                        _usernameController.text = 'cashier';
                                        _passwordController.text = 'cashier123';
                                      },
                                      child: const Text('Cashier'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
