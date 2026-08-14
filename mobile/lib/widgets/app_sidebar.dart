import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
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
      width: 270.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
          left: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header / Logo Area
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
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
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 13.r,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            user.companyName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
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

          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),

          // Navigation Menu
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = route == item.route;

                return Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () => context.go(item.route),
                      borderRadius: BorderRadius.circular(12.r),
                      hoverColor: theme.colorScheme.primary.withValues(alpha: 0.06),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 11.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withValues(alpha: 0.88),
                                  ],
                                  begin: AlignmentDirectional.centerStart,
                                  end: AlignmentDirectional.centerEnd,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 10.r,
                                    offset: Offset(0, 3.h),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 19.r,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                item.labelKey.tr(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 5.r,
                                height: 5.r,
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

          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),

          // Bottom Bar (User Profile + Quick Toggles)
          Container(
            padding: EdgeInsets.all(14.w),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 17.r,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        (user?.username.isNotEmpty == true) ? user!.username[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
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
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: (user?.isAdmin == true ? Colors.blue : Colors.teal)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              user?.isAdmin == true ? 'admin'.tr() : 'cashier'.tr(),
                              style: TextStyle(
                                color: user?.isAdmin == true ? Colors.blue : Colors.teal,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      iconSize: 19.r,
                      tooltip: 'logout'.tr(),
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        context.go('/login');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    const Expanded(child: LanguageToggle()),
                    SizedBox(width: 8.w),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, state) {
                        final currentMode = (state is SettingsLoaded) ? state.themeMode : 'light';
                        final isCurrentlyDark = currentMode == 'dark' || (currentMode == 'system' && isDark);

                        return IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          icon: Icon(
                            isCurrentlyDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            size: 16.r,
                            color: isCurrentlyDark ? Colors.amber : theme.colorScheme.primary,
                          ),
                          tooltip: isCurrentlyDark ? 'Light Mode' : 'Dark Mode',
                          onPressed: () {
                            if (state is SettingsLoaded) {
                              final newMode = isCurrentlyDark ? 'light' : 'dark';
                              context.read<SettingsBloc>().add(
                                SaveSettings(
                                  companyName: state.companyName,
                                  taxPercent: state.taxPercent,
                                  printerIp: state.printerIp,
                                  themeType: state.themeType,
                                  themeMode: newMode,
                                  whatsappPhone: state.whatsappPhone,
                                  companyAddress: state.companyAddress,
                                  companyPhone: state.companyPhone,
                                  companyDistributor: state.companyDistributor,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
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
