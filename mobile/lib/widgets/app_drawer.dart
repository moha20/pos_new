import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'language_toggle.dart';
import 'app_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final route = GoRouterState.of(context).matchedLocation;
    final authBloc = context.read<AuthBloc>();
    final user = authBloc.currentUser;

    // Tabs NOT in mobile bottom nav bar:
    // Bottom nav has: POS (/pos), Inventory (/inventory), Returns (/returns), Customers (/customers), Cashier (/cashier), Sales (/sales)
    final List<_DrawerItem> extraItems = [
      _DrawerItem(
        icon: Icons.local_shipping,
        labelKey: 'suppliers',
        route: '/suppliers',
      ),
      if (user?.isAdmin == true)
        _DrawerItem(
          icon: Icons.receipt,
          labelKey: 'supplier_invoice',
          route: '/supplier-invoice',
        ),
      _DrawerItem(
        icon: Icons.account_balance_wallet,
        labelKey: 'balance',
        route: '/balance',
      ),
      _DrawerItem(
        icon: Icons.bar_chart,
        labelKey: 'reports',
        route: '/reports',
      ),
      _DrawerItem(
        icon: Icons.history,
        labelKey: 'activity_log',
        route: '/activity-log',
      ),
      _DrawerItem(
        icon: Icons.settings,
        labelKey: 'settings',
        route: '/settings',
      ),
      _DrawerItem(
        icon: Icons.info_outline,
        labelKey: 'about',
        route: '/about',
      ),
    ];

    // All remaining tabs for quick access:
    final List<_DrawerItem> mainItems = [
      _DrawerItem(icon: Icons.point_of_sale, labelKey: 'pos', route: '/pos'),
      _DrawerItem(
        icon: Icons.receipt_long,
        labelKey: 'sales_history',
        route: '/sales',
      ),
      _DrawerItem(
        icon: Icons.inventory,
        labelKey: 'inventory',
        route: '/inventory',
      ),
      _DrawerItem(
        icon: Icons.people,
        labelKey: 'customers',
        route: '/customers',
      ),
      _DrawerItem(
        icon: Icons.calculate,
        labelKey: 'cashier',
        route: '/cashier',
      ),
      _DrawerItem(
        icon: Icons.assignment_return,
        labelKey: 'returns',
        route: '/returns',
      ),
    ];

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Logo & Language toggle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  Container(
                    height: 60.h,
                    width: double.infinity,
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                  SizedBox(height: 12.h),
                  const LanguageToggle(),
                ],
              ),
            ),
            const Divider(height: 1),

            // Navigation List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                children: [
                  // Section 1: Additional Pages (Not in Bottom Nav)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      top: 8.h,
                      bottom: 4.h,
                    ),
                    child: Text(
                      'more_sections'.tr(), // localized or fallback
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...extraItems.map((item) => _buildTile(context, item, route, theme)),

                  SizedBox(height: 8.h),
                  const Divider(height: 1),
                  SizedBox(height: 8.h),

                  // Section 2: All Main Pages
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      top: 4.h,
                      bottom: 4.h,
                    ),
                    child: Text(
                      'all_sections'.tr(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...mainItems.map((item) => _buildTile(context, item, route, theme)),
                ],
              ),
            ),

            const Divider(height: 1),

            // User Info & Logout
            if (user != null)
              Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user.role.tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.logout, size: 18),
                        label: Text('logout'.tr()),
                        onPressed: () {
                          Navigator.pop(context); // Close drawer
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                          context.go('/login');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    _DrawerItem item,
    String currentRoute,
    ThemeData theme,
  ) {
    final isSelected = currentRoute == item.route;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(
            item.icon,
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          title: Text(
            item.labelKey.tr(),
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            Navigator.pop(context); // Close drawer on selection
            context.go(item.route);
          },
        ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String labelKey;
  final String route;

  _DrawerItem({
    required this.icon,
    required this.labelKey,
    required this.route,
  });
}
