import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'language_toggle.dart';
import 'app_logo.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final route = GoRouterState.of(context).matchedLocation;
    final authBloc = context.read<AuthBloc>();
    final user = authBloc.currentUser;

    final List<_SidebarItem> items = [
      _SidebarItem(icon: Icons.point_of_sale_rounded, labelKey: 'pos', route: '/pos'),
      _SidebarItem(
        icon: Icons.receipt_long_rounded,
        labelKey: 'sales_history',
        route: '/sales',
      ),
      _SidebarItem(
        icon: Icons.inventory_2_rounded,
        labelKey: 'inventory',
        route: '/inventory',
      ),
      _SidebarItem(
        icon: Icons.people_alt_rounded,
        labelKey: 'customers',
        route: '/customers',
      ),
      _SidebarItem(
        icon: Icons.local_shipping_rounded,
        labelKey: 'suppliers',
        route: '/suppliers',
      ),
      if (user?.isAdmin == true)
        _SidebarItem(
          icon: Icons.receipt_rounded,
          labelKey: 'supplier_invoice',
          route: '/supplier-invoice',
        ),
      _SidebarItem(
        icon: Icons.account_balance_wallet_rounded,
        labelKey: 'balance',
        route: '/balance',
      ),
      _SidebarItem(
        icon: Icons.insights_rounded,
        labelKey: 'reports',
        route: '/reports',
      ),
      _SidebarItem(
        icon: Icons.point_of_sale_outlined,
        labelKey: 'cashier',
        route: '/cashier',
      ),
      _SidebarItem(
        icon: Icons.replay_rounded,
        labelKey: 'returns',
        route: '/returns',
      ),
      _SidebarItem(
        icon: Icons.history_toggle_off_rounded,
        labelKey: 'activity_log',
        route: '/activity-log',
      ),
      _SidebarItem(
        icon: Icons.settings_suggest_rounded,
        labelKey: 'settings',
        route: '/settings',
      ),
    ];

    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1.w,
          ),
          left: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1.w,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo & Header Area
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const AppLogo(),
                if (user?.companyName != null && user!.companyName!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 14.r,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            user.companyName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.08)),

          // Navigation Menu List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = route == item.route;

                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14.r),
                    child: InkWell(
                      onTap: () => context.go(item.route),
                      borderRadius: BorderRadius.circular(14.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withValues(alpha: 0.85),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                    blurRadius: 10.r,
                                    offset: Offset(0, 4.h),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20.r,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Text(
                                item.labelKey.tr(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.08)),

          // User Profile & Logout Bottom Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        (user?.username.isNotEmpty == true) ? user!.username[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? 'user'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.isAdmin == true ? 'admin'.tr() : 'cashier'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      iconSize: 20.r,
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        context.go('/login');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const LanguageToggle(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String labelKey;
  final String route;

  _SidebarItem({
    required this.icon,
    required this.labelKey,
    required this.route,
  });
}
