import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/auth_bloc.dart';
import '../../../../widgets/language_toggle.dart';
import '../../../../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
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
                content: Text('saved_successfully'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/pos');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('invalid_credentials'.tr()),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400.w,
              padding: EdgeInsets.all(32.0.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  width: 1.5.w,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lang switcher
                    const Align(
                      alignment: Alignment.topRight,
                      child: LanguageToggle(),
                    ),
                    SizedBox(height: 16.h),

                    // Logo Image
                    Center(
                      child: Container(
                        height: 100.h,
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.w,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: const AppLogo(fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Username input
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'username'.tr(),
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'no_data'.tr();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Password input
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'password'.tr(),
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'no_data'.tr();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Submit button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      AuthLoginRequested(
                                        _usernameController.text.trim(),
                                        _passwordController.text.trim(),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'login'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    Divider(color: theme.dividerColor.withValues(alpha: 0.1)),
                    SizedBox(height: 12.h),

                    // Immutable Developer & Owner Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 14.r,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Elmohands software',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          ' • Mohamed Salah',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Social and Website Action Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.language_rounded),
                          tooltip: 'elmohands.official-web.online',
                          color: theme.colorScheme.primary,
                          iconSize: 20.r,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _openUrl('https://elmohands.official-web.online/'),
                        ),
                        SizedBox(width: 6.w),
                        IconButton(
                          icon: const Icon(Icons.business_center_rounded),
                          tooltip: 'LinkedIn',
                          color: const Color(0xFF0A66C2),
                          iconSize: 20.r,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _openUrl('https://www.linkedin.com/in/mohamed-salah-11a570112/'),
                        ),
                        SizedBox(width: 6.w),
                        IconButton(
                          icon: const Icon(Icons.public_rounded),
                          tooltip: 'Facebook',
                          color: const Color(0xFF1877F2),
                          iconSize: 20.r,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _openUrl('https://www.facebook.com/share/1K7dFc8zGa/'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
