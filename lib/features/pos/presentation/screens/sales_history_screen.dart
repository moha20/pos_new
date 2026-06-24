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

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final _searchController = TextEditingController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SalesHistoryCubit>().loadSales();
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

                // Search Box
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

                // Invoices Table
                Expanded(
                  child: sales.isEmpty
                      ? Center(child: Text('no_data'.tr()))
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
