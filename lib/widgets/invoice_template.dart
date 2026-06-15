import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../features/pos/domain/entities/sale_entity.dart';
import 'app_logo.dart';

class InvoiceTemplate extends StatelessWidget {
  final SaleEntity sale;
  final String companyName;

  const InvoiceTemplate({
    super.key,
    required this.sale,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final textDirection = isArabic
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
    final alignment = isArabic
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.start;

    // Currency Formatter
    final currencySymbol = 'currency_symbol'.tr();
    String formatCurrency(double val) =>
        '${val.toStringAsFixed(2)} $currencySymbol';

    return Directionality(
      textDirection: textDirection,
      child: Container(
        color: theme.colorScheme.surface,
        padding: EdgeInsets.all(24.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Logo
            Center(
              child: Container(
                height: 60.h,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: const AppLogo(fit: BoxFit.contain),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.center,
              child: Text(
                'print_invoice'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16.h),
            const Divider(thickness: 1.5),

            // Metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'invoice_number'.tr()}: ${sale.invoiceNumber}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sale.createdAt.toString().substring(0, 16),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '${'cashier_role'.tr()}: ${sale.cashierId}',
              style: theme.textTheme.bodySmall,
            ),

            if (sale.customerId != null) ...[
              SizedBox(height: 4.h),
              Text(
                '${'customer_name'.tr()}: ${sale.customerId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            SizedBox(height: 16.h),
            const Divider(thickness: 1),

            // Cart Items Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'product_name'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'stock'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'total'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),

            // Items List
            ...sale.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: alignment,
                        children: [
                          Text(
                            item.productName,
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '${item.priceLevel.tr()} @ ${formatCurrency(item.unitPrice)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'x${item.qty}',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        formatCurrency(item.totalPrice),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(thickness: 1.5),
            SizedBox(height: 8.h),

            // Summaries
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('subtotal'.tr()),
                Text(formatCurrency(sale.subtotal)),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'discount'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
                Text(
                  '-${formatCurrency(sale.discount)}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('tax'.tr()), Text(formatCurrency(sale.tax))],
            ),
            SizedBox(height: 8.h),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  formatCurrency(sale.total),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('payment_method'.tr(), style: theme.textTheme.bodySmall),
                Text(
                  sale.paymentMethod.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Align(
              alignment: Alignment.center,
              child: Text(
                'thank_you_message'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
