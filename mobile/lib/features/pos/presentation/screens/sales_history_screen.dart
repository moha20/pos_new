import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sales_history_cubit.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../../widgets/responsive_layout.dart';
import '../../../../widgets/stat_card.dart';
import '../../../../core/di/di.dart';
import '../../../../services/print_service.dart';
import '../../../../widgets/invoice_details_dialog.dart';
import '../../../../services/cloud_sync_service.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final _searchController = TextEditingController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  bool _showOnline = false;
  List<OnlineSaleRecord> _onlineRecords = [];
  bool _isLoadingOnline = false;

  @override
  void initState() {
    super.initState();
    context.read<SalesHistoryCubit>().loadSales();
  }

  void _fetchOnlineSales() async {
    setState(() => _isLoadingOnline = true);
    try {
      final cloudSync = Gravity.find<CloudSyncService>();
      final list = await cloudSync.fetchOnlineSales();
      setState(() {
        _onlineRecords = list;
        _isLoadingOnline = false;
      });
    } catch (_) {
      setState(() => _isLoadingOnline = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final currencySymbol = 'currency_symbol'.tr();

    String formatCurrency(double val) =>
        '${val.toStringAsFixed(2)} $currencySymbol';

    return ResponsiveLayout(
      title: 'sales_history'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<SalesHistoryCubit>().loadSales();
          },
        ),
      ],
      child: BlocBuilder<SalesHistoryCubit, SalesHistoryState>(
        builder: (context, state) {
          if (state is SalesHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SalesHistoryLoaded) {
            final sales = state.filteredSales;
            final theme = Theme.of(context);
            final screenWidth = MediaQuery.of(context).size.width;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats Card Grid
                Padding(
                  padding: EdgeInsets.all(16.0.r),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 750 ? 3 : (constraints.maxWidth > 450 ? 2 : 1);
                      final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
                      final double cardHeight = 100.h;
                      final double childAspectRatio = itemWidth / cardHeight;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: childAspectRatio,
                        children: [
                          StatCard(
                            title: 'total'.tr(),
                            value: formatCurrency(state.totalSalesAmount),
                            icon: Icons.monetization_on,
                            color: Colors.teal,
                          ),
                          StatCard(
                            title: 'paid'.tr(),
                            value: formatCurrency(state.totalPaidAmount),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                          StatCard(
                            title: 'remaining'.tr(),
                            value: formatCurrency(state.totalRemainingAmount),
                            icon: Icons.hourglass_empty,
                            color: Colors.red,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Mode Selector Toggle (Local vs Online Cloud Sales)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<bool>(
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: theme.colorScheme.primary,
                            selectedForegroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                          segments: [
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(isArabic ? 'المبيعات المحلية' : 'Local Sales'),
                              icon: const Icon(Icons.table_chart_outlined, size: 18),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('online_sales'.tr()),
                              icon: const Icon(Icons.cloud_outlined, size: 18),
                            ),
                          ],
                          selected: {_showOnline},
                          onSelectionChanged: (val) {
                            final isOnline = val.first;
                            setState(() {
                              _showOnline = isOnline;
                            });
                            if (isOnline) {
                              _fetchOnlineSales();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),

                // Search Box
                if (!_showOnline)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'search'.tr(),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onChanged: (val) {
                        context.read<SalesHistoryCubit>().searchSales(val);
                      },
                    ),
                  ),
                SizedBox(height: 12.h),

                // Online Cloud Sales View
                if (_showOnline)
                  Expanded(
                    child: _isLoadingOnline
                        ? const Center(child: CircularProgressIndicator())
                        : _onlineRecords.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_off_rounded, size: 48.r, color: Colors.grey),
                                    SizedBox(height: 8.h),
                                    Text(
                                      isArabic ? 'لا توجد مبيعات أونلاين مسجلة بعد' : 'No online cloud sales recorded yet',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                itemCount: _onlineRecords.length,
                                itemBuilder: (context, index) {
                                  final rec = _onlineRecords[index];
                                  final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(rec.createdAt);
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 10.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      side: BorderSide(
                                        color: theme.dividerColor.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(14.r),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8.r),
                                                    ),
                                                    child: Text(
                                                      rec.invoiceNumber,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blue.shade800,
                                                        fontSize: 12.sp,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                                    decoration: BoxDecoration(
                                                      color: Colors.purple.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6.r),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.business, size: 12.r, color: Colors.purple),
                                                        SizedBox(width: 4.w),
                                                        Text(
                                                          rec.companyName,
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.purple.shade900,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                formatCurrency(rec.total),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 15.sp,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.person_pin, size: 14.r, color: Colors.grey),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    '${isArabic ? "الكاشير / المستخدم" : "Cashier"}: ${rec.cashierId}',
                                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                formattedDate,
                                                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),

                // Invoices List (DataTable for Desktop, Cards for Mobile & Tablet)
                if (!_showOnline)
                  Expanded(
                  child: sales.isEmpty
                      ? Center(child: Text('no_data'.tr()))
                      : (screenWidth <= 950)
                          ? ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              itemCount: sales.length,
                              itemBuilder: (context, index) {
                                final sale = sales[index];
                                final customerBloc = context.read<CustomerBloc>();
                                String customerName = isArabic ? 'عميل نقدي' : 'Cash Customer';
                                if (sale.customerId != null && customerBloc.state is CustomerLoaded) {
                                  final customers = (customerBloc.state as CustomerLoaded).allCustomers;
                                  try {
                                    final match = customers.firstWhere((c) => c.id == sale.customerId);
                                    customerName = match.name;
                                  } catch (_) {}
                                }
                                final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt);

                                return Card(
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: theme.dividerColor.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      showInvoiceDetailsDialog(context, sale, customerName);
                                    },
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(14.r),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Text(
                                                  sale.invoiceNumber,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.colorScheme.primary,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                formatCurrency(sale.total),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 15.sp,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            children: [
                                              Icon(Icons.person_outline, size: 16.r, color: Colors.grey.shade600),
                                              SizedBox(width: 4.w),
                                              Text(
                                                customerName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(Icons.access_time, size: 14.r, color: Colors.grey.shade600),
                                              SizedBox(width: 4.w),
                                              Text(
                                                formattedDate,
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Chip(
                                                visualDensity: VisualDensity.compact,
                                                label: Text(sale.paymentMethod.tr(), style: TextStyle(fontSize: 10.sp)),
                                                padding: EdgeInsets.zero,
                                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${'paid'.tr()}: ${sale.amountPaid.toStringAsFixed(2)}',
                                                    style: TextStyle(fontSize: 11.sp, color: Colors.green),
                                                  ),
                                                  if (sale.amountRemaining > 0) ...[
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      '${'remaining'.tr()}: ${sale.amountRemaining.toStringAsFixed(2)}',
                                                      style: TextStyle(fontSize: 11.sp, color: Colors.red, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Scrollbar(
                              controller: _verticalScrollController,
                              thumbVisibility: true,
                              notificationPredicate: (notification) =>
                                  notification.metrics.axis == Axis.vertical,
                              child: Scrollbar(
                                controller: _horizontalScrollController,
                                thumbVisibility: true,
                                notificationPredicate: (notification) =>
                                    notification.metrics.axis == Axis.horizontal,
                                child: SingleChildScrollView(
                                  controller: _verticalScrollController,
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    controller: _horizontalScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: DataTable(
                                    showCheckboxColumn: false,
                                    columns: [
                                      DataColumn(
                                        label: Text('invoice_number'.tr()),
                                      ),
                                      DataColumn(label: Text('customer_name'.tr())),
                                      DataColumn(label: Text('date'.tr())),
                                      DataColumn(label: Text('total'.tr())),
                                      DataColumn(label: Text('paid'.tr())),
                                      DataColumn(label: Text('remaining'.tr())),
                                      DataColumn(
                                        label: Text('payment_method'.tr()),
                                      ),
                                      DataColumn(label: Text('settings'.tr())),
                                    ],
                                    rows: sales.map((sale) {
                                      // Get customer name
                                      final customerBloc = context
                                          .read<CustomerBloc>();
                                      String customerName = isArabic
                                          ? 'عميل نقدي'
                                          : 'Cash Customer';
                                      if (sale.customerId != null &&
                                          customerBloc.state is CustomerLoaded) {
                                        final customers =
                                            (customerBloc.state as CustomerLoaded)
                                                .allCustomers;
                                        try {
                                          final match = customers.firstWhere(
                                            (c) => c.id == sale.customerId,
                                          );
                                          customerName = match.name;
                                        } catch (_) {}
                                      }

                                      // Date format
                                      final formattedDate = DateFormat(
                                        'yyyy-MM-dd HH:mm',
                                      ).format(sale.createdAt);

                                      return DataRow(
                                        onSelectChanged: (selected) {
                                          if (selected != null) {
                                            showInvoiceDetailsDialog(
                                              context,
                                              sale,
                                              customerName,
                                            );
                                          }
                                        },
                                        cells: [
                                          DataCell(Text(sale.invoiceNumber)),
                                          DataCell(Text(customerName)),
                                          DataCell(Text(formattedDate)),
                                          DataCell(
                                            Text(formatCurrency(sale.total)),
                                          ),
                                          DataCell(
                                            Text(formatCurrency(sale.amountPaid)),
                                          ),
                                          DataCell(
                                            Text(
                                              formatCurrency(sale.amountRemaining),
                                              style: TextStyle(
                                                color: sale.amountRemaining > 0
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontWeight: sale.amountRemaining > 0
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(sale.paymentMethod.tr())),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.print,
                                                    color: Colors.blue,
                                                  ),
                                                  tooltip: 'print'.tr(),
                                                  onPressed: () async {
                                                    final printService =
                                                        Gravity.find<PrintService>();
                                                    await printService.printInvoice(
                                                      context,
                                                      sale,
                                                      'Al Mohands Electrical Tools / المهندس للأدوات الكهربائية',
                                                      context.locale.languageCode,
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.share,
                                                    color: Colors.teal,
                                                  ),
                                                  tooltip: 'share'.tr(),
                                                  onPressed: () async {
                                                    final printService =
                                                        Gravity.find<PrintService>();
                                                    await printService.shareInvoice(
                                                      context,
                                                      sale,
                                                      'Al Mohands Electrical Tools / المهندس للأدوات الكهربائية',
                                                      context.locale.languageCode,
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.chat_rounded,
                                                    color: Colors.green,
                                                  ),
                                                  tooltip: 'WhatsApp',
                                                  onPressed: () async {
                                                    final printService =
                                                        Gravity.find<PrintService>();
                                                    String? customerPhone;
                                                    CustomerEntity? customerEntity;
                                                    if (sale.customerId != null) {
                                                      try {
                                                        final customerBloc = context.read<CustomerBloc>();
                                                        if (customerBloc.state is CustomerLoaded) {
                                                          final customers = (customerBloc.state as CustomerLoaded).allCustomers;
                                                          final match = customers.firstWhere((c) => c.id == sale.customerId);
                                                          customerPhone = match.phone;
                                                          customerEntity = match;
                                                        }
                                                      } catch (_) {}
                                                    }
                                                    await printService.shareToWhatsApp(
                                                      context,
                                                      sale,
                                                      customer: customerEntity,
                                                      customerName: customerName,
                                                      customerPhone: customerPhone,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            );
          }
          if (state is SalesHistoryError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('no_data'.tr()));
        },
      ),
    );
  }
}
