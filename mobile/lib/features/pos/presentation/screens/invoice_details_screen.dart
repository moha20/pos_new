import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sale_entity.dart';
import '../../../../widgets/responsive_layout.dart';
import '../../../../widgets/invoice_format_widgets.dart';
import '../../../../services/print_service.dart';
import '../../../../core/di/di.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final SaleEntity sale;
  final String? customerName;

  const InvoiceDetailsScreen({
    super.key,
    required this.sale,
    this.customerName,
  });

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  InvoiceFormatShape _selectedShape = InvoiceFormatShape.a4;
  String _customerName = '';

  @override
  void initState() {
    super.initState();
    _customerName = widget.customerName ?? '';
    if (_customerName.isEmpty && widget.sale.customerId != null) {
      try {
        final custState = context.read<CustomerBloc>().state;
        if (custState is CustomerLoaded) {
          final match = custState.allCustomers.firstWhere(
            (c) => c.id == widget.sale.customerId,
          );
          _customerName = match.name;
        }
      } catch (_) {}
    }
    if (_customerName.isEmpty) {
      _customerName = 'cash_customer'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveLayout(
      title: '${'invoice_details'.tr()} - ${widget.sale.invoiceNumber}',
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'back'.tr(),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/sales');
            }
          },
        ),
      ],
      child: Column(
        children: [
          // Control Bar: Shape Selector & Print Action
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    '${'invoice_shape'.tr()}: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Segmented Buttons for A4, A5, Thermal 80mm
                  SegmentedButton<InvoiceFormatShape>(
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: theme.colorScheme.primary,
                      selectedForegroundColor: Colors.white,
                    ),
                    segments: [
                      ButtonSegment<InvoiceFormatShape>(
                        value: InvoiceFormatShape.a4,
                        icon: const Icon(Icons.description),
                        label: Text('A4 (${'standard'.tr()})'),
                      ),
                      ButtonSegment<InvoiceFormatShape>(
                        value: InvoiceFormatShape.a5,
                        icon: const Icon(Icons.feed),
                        label: Text('A5 (${'medium'.tr()})'),
                      ),
                      ButtonSegment<InvoiceFormatShape>(
                        value: InvoiceFormatShape.thermal80,
                        icon: const Icon(Icons.receipt_long),
                        label: Text('80mm (${'receipt_cashier'.tr()})'),
                      ),
                    ],
                    selected: {_selectedShape},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedShape = newSelection.first;
                      });
                    },
                  ),

                  SizedBox(width: 16.w),

                  // Print Action Button
                  ElevatedButton.icon(
                    onPressed: () => _printInvoice(context),
                    icon: const Icon(Icons.print, color: Colors.white),
                    label: Text(
                      'print_invoice'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Preview Area wrapped in BlocBuilder to automatically re-render when company name changes
          Expanded(
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, _) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.r),
                  child: Center(
                    child: InvoiceFormattedPreview(
                      sale: widget.sale,
                      customerName: _customerName,
                      shape: _selectedShape,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _printInvoice(BuildContext context) async {
    final printService = Gravity.find<PrintService>();
    final storeInfo = InvoiceStoreInfo.fromContext(context);
    final lang = context.locale.languageCode;

    await printService.printInvoice(
      context,
      widget.sale,
      storeInfo.companyName,
      lang,
      shape: _selectedShape,
    );
  }
}
