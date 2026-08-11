import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/localization/locale_cubit.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, currentLocale) {
        final isArabic = currentLocale.languageCode == 'ar';
        final theme = Theme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.1),
              width: 1.w,
            ),
          ),
          padding: EdgeInsets.all(4.r),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPillButton(
                context,
                label: 'العربية',
                isSelected: isArabic,
                onTap: () {
                  context.read<LocaleCubit>().switchToArabic(context);
                },
              ),
              _buildPillButton(
                context,
                label: 'English',
                isSelected: !isArabic,
                onTap: () {
                  context.read<LocaleCubit>().switchToEnglish(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPillButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }
}
