import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;
    final theme = Theme.of(context);

    final List<_BottomItem> items = [
      _BottomItem(icon: Icons.point_of_sale, labelKey: 'pos', route: '/pos'),
      _BottomItem(icon: Icons.inventory, labelKey: 'inventory', route: '/inventory'),
      _BottomItem(icon: Icons.assignment_return, labelKey: 'returns', route: '/returns'),
      _BottomItem(icon: Icons.people, labelKey: 'customers', route: '/customers'),
      _BottomItem(icon: Icons.calculate, labelKey: 'cashier', route: '/cashier'),
      _BottomItem(icon: Icons.receipt_long, labelKey: 'sales_history', route: '/sales'),
    ];

    int currentIndex = items.indexWhere((i) => i.route == route);
    if (currentIndex < 0) currentIndex = 0;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        context.go(items[index].route);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.labelKey.tr(),
        );
      }).toList(),
    );
  }
}

class _BottomItem {
  final IconData icon;
  final String labelKey;
  final String route;

  _BottomItem({
    required this.icon,
    required this.labelKey,
    required this.route,
  });
}
