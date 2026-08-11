import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<_BottomItem> items = [
      _BottomItem(icon: Icons.point_of_sale_rounded, labelKey: 'pos', route: '/pos'),
      _BottomItem(icon: Icons.inventory_2_rounded, labelKey: 'inventory', route: '/inventory'),
      _BottomItem(icon: Icons.replay_rounded, labelKey: 'returns', route: '/returns'),
      _BottomItem(icon: Icons.people_alt_rounded, labelKey: 'customers', route: '/customers'),
      _BottomItem(icon: Icons.point_of_sale_outlined, labelKey: 'cashier', route: '/cashier'),
      _BottomItem(icon: Icons.receipt_long_rounded, labelKey: 'sales_history', route: '/sales'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1.w,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 62.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isSelected = route == item.route;

              return InkWell(
                onTap: () => context.go(item.route),
                borderRadius: BorderRadius.circular(16.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22.r,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        item.labelKey.tr(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
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
