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
    final route = GoRouterState.of(context).matchedLocation;
    final authBloc = context.read<AuthBloc>();
    final user = authBloc.currentUser;

    final List<_SidebarItem> items = [
      _SidebarItem(icon: Icons.point_of_sale, labelKey: 'pos', route: '/pos'),
      _SidebarItem(
        icon: Icons.receipt_long,
        labelKey: 'sales_history',
        route: '/sales',
      ),
      _SidebarItem(
        icon: Icons.inventory,
        labelKey: 'inventory',
        route: '/inventory',
      ),
      _SidebarItem(
        icon: Icons.people,
        labelKey: 'customers',
        route: '/customers',
      ),
      _SidebarItem(
        icon: Icons.local_shipping,
        labelKey: 'suppliers',
        route: '/suppliers',
      ),
      _SidebarItem(
        icon: Icons.bar_chart,
        labelKey: 'reports',
        route: '/reports',
      ),
      _SidebarItem(
        icon: Icons.calculate,
        labelKey: 'cashier',
        route: '/cashier',
      ),
      _SidebarItem(
        icon: Icons.assignment_return,
        labelKey: 'returns',
        route: '/returns',
      ),
      _SidebarItem(
        icon: Icons.history,
        labelKey: 'activity_log',
        route: '/activity-log',
      ),
      _SidebarItem(
        icon: Icons.settings,
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
            color: theme.dividerColor.withOpacity(0.08),
            width: 1.w,
          ),
          left: BorderSide(
            color: theme.dividerColor.withOpacity(0.08),
            width: 1.w,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo & Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                Container(
                  height: 70.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200, width: 1.w),
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
          // Nav list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = route == item.route;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      leading: Icon(
                        item.icon,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      title: Text(
                        item.labelKey.tr(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      tileColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      onTap: () => context.go(item.route),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Logged user & Logout
          if (user != null)
            Padding(
              padding: EdgeInsets.all(16.0.r),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
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
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: Text('logout'.tr()),
                      onPressed: () {
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
