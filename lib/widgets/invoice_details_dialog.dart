import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../features/pos/domain/entities/sale_entity.dart';
import '../services/print_service.dart';
import '../core/di/di.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/customers/presentation/bloc/customer_bloc.dart';

void showInvoiceDetailsDialog(
  BuildContext context,
  SaleEntity sale,
  String customerName,
) {
  final theme = Theme.of(context);
  final isArabic = context.locale.languageCode == 'ar';
  final currencySymbol = isArabic ? 'ج.م' : 'EGP';
  String formatCurrency(double val) =>
      '${val.toStringAsFixed(2)} $currencySymbol';
  final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt);

  showDialog(
    context: context,
    builder: (dialogContext) {
      bool isMaximized = false;
      return StatefulBuilder(
        builder: (context, setState) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isMaximized ? screenWidth * 0.95 : 500.w,
              height: isMaximized ? screenHeight * 0.95 : null,
              constraints: BoxConstraints(
                maxHeight: isMaximized ? screenHeight * 0.95 : 650.h,
              ),
              padding: EdgeInsets.all(24.0.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${'invoice_number'.tr()}: ${sale.invoiceNumber}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(isMaximized ? Icons.fullscreen_exit : Icons.fullscreen),
                            tooltip: isArabic
                                ? (isMaximized ? 'تصغير' : 'تكبير')
                                : (isMaximized ? 'Minimize' : 'Maximize'),
                            onPressed: () {
                              setState(() {
                                isMaximized = !isMaximized;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${'date'.tr()}: $formattedDate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '${'cashier'.tr()}: ${sale.cashierId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '${'customer_name'.tr()}: $customerName',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),

                  // Items List
                  Text(
                    'items'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sale.items.length,
                      itemBuilder: (context, index) {
                        final item = sale.items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${item.qty} x ${formatCurrency(item.unitPrice)} (${_getTierBadgeText(item.priceLevel, isArabic)})',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 11.sp,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                formatCurrency(item.totalPrice),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 24),

                  // Summary calculations
                  _buildSummaryRow(
                    'subtotal'.tr(),
                    formatCurrency(sale.subtotal),
                    theme,
                  ),
                  if (sale.discount > 0)
                    _buildSummaryRow(
                      'discount'.tr(),
                      '-${formatCurrency(sale.discount)}',
                      theme,
                      color: Colors.red,
                    ),
                  if (sale.tax > 0)
                    _buildSummaryRow('tax'.tr(), formatCurrency(sale.tax), theme),
                  const Divider(height: 12),
                  _buildSummaryRow(
                    'total'.tr(),
                    formatCurrency(sale.total),
                    theme,
                    isBold: true,
                    fontSize: 16.sp,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 8.h),
                  _buildSummaryRow(
                    'paid'.tr(),
                    formatCurrency(sale.amountPaid),
                    theme,
                    color: Colors.green,
                    isBold: true,
                  ),
                  _buildSummaryRow(
                    'remaining'.tr(),
                    formatCurrency(sale.amountRemaining),
                    theme,
                    color: sale.amountRemaining > 0 ? Colors.red : Colors.green,
                    isBold: true,
                  ),

                  if (sale.note != null && sale.note!.isNotEmpty) ...[
                    const Divider(height: 16),
                    Text(
                      '${'notes'.tr()}: ${sale.note}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${'payment_method'.tr()}: ${sale.paymentMethod.tr()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final printService = Gravity.find<PrintService>();
                              await printService.shareInvoice(
                                context,
                                sale,
                                'Al Mohands Electrical Tools / المهندس للأدوات الكهربائية',
                                context.locale.languageCode,
                              );
                            },
                            icon: const Icon(Icons.share, color: Colors.white),
                            label: Text(
                              'share'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final printService = Gravity.find<PrintService>();
                              String? customerPhone;
                              if (sale.customerId != null) {
                                try {
                                  final customerBloc = context.read<CustomerBloc>();
                                  if (customerBloc.state is CustomerLoaded) {
                                    final customers = (customerBloc.state as CustomerLoaded).allCustomers;
                                    final match = customers.firstWhere((c) => c.id == sale.customerId);
                                    customerPhone = match.phone;
                                  }
                                } catch (_) {}
                              }
                              await printService.shareToWhatsApp(
                                context,
                                sale,
                                customerName: customerName,
                                customerPhone: customerPhone,
                              );
                            },
                            icon: const Icon(Icons.chat_rounded, color: Colors.white),
                            label: const Text(
                              'WhatsApp',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final printService = Gravity.find<PrintService>();
                              await printService.printInvoice(
                                context,
                                sale,
                                'Al Mohands Electrical Tools / المهندس للأدوات الكهربائية',
                                context.locale.languageCode,
                              );
                            },
                            icon: const Icon(Icons.print, color: Colors.white),
                            label: Text(
                              'print'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildSummaryRow(
  String label,
  String value,
  ThemeData theme, {
  bool isBold = false,
  double fontSize = 13,
  Color? color,
}) {
  final style = TextStyle(
    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    fontSize: fontSize,
    color: color ?? theme.textTheme.bodyMedium?.color,
  );
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    ),
  );
}

String _getTierBadgeText(String level, bool isArabic) {
  switch (level) {
    case 'retail':
      return 'tier_retail'.tr();
    case 'salesman':
      return 'tier_salesman'.tr();
    case 'company':
      return 'tier_company'.tr();
    case 'wholesale':
      return 'tier_wholesale'.tr();
    default:
      return level;
  }
}
