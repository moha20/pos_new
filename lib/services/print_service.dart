import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart'
    show rootBundle, Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/pos/domain/entities/sale_entity.dart';
import '../features/customers/domain/entities/customer_entity.dart';
import '../core/di/di.dart';

class PrintService {
  // Cache loaded fonts to avoid re-downloading
  pw.Font? _baseFont;
  pw.Font? _boldFont;
  List<pw.Font>? _fallbackFonts;

  Future<void> _loadFonts() async {
    if (_baseFont != null && _boldFont != null && _fallbackFonts != null)
      return;

    // Load local Amiri font (fully offline-compatible, shapes Arabic perfectly)
    final regularData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');

    _baseFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);

    _fallbackFonts = [_baseFont!, _boldFont!];
  }

  pw.TextStyle _style({
    double fontSize = 8,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.TextStyle(
      font: bold ? _boldFont : _baseFont,
      fontBold: _boldFont,
      fontFallback: _fallbackFonts!,
      fontSize: fontSize,
      color: color,
    );
  }

  Future<pw.Document> _buildInvoicePdf(
    BuildContext context,
    SaleEntity sale,
    String companyName,
    String lang,
    pw.MemoryImage logoImage, {
    CustomerEntity? customer,
  }) async {
    final pdf = pw.Document();
    final isAr = lang == 'ar';
    final textDirection = isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    // Localized Labels
    final isDraft =
        sale.id == 'draft' || (sale.note?.contains('DRAFT') ?? false);
    final title = isDraft
        ? (isAr ? 'مسودة فاتورة (معاينة)' : 'Draft Invoice Preview')
        : (isAr ? 'بيان مبيعات' : 'Sales Receipt');
    final dateLabel = isAr ? 'التاريخ: ' : 'Date: ';
    final invLabel = isAr ? 'رقم البيان: ' : 'Invoice No: ';
    final custLabel = isAr ? 'العميل: ' : 'Customer: ';
    final userLabel = isAr ? 'المستخدم: ' : 'Cashier: ';
    final addrLabel = isAr ? 'العنوان: ' : 'Address: ';
    final phoneLabel = isAr ? 'الهاتف: ' : 'Phone: ';

    final tableHeaders = isAr
        ? ['م', 'اسم الصنف', 'الوحدة', 'الكمية', 'السعر', 'خصم %', 'الاجمالي']
        : ['No', 'Item Name', 'Unit', 'Qty', 'Price', 'Disc %', 'Total'];

    final subtotalLabel = isAr ? 'المجموع الفرعي:' : 'Subtotal:';
    final discountLabel = isAr ? 'الخصم:' : 'Discount:';
    final taxLabel = isAr ? 'الضريبة:' : 'Tax:';
    final totalLabel = isAr ? 'صافي الفاتورة:' : 'Net Invoice:';
    final prevBalLabel = isAr ? 'الرصيد السابق:' : 'Prev Balance:';
    final totAccLabel = isAr ? 'إجمالي الحساب:' : 'Total Account:';
    final paidLabel = isAr ? 'المدفوع:' : 'Amount Paid:';
    final remLabel = isAr ? 'الرصيد الحالي:' : 'Remaining Debt:';

    final itemsCountLabel = isAr ? 'عدد الأصناف: ' : 'Items Count: ';
    final totalQtyLabel = isAr ? 'إجمالي الكمية: ' : 'Total Qty: ';

    final defaultCustomerName = isAr ? 'عميل نقدي' : 'Cash Customer';

    final printTimeStr = isAr
        ? 'طباعة: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}'
        : 'Print Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}';

    final prefs = Gravity.find<SharedPreferences>();
    final systemFooterText = isAr
        ? 'Mazaya Co. for Programming 01118152828 / شركة مزايا للبرمجيات'
        : 'Mazaya Co. for Programming 01118152828';

    final addressText =
        prefs.getString('company_address') ??
        (isAr ? 'الهرم - مربوطة حمزة' : 'Haram - Marboutat Hamza');
    final phoneText =
        prefs.getString('company_phone') ??
        (isAr
            ? 'ت: ٠١١١٥٥٢٥٩٤٢ / ٠١٢٢٥٥٩٥٢٧١'
            : 'Tel: 01115525942 / 01225595271');

    final distributorText =
        prefs.getString('company_distributor') ??
        (isAr
            ? 'موزع معتمد - مصطفى محمود'
            : 'Authorized Distributor - Mostafa Mahmoud');
    final companyNameText = prefs.getString('company_name') ?? companyName;
    final tafqeetText = isAr
        ? tafqeet(sale.total)
        : 'Only ${sale.total.toStringAsFixed(2)} EGP';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        theme: pw.ThemeData.withFont(
          base: _baseFont!,
          bold: _boldFont!,
          fontFallback: _fallbackFonts!,
        ),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: textDirection,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // 1. Top Header Row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Right/Left side depending on layout direction
                      pw.Column(
                        crossAxisAlignment: isAr
                            ? pw.CrossAxisAlignment.start
                            : pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            addressText,
                            style: _style(fontSize: 8, bold: true),
                          ),
                          pw.Text(phoneText, style: _style(fontSize: 7)),
                        ],
                      ),
                      // Center: Logo & Title
                      pw.Column(
                        children: [
                          pw.Container(
                            height: 35,
                            width: 75,
                            child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            title,
                            style: _style(fontSize: 9, bold: true),
                          ),
                        ],
                      ),
                      // Left/Right side depending on layout direction
                      pw.Column(
                        crossAxisAlignment: isAr
                            ? pw.CrossAxisAlignment.end
                            : pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            distributorText,
                            style: _style(fontSize: 8, bold: true),
                          ),
                          pw.Text(companyNameText, style: _style(fontSize: 7)),
                        ],
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 1),
                  if (isDraft) ...[
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFFFF3CD), // Amber 100
                        borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        isAr
                            ? 'معاينة مسودة - هذه ليست فاتورة نهائية ولم يتم حفظها في النظام'
                            : 'DRAFT PREVIEW - NOT A FINAL INVOICE, NOT SAVED IN SYSTEM',
                        style: _style(
                          fontSize: 8,
                          bold: true,
                          color: const PdfColor.fromInt(0xFF856404),
                        ), // Amber 900
                      ),
                    ),
                    pw.SizedBox(height: 4),
                  ],
                  pw.SizedBox(height: 4),

                  // 2. Customer & Date Info Box
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.grey300,
                        width: 0.5,
                      ),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(6),
                      ),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoPair(
                              dateLabel,
                              DateFormat(
                                'yyyy-MM-dd HH:mm',
                              ).format(sale.createdAt),
                            ),
                            _buildInfoPair(invLabel, sale.invoiceNumber),
                          ],
                        ),
                        pw.SizedBox(height: 3),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoPair(
                              custLabel,
                              customer?.name ?? defaultCustomerName,
                            ),
                            _buildInfoPair(userLabel, sale.cashierId),
                          ],
                        ),
                        pw.SizedBox(height: 3),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoPair(
                              addrLabel,
                              customer?.address ?? 'N/A',
                            ),
                            _buildInfoPair(
                              phoneLabel,
                              customer?.phone ?? 'N/A',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // 3. Items Table
                  pw.TableHelper.fromTextArray(
                    context: context,
                    border: pw.TableBorder.all(
                      color: PdfColors.grey400,
                      width: 0.5,
                    ),
                    headers: tableHeaders,
                    data: List<List<dynamic>>.generate(sale.items.length, (
                      index,
                    ) {
                      final item = sale.items[index];
                      return [
                        '${index + 1}',
                        item.productName,
                        isAr ? 'قطعة' : 'Piece',
                        '${item.qty}',
                        item.unitPrice.toStringAsFixed(2),
                        '0.0%',
                        item.totalPrice.toStringAsFixed(2),
                      ];
                    }),
                    headerStyle: _style(fontSize: 7, bold: true),
                    cellStyle: _style(fontSize: 7),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    cellAlignment: pw.Alignment.center,
                  ),
                  pw.SizedBox(height: 8),

                  // 4. Summaries & Footer Row
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Quantities count and Tafqeet
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '$itemsCountLabel${sale.items.length}',
                              style: _style(fontSize: 8),
                            ),
                            pw.Text(
                              '$totalQtyLabel${sale.items.fold(0, (sum, item) => sum + item.qty)}',
                              style: _style(fontSize: 8),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              tafqeetText,
                              style: _style(
                                fontSize: 8,
                                bold: true,
                                color: PdfColors.blueGrey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Financial Totals Box
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: PdfColors.grey300,
                              width: 0.5,
                            ),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(6),
                            ),
                          ),
                          child: pw.Column(
                            children: [
                              _summaryRow(
                                subtotalLabel,
                                sale.subtotal.toStringAsFixed(2),
                              ),
                              if (sale.discount > 0)
                                _summaryRow(
                                  discountLabel,
                                  '-${sale.discount.toStringAsFixed(2)}',
                                  color: PdfColors.red,
                                ),
                              if (sale.tax > 0)
                                _summaryRow(
                                  taxLabel,
                                  sale.tax.toStringAsFixed(2),
                                ),
                              pw.Divider(thickness: 0.5),
                              _summaryRow(
                                totalLabel,
                                '${sale.total.toStringAsFixed(2)} EGP',
                                bold: true,
                                color: PdfColors.blue800,
                              ),
                              if (customer != null) ...[
                                _summaryRow(
                                  prevBalLabel,
                                  customer.balance.toStringAsFixed(2),
                                ),
                                _summaryRow(
                                  totAccLabel,
                                  (customer.balance + sale.amountRemaining)
                                      .toStringAsFixed(2),
                                  bold: true,
                                ),
                              ],
                              pw.Divider(thickness: 0.5),
                              _summaryRow(
                                paidLabel,
                                sale.amountPaid.toStringAsFixed(2),
                                color: PdfColors.green800,
                              ),
                              _summaryRow(
                                remLabel,
                                sale.amountRemaining.toStringAsFixed(2),
                                bold: true,
                                color: PdfColors.red800,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),

                  // 5. System Footer info
                  pw.Divider(thickness: 0.5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(systemFooterText, style: _style(fontSize: 6)),
                      pw.Text(printTimeStr, style: _style(fontSize: 6)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf;
  }

  Future<pw.MemoryImage> _getLogoImage() async {
    try {
      final prefs = Gravity.find<SharedPreferences>();
      final logoPath = prefs.getString('logo_path');
      if (logoPath != null && logoPath.isNotEmpty) {
        if (logoPath.startsWith('data:image/')) {
          final base64String = logoPath.split(',').last;
          final bytes = base64.decode(base64String);
          return pw.MemoryImage(bytes);
        } else if (!kIsWeb && File(logoPath).existsSync()) {
          final bytes = await File(logoPath).readAsBytes();
          return pw.MemoryImage(bytes);
        }
      }
    } catch (_) {}
    final logoData = await rootBundle.load('assets/images/logo.jpg');
    return pw.MemoryImage(logoData.buffer.asUint8List());
  }

  Future<void> printInvoice(
    BuildContext context,
    SaleEntity sale,
    String companyName,
    String lang, {
    CustomerEntity? customer,
  }) async {
    await _loadFonts();

    final logoImage = await _getLogoImage();

    // Show PDF preview Dialog first
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) {
        String activeLang = lang;
        bool isMaximized = false;
        return StatefulBuilder(
          builder: (context, setState) {
            final isArabic = activeLang == 'ar';
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isMaximized ? screenWidth * 0.95 : 500,
                height: isMaximized ? screenHeight * 0.95 : 650,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'invoice_preview'.tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Language Dropdown Selector
                          Row(
                          children: [
                            Text(
                              'receipt_language'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: activeLang,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 20,
                                  ),
                                  dropdownColor: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'ar',
                                      child: Text(
                                        'العربية',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'en',
                                      child: Text(
                                        'English',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        activeLang = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isMaximized
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                              ),
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
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: PdfPreview(
                        key: ValueKey(activeLang),
                        build: (format) async {
                          final doc = await _buildInvoicePdf(
                            context,
                            sale,
                            companyName,
                            activeLang,
                            logoImage,
                            customer: customer,
                          );
                          return doc.save();
                        },
                        allowPrinting: true,
                        allowSharing: true,
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        canDebug: false,
                        actions: const [],
                      ),
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

  Future<void> shareInvoice(
    BuildContext context,
    SaleEntity sale,
    String companyName,
    String lang, {
    CustomerEntity? customer,
  }) async {
    await _loadFonts();
    final logoImage = await _getLogoImage();
    if (!context.mounted) return;
    final doc = await _buildInvoicePdf(
      context,
      sale,
      companyName,
      lang,
      logoImage,
      customer: customer,
    );
    final pdfBytes = await doc.save();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'invoice_${sale.invoiceNumber}.pdf',
    );
  }

  Future<void> shareToWhatsApp(
    BuildContext context,
    SaleEntity sale, {
    CustomerEntity? customer,
    String? customerName,
    String? customerPhone,
  }) async {
    final isArabic = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final phoneController = TextEditingController(text: customerPhone ?? '');

    String resolvedCustName = customerName ?? '';
    if (resolvedCustName.isEmpty) {
      resolvedCustName = isArabic ? 'عميل نقدي' : 'Cash Customer';
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool shareViaWeb = true; // Default to WhatsApp Web as requested
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Row(
                children: [
                  const Icon(Icons.share, color: Colors.green),
                  SizedBox(width: 8.w),
                  Text(
                    isArabic ? 'مشاركة عبر واتساب' : 'Share via WhatsApp',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isArabic
                        ? 'أدخل رقم هاتف العميل (اختياري، مع رمز الدولة مثل 2010...)'
                        : 'Enter customer phone number (Optional, e.g., 2010...)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                      labelText: isArabic ? 'رقم الهاتف' : 'Phone Number',
                      hintText: '201001234567',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Option: WhatsApp Web vs App
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          value: true,
                          groupValue: shareViaWeb,
                          title: Text(
                            isArabic ? 'واتساب ويب' : 'WhatsApp Web',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            if (val != null) setState(() => shareViaWeb = val);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          value: false,
                          groupValue: shareViaWeb,
                          title: Text(
                            isArabic ? 'تطبيق واتساب' : 'WhatsApp App',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            if (val != null) setState(() => shareViaWeb = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    shareViaWeb
                        ? (isArabic
                            ? '• سيتم فتح واتساب ويب وتنزيل الفاتورة بصيغة PDF لتتمكن من إرسالها.'
                            : '• WhatsApp Web will open, and the PDF invoice will download for you to send.')
                        : (isArabic
                            ? '• سيتم فتح قائمة المشاركة بالنظام لمشاركة ملف الفاتورة PDF عبر تطبيق واتساب.'
                            : '• The system share menu will open to share the PDF invoice via the WhatsApp app.'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10.sp,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _performWhatsAppShare(
                      context,
                      sale,
                      resolvedCustName,
                      phoneController.text.trim(),
                      shareViaWeb,
                      customer: customer,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'مشاركة' : 'Share',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _performWhatsAppShare(
    BuildContext context,
    SaleEntity sale,
    String customerName,
    String phone,
    bool shareViaWeb, {
    CustomerEntity? customer,
  }) async {
    final isArabic = context.locale.languageCode == 'ar';
    final currencySymbol = isArabic ? 'ج.م' : 'EGP';

    // 1. Build Formatted Invoice Message
    final buffer = StringBuffer();
    final isDraft =
        sale.id == 'draft' || (sale.note?.contains('DRAFT') ?? false);
    final prefs = Gravity.find<SharedPreferences>();
    final companyNameText =
        prefs.getString('company_name') ??
        (isArabic
            ? 'المهندس للأدوات الكهربائية'
            : 'Al Mohands Electrical Tools');
    if (isArabic) {
      if (isDraft) {
        buffer.writeln('*[معاينة مسودة غير محفوظة]*');
        buffer.writeln();
      }
      buffer.writeln('*بيان مبيعات - $companyNameText*');
      buffer.writeln('*رقم الفاتورة:* #${sale.invoiceNumber}');
      buffer.writeln(
        '*التاريخ:* ${DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt)}',
      );
      buffer.writeln('*العميل:* $customerName');
      buffer.writeln('*الكاشير:* ${sale.cashierId}');
      buffer.writeln();
      buffer.writeln('*المنتجات:*');
      for (final item in sale.items) {
        buffer.writeln(
          '• ${item.productName} (الكمية: ${item.qty}) - ${(item.totalPrice).toStringAsFixed(2)} $currencySymbol',
        );
      }
      buffer.writeln();
      buffer.writeln('*الملخص المالي:*');
      buffer.writeln(
        '- المجموع الفرعي: ${sale.subtotal.toStringAsFixed(2)} $currencySymbol',
      );
      if (sale.discount > 0) {
        buffer.writeln(
          '- الخصم: -${sale.discount.toStringAsFixed(2)} $currencySymbol',
        );
      }
      if (sale.tax > 0) {
        buffer.writeln(
          '- الضريبة: ${sale.tax.toStringAsFixed(2)} $currencySymbol',
        );
      }
      buffer.writeln(
        '- *صافي الفاتورة:* ${sale.total.toStringAsFixed(2)} $currencySymbol',
      );
      buffer.writeln(
        '- المدفوع: ${sale.amountPaid.toStringAsFixed(2)} $currencySymbol',
      );
      buffer.writeln(
        '- *المتبقي:* ${sale.amountRemaining.toStringAsFixed(2)} $currencySymbol',
      );
      buffer.writeln();
      buffer.writeln('شكراً لتعاملكم معنا!');
      final whatsappPhone = prefs.getString('whatsapp_phone') ?? '';
      if (whatsappPhone.isNotEmpty) {
        buffer.writeln('للتواصل عبر واتساب: $whatsappPhone');
      }
    } else {
      if (isDraft) {
        buffer.writeln('*[DRAFT INVOICE PREVIEW - NOT SAVED]*');
        buffer.writeln();
      }
      buffer.writeln('*Sales Receipt - $companyNameText*');
      buffer.writeln('*Invoice No:* #${sale.invoiceNumber}');
      buffer.writeln(
        '*Date:* ${DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt)}',
      );
      buffer.writeln('*Customer:* $customerName');
      buffer.writeln('*Cashier:* ${sale.cashierId}');
      buffer.writeln();
      buffer.writeln('*Items:*');
      for (final item in sale.items) {
        buffer.writeln(
          '• ${item.productName} (Qty: ${item.qty}) - ${(item.totalPrice).toStringAsFixed(2)} $currencySymbol',
        );
      }
      buffer.writeln();
      buffer.writeln('*Financial Summary:*');
      buffer.writeln(
        '- Subtotal: ${sale.subtotal.toStringAsFixed(2)} $currencySymbol',
      );
      if (sale.discount > 0) {
        buffer.writeln(
          '- Discount: -${sale.discount.toStringAsFixed(2)} $currencySymbol',
        );
      }
      if (sale.tax > 0) {
        buffer.writeln('- Tax: ${sale.tax.toStringAsFixed(2)} $currencySymbol');
      }
      buffer.writeln(
        '- *Net Invoice:* ${sale.total.toStringAsFixed(2)} $currencySymbol',
      );
      buffer.writeln(
        '- Amount Paid: ${sale.amountPaid.toStringAsFixed(2)} $currencySymbol',
      );
      buffer.writeln(
        '- *Remaining:* ${sale.amountRemaining.toStringAsFixed(2)} $currencySymbol',
      );
      buffer.writeln();
      buffer.writeln('Thank you for shopping with us!');
      final whatsappPhoneEn = prefs.getString('whatsapp_phone') ?? '';
      if (whatsappPhoneEn.isNotEmpty) {
        buffer.writeln('Contact us via WhatsApp: $whatsappPhoneEn');
      }
    }

    final textMsg = buffer.toString();

    // 2. Copy to clipboard automatically for convenient backup/manual pasting
    await Clipboard.setData(ClipboardData(text: textMsg));

    // 3. Generate PDF invoice bytes
    await _loadFonts();
    final logoImage = await _getLogoImage();
    
    if (!context.mounted) return;

    final doc = await _buildInvoicePdf(
      context,
      sale,
      companyNameText,
      context.locale.languageCode,
      logoImage,
      customer: customer,
    );
    final pdfBytes = await doc.save();

    // 4. Format phone number (remove leading +, remove spaces/dashes)
    var formattedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedPhone.startsWith('01') && formattedPhone.length == 11) {
      formattedPhone = '2$formattedPhone';
    }

    // 5. Perform sharing action based on choice
    if (shareViaWeb) {
      // For WhatsApp Web, open the browser chat URL
      String urlString;
      final encodedText = Uri.encodeComponent(textMsg);
      if (formattedPhone.isNotEmpty) {
        urlString =
            'https://web.whatsapp.com/send?phone=$formattedPhone&text=$encodedText';
      } else {
        urlString = 'https://web.whatsapp.com/send?text=$encodedText';
      }

      final uri = Uri.parse(urlString);

      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $urlString';
        }
      } catch (_) {}

      // Download/Share the PDF file so they can attach it
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'invoice_${sale.invoiceNumber}.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'تم فتح واتساب ويب وتنزيل الفاتورة PDF. يمكنك إرفاق الملف ولصق النص المنسوخ.'
                  : 'WhatsApp Web opened & PDF invoice downloaded. You can attach the PDF and paste the text.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // For WhatsApp App (direct PDF sharing via OS share sheet)
      try {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'invoice_${sale.invoiceNumber}.pdf',
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? 'جاري فتح قائمة المشاركة بالنظام لمشاركة ملف الفاتورة PDF...'
                    : 'Opening system share menu to share PDF invoice...',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? 'فشل في فتح قائمة المشاركة. تم نسخ النص للحافظة.'
                    : 'Could not open share menu, but invoice text was copied to clipboard.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> printZReport(
    BuildContext context, {
    required double startingCash,
    required double totalSales,
    required double totalExpenses,
    required double expectedCash,
    required String lang,
  }) async {
    await _loadFonts();

    final logoImage = await _getLogoImage();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        theme: pw.ThemeData.withFont(
          base: _baseFont!,
          bold: _boldFont!,
          fontFallback: _fallbackFonts!,
        ),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Column(
                      children: [
                        pw.Container(
                          height: 35,
                          width: 75,
                          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'تقرير إغلاق الصندوق (Z-Report)',
                          style: _style(fontSize: 12, bold: true),
                        ),
                      ],
                    ),
                  ),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'التاريخ والوقت: ${DateTime.now().toString().substring(0, 19)}',
                    style: _style(fontSize: 8),
                  ),
                  pw.Divider(thickness: 0.5),
                  pw.SizedBox(height: 8),
                  _zRow('النقدية الافتتاحية:', startingCash.toStringAsFixed(2)),
                  _zRow('إجمالي المبيعات:', totalSales.toStringAsFixed(2)),
                  _zRow(
                    'إجمالي المصروفات:',
                    '-${totalExpenses.toStringAsFixed(2)}',
                    color: PdfColors.red,
                  ),
                  pw.Divider(thickness: 0.5),
                  _zRow(
                    'النقدية المتوقعة بالصندوق:',
                    '${expectedCash.toStringAsFixed(2)} EGP',
                    bold: true,
                    color: PdfColors.green800,
                  ),
                  pw.Divider(thickness: 1),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'نهاية الوردية بنجاح',
                      style: _style(fontSize: 8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // Show PDF preview Dialog first
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isMaximized = false;
        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isMaximized ? screenWidth * 0.95 : 450,
                height: isMaximized ? screenHeight * 0.95 : 600,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang == 'ar'
                              ? 'معاينة تقرير وردية الصندوق'
                              : 'Z-Report Preview',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isMaximized
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                              ),
                              tooltip: lang == 'ar'
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
                    const SizedBox(height: 12),
                    Expanded(
                      child: PdfPreview(
                        build: (format) => pdf.save(),
                        allowPrinting: true,
                        allowSharing: true,
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        canDebug: false,
                        actions: const [],
                      ),
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

  // --- Helper Widgets ---

  pw.Widget _buildInfoPair(String label, String value) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(label, style: _style(fontSize: 8, bold: true)),
        pw.Text(value, style: _style(fontSize: 8)),
      ],
    );
  }

  pw.Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: _style(fontSize: 7, bold: bold, color: color),
          ),
          pw.Text(
            value,
            style: _style(fontSize: 7, bold: bold, color: color),
          ),
        ],
      ),
    );
  }

  pw.Widget _zRow(
    String label,
    String value, {
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: _style(fontSize: 10, bold: bold, color: color),
          ),
          pw.Text(
            value,
            style: _style(fontSize: 10, bold: bold, color: color),
          ),
        ],
      ),
    );
  }

  // --- Tafqeet (Number to Arabic Words) ---

  String tafqeet(double amount) {
    final whole = amount.floor();
    final decimals = ((amount - whole) * 100).round();

    if (whole == 0 && decimals == 0) return 'فقط صفر جنيه لا غير';

    String words = _convertGroup(whole);
    if (words.isEmpty) {
      words = 'صفر';
    }
    words += ' جنيهاً';

    if (decimals > 0) {
      words += ' و ${_convertGroup(decimals)} قرشاً';
    }

    return 'فقط $words لا غير';
  }

  String _convertGroup(int number) {
    if (number == 0) return '';

    final ones = [
      '',
      'واحد',
      'اثنان',
      'ثلاثة',
      'أربعة',
      'خمسة',
      'ستة',
      'سبعة',
      'ثمانية',
      'تسعة',
      'عشرة',
    ];
    final teens = [
      'عشرة',
      'أحد عشر',
      'اثنا عشر',
      'ثلاثة عشر',
      'أربعة عشر',
      'خمسة عشر',
      'ستة عشر',
      'سبعة عشر',
      'ثمانية عشر',
      'تسعة عشر',
    ];
    final tens = [
      '',
      'عشرة',
      'عشرون',
      'ثلاثون',
      'أربعون',
      'خمسون',
      'ستون',
      'سبعون',
      'ثمانون',
      'تسعون',
    ];
    final hundreds = [
      '',
      'مائة',
      'مائتان',
      'ثلاثمائة',
      'أربعمائة',
      'خمسمائة',
      'ستمائة',
      'سبعمائة',
      'ثمانمائة',
      'تسعمائة',
    ];

    if (number <= 10) return ones[number];
    if (number < 20) return teens[number - 10];

    if (number < 100) {
      final oneDigit = number % 10;
      final tenDigit = number ~/ 10;
      if (oneDigit == 0) return tens[tenDigit];
      return '${ones[oneDigit]} و ${tens[tenDigit]}';
    }

    if (number < 1000) {
      final hundredDigit = number ~/ 100;
      final remainder = number % 100;
      if (remainder == 0) return hundreds[hundredDigit];
      return '${hundreds[hundredDigit]} و ${_convertGroup(remainder)}';
    }

    if (number < 1000000) {
      final thousandDigit = number ~/ 1000;
      final remainder = number % 1000;
      String thousandWord = '';
      if (thousandDigit == 1) {
        thousandWord = 'ألف';
      } else if (thousandDigit == 2) {
        thousandWord = 'ألفين';
      } else if (thousandDigit >= 3 && thousandDigit <= 10) {
        thousandWord = '${ones[thousandDigit]} آلاف';
      } else {
        thousandWord = '${_convertGroup(thousandDigit)} ألف';
      }

      if (remainder == 0) return thousandWord;
      return '$thousandWord و ${_convertGroup(remainder)}';
    }

    return '$number';
  }
}
