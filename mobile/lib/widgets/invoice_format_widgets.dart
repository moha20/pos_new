import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/di/di.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/pos/domain/entities/sale_entity.dart';
import 'app_logo.dart';

class InvoiceStoreInfo {
  final String companyName;
  final String companyPhone;
  final String companyAddress;
  final String companyDistributor;

  const InvoiceStoreInfo({
    required this.companyName,
    required this.companyPhone,
    required this.companyAddress,
    required this.companyDistributor,
  });

  static String resolveCompanyName({
    String? name,
    bool isArabic = true,
    SharedPreferences? prefs,
    String? fallbackUserCompany,
  }) {
    String candidate = (name != null && name.trim().isNotEmpty) ? name.trim() : '';

    if (candidate.isEmpty && prefs != null) {
      final saved = prefs.getString('company_name')?.trim();
      if (saved != null && saved.isNotEmpty) {
        candidate = saved;
      }
    }

    if (candidate.isEmpty && fallbackUserCompany != null && fallbackUserCompany.trim().isNotEmpty) {
      candidate = fallbackUserCompany.trim();
    }

    final defaultName = isArabic ? 'المهندس للبرمجيات' : 'Elmohands software';

    // Discard only empty strings or exact placeholder translation labels:
    final isPlaceholder = candidate.isEmpty ||
        candidate == 'اسم الشركة / الفرع' ||
        candidate == 'Company / Branch Name' ||
        candidate == 'اسم الشركة' ||
        candidate == 'Company Name' ||
        candidate == 'Company / Store Name';

    if (isPlaceholder) {
      return defaultName;
    }

    if (candidate == 'Elmohands software' && isArabic) {
      return 'المهندس للبرمجيات';
    }

    return candidate;
  }

  factory InvoiceStoreInfo.fromContext(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    String? name;
    String? phone;
    String? address;
    String? distributor;

    try {
      final settingsState = context.watch<SettingsBloc>().state;
      if (settingsState is SettingsLoaded) {
        name = settingsState.companyName;
        phone = settingsState.companyPhone;
        address = settingsState.companyAddress;
        distributor = settingsState.companyDistributor;
      }
    } catch (_) {
      try {
        final settingsState = context.read<SettingsBloc>().state;
        if (settingsState is SettingsLoaded) {
          name = settingsState.companyName;
          phone = settingsState.companyPhone;
          address = settingsState.companyAddress;
          distributor = settingsState.companyDistributor;
        }
      } catch (_) {}
    }

    SharedPreferences? prefs;
    try {
      prefs = Gravity.find<SharedPreferences>();
      if (name == null || name.trim().isEmpty) {
        name = prefs.getString('company_name');
      }
      phone ??= prefs.getString('company_phone');
      address ??= prefs.getString('company_address');
      distributor ??= prefs.getString('company_distributor');
    } catch (_) {}

    String? userCompany;
    try {
      final user = context.read<AuthBloc>().currentUser;
      userCompany = user?.companyName;
    } catch (_) {}

    final resolvedName = resolveCompanyName(
      name: name,
      isArabic: isArabic,
      prefs: prefs,
      fallbackUserCompany: userCompany,
    );

    final resolvedPhone = (phone != null && phone.trim().isNotEmpty)
        ? phone.trim()
        : '٠١١١٥٥٢٥٩٤٢ / ٠١٢٢٥٥٩٥٢٧١';
    final resolvedAddress = (address != null && address.trim().isNotEmpty)
        ? address.trim()
        : (isArabic ? 'الهرم - مربوطة حمزة' : 'Al-Haram - Marbouta Hamza');
    final resolvedDistributor = (distributor != null && distributor.trim().isNotEmpty)
        ? distributor.trim()
        : (isArabic
            ? 'موزع معتمد - مصطفى محمود'
            : 'Authorized Distributor - Mostafa Mahmoud');

    return InvoiceStoreInfo(
      companyName: resolvedName,
      companyPhone: resolvedPhone,
      companyAddress: resolvedAddress,
      companyDistributor: resolvedDistributor,
    );
  }
}


enum InvoiceFormatShape { a4, a5, thermal80 }

extension InvoiceFormatShapeExt on InvoiceFormatShape {
  String get labelKey {
    switch (this) {
      case InvoiceFormatShape.a4:
        return 'invoice_shape_a4';
      case InvoiceFormatShape.a5:
        return 'invoice_shape_a5';
      case InvoiceFormatShape.thermal80:
        return 'invoice_shape_thermal';
    }
  }

  IconData get icon {
    switch (this) {
      case InvoiceFormatShape.a4:
        return Icons.description;
      case InvoiceFormatShape.a5:
        return Icons.feed;
      case InvoiceFormatShape.thermal80:
        return Icons.receipt_long;
    }
  }
}

class InvoiceFormattedPreview extends StatelessWidget {
  final SaleEntity sale;
  final String customerName;
  final InvoiceFormatShape shape;

  const InvoiceFormattedPreview({
    super.key,
    required this.sale,
    required this.customerName,
    this.shape = InvoiceFormatShape.a4,
  });

  @override
  Widget build(BuildContext context) {
    switch (shape) {
      case InvoiceFormatShape.a4:
        return A4InvoicePreviewWidget(sale: sale, customerName: customerName);
      case InvoiceFormatShape.a5:
        return A5InvoicePreviewWidget(sale: sale, customerName: customerName);
      case InvoiceFormatShape.thermal80:
        return ThermalReceiptPreviewWidget(sale: sale, customerName: customerName);
    }
  }
}

// ==========================================
// 1. A4 INVOICE PREVIEW WIDGET (Standard Full Page)
// ==========================================
class A4InvoicePreviewWidget extends StatelessWidget {
  final SaleEntity sale;
  final String customerName;

  const A4InvoicePreviewWidget({
    super.key,
    required this.sale,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final currency = isArabic ? 'ج.م' : 'EGP';
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt);
    final storeInfo = InvoiceStoreInfo.fromContext(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(28.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Company & Logo & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeInfo.companyName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'company_subtitle'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${'phone'.tr()}: ${storeInfo.companyPhone}',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                    if (storeInfo.companyAddress.isNotEmpty)
                      Text(
                        storeInfo.companyAddress,
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
              Container(
                height: 70.h,
                width: 140.w,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const AppLogo(fit: BoxFit.contain),
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'invoice_number'.tr()}: ${sale.invoiceNumber}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'a4_format_badge'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Customer & Metadata Grid
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _metaRow('customer_name'.tr(), customerName),
                      SizedBox(height: 4.h),
                      _metaRow('cashier'.tr(), sale.cashierId),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _metaRow('date'.tr(), dateStr),
                      SizedBox(height: 4.h),
                      _metaRow('payment_method'.tr(), sale.paymentMethod.tr()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Items Table
          Text(
            'items'.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300, width: 1),
            columnWidths: const {
              0: FixedColumnWidth(40),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.2),
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: [
                  _th('#'),
                  _th('product_name'.tr()),
                  _th('qty'.tr()),
                  _th('price'.tr()),
                  _th('total'.tr()),
                ],
              ),
              ...sale.items.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value;
                return TableRow(
                  children: [
                    _td('$idx'),
                    _td(item.productName),
                    _td('${item.qty}'),
                    _td('${item.unitPrice.toStringAsFixed(2)} $currency'),
                    _td('${item.totalPrice.toStringAsFixed(2)} $currency', isBold: true),
                  ],
                );
              }),
            ],
          ),

          SizedBox(height: 20.h),

          // Financial Summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sale.note != null && sale.note!.isNotEmpty) ...[
                      Text(
                        'note'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                      ),
                      Text(
                        sale.note!,
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Text(
                        '${'total_in_words'.tr()}: ${_tafqeet(sale.total, isArabic)}',
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('subtotal'.tr(), '${sale.subtotal.toStringAsFixed(2)} $currency'),
                      if (sale.discount > 0)
                        _summaryRow('discount'.tr(), '- ${sale.discount.toStringAsFixed(2)} $currency', isDiscount: true),
                      if (sale.tax > 0)
                        _summaryRow('tax'.tr(), '+ ${sale.tax.toStringAsFixed(2)} $currency'),
                      const Divider(),
                      _summaryRow('total'.tr(), '${sale.total.toStringAsFixed(2)} $currency', isTotal: true, color: theme.colorScheme.primary),
                      _summaryRow('amount_paid'.tr(), '${sale.amountPaid.toStringAsFixed(2)} $currency'),
                      if (sale.amountRemaining > 0)
                        _summaryRow('amount_remaining'.tr(), '${sale.amountRemaining.toStringAsFixed(2)} $currency', isRemaining: true),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 30.h),
          const Divider(),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'thank_you_notice'.tr(),
                  style: TextStyle(fontSize: 11.sp, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'signature_label'.tr(),
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. A5 INVOICE PREVIEW WIDGET (Medium Compact)
// ==========================================
class A5InvoicePreviewWidget extends StatelessWidget {
  final SaleEntity sale;
  final String customerName;

  const A5InvoicePreviewWidget({
    super.key,
    required this.sale,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final currency = isArabic ? 'ج.م' : 'EGP';
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt);
    final storeInfo = InvoiceStoreInfo.fromContext(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 580),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header A5
          Row(
            children: [
              Container(
                height: 45.h,
                width: 90.w,
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const AppLogo(fit: BoxFit.contain),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeInfo.companyName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'company_subtitle'.tr(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${'invoice_number'.tr()}: ${sale.invoiceNumber}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'a5_format_badge'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 8.h),

          // Metadata Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${'customer_name'.tr()}: $customerName', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
              Text('${'date'.tr()}: $dateStr', style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700)),
            ],
          ),

          SizedBox(height: 12.h),

          // Items Compact Table
          Table(
            border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: [
                  _th('product_name'.tr(), fontSize: 10),
                  _th('qty'.tr(), fontSize: 10),
                  _th('price'.tr(), fontSize: 10),
                  _th('total'.tr(), fontSize: 10),
                ],
              ),
              ...sale.items.map((item) {
                return TableRow(
                  children: [
                    _td(item.productName, fontSize: 10),
                    _td('${item.qty}', fontSize: 10),
                    _td('${item.unitPrice.toStringAsFixed(2)}', fontSize: 10),
                    _td('${item.totalPrice.toStringAsFixed(2)}', fontSize: 10, isBold: true),
                  ],
                );
              }),
            ],
          ),

          SizedBox(height: 12.h),

          // Totals summary
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _summaryRow('subtotal'.tr(), '${sale.subtotal.toStringAsFixed(2)} $currency', fontSize: 11),
                if (sale.discount > 0)
                  _summaryRow('discount'.tr(), '- ${sale.discount.toStringAsFixed(2)} $currency', isDiscount: true, fontSize: 11),
                const Divider(),
                _summaryRow('total'.tr(), '${sale.total.toStringAsFixed(2)} $currency', isTotal: true, color: theme.colorScheme.primary, fontSize: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. THERMAL RECEIPT PREVIEW WIDGET (80mm Cashier Printer)
// ==========================================
class ThermalReceiptPreviewWidget extends StatelessWidget {
  final SaleEntity sale;
  final String customerName;

  const ThermalReceiptPreviewWidget({
    super.key,
    required this.sale,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final currency = isArabic ? 'ج.م' : 'EGP';
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt);
    final storeInfo = InvoiceStoreInfo.fromContext(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7), // Receipt thermal paper tint
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.amber.shade300),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thermal Store Header
          Container(
            height: 45.h,
            width: 90.w,
            child: const AppLogo(fit: BoxFit.contain),
          ),
          SizedBox(height: 6.h),
          Text(
            storeInfo.companyName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'company_subtitle'.tr(),
            style: TextStyle(
              fontSize: 9.sp,
              fontFamily: 'monospace',
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            storeInfo.companyPhone,
            style: TextStyle(fontSize: 9.sp, fontFamily: 'monospace', color: Colors.grey.shade800),
          ),
          SizedBox(height: 8.h),
          Text(
            '------------------------------------------',
            style: TextStyle(color: Colors.grey.shade500, fontFamily: 'monospace'),
          ),

          // Invoice Info
          Text(
            '${'invoice_number'.tr()}: ${sale.invoiceNumber}',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
          Text(
            dateStr,
            style: TextStyle(fontSize: 10.sp, fontFamily: 'monospace'),
          ),
          Text(
            '${'customer_name'.tr()}: $customerName',
            style: TextStyle(fontSize: 10.sp, fontFamily: 'monospace'),
          ),
          Text(
            '${'cashier'.tr()}: ${sale.cashierId}',
            style: TextStyle(fontSize: 10.sp, fontFamily: 'monospace'),
          ),

          // Items Table (80mm Receipt Table)
          Table(
            border: TableBorder.all(
              color: Colors.black45,
              width: 0.8,
            ),
            columnWidths: const {
              0: const FlexColumnWidth(3.2),
              1: const FlexColumnWidth(1.0),
              2: const FlexColumnWidth(1.4),
              3: const FlexColumnWidth(1.6),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.07),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                    child: Text(
                      'item'.tr(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                    child: Text(
                      'qty'.tr(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                    child: Text(
                      'price'.tr(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                    child: Text(
                      'total'.tr(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              ...sale.items.map((item) {
                return TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 3.w),
                      child: Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
                      child: Text(
                        '${item.qty}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
                      child: Text(
                        item.unitPrice.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
                      child: Text(
                        item.totalPrice.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          SizedBox(height: 8.h),

          // Totals Breakdown
          _thermalRow('subtotal'.tr(), '${sale.subtotal.toStringAsFixed(2)} $currency'),
          if (sale.discount > 0)
            _thermalRow('discount'.tr(), '- ${sale.discount.toStringAsFixed(2)} $currency'),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  '${sale.total.toStringAsFixed(2)} $currency',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Fake Barcode Graphic for Receipt feel
          Container(
            height: 36.h,
            width: 180.w,
            color: Colors.black12,
            child: Icon(Icons.qr_code_2, size: 36.r, color: Colors.black87),
          ),
          SizedBox(height: 6.h),
          Text(
            'thank_you_cashier_notice'.tr(),
            style: TextStyle(fontSize: 10.sp, fontFamily: 'monospace'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _thermalRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 10.sp, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4.w),
          Text(value, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// Helpers
Widget _metaRow(String label, String val) {
  return Row(
    children: [
      Text('$label: ', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
      Expanded(
        child: Text(
          val,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget _th(String label, {double fontSize = 11}) {
  return Padding(
    padding: const EdgeInsets.all(6),
    child: Text(
      label,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _td(String label, {bool isBold = false, double fontSize = 11}) {
  return Padding(
    padding: const EdgeInsets.all(6),
    child: Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _summaryRow(
  String label,
  String value, {
  bool isTotal = false,
  bool isDiscount = false,
  bool isRemaining = false,
  Color? color,
  double fontSize = 11,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? fontSize + 2 : fontSize,
            fontWeight: isTotal || isRemaining ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isDiscount || isRemaining ? Colors.red : null),
          ),
        ),
      ],
    ),
  );
}

String _tafqeet(double amount, bool isAr) {
  if (!isAr) return 'Only ${amount.toStringAsFixed(2)} EGP';
  final whole = amount.floor();
  final fraction = ((amount - whole) * 100).round();
  String text = '$whole جنيه مصري';
  if (fraction > 0) {
    text += ' و $fraction قرشاً';
  }
  return '$text فقط لا غير';
}
