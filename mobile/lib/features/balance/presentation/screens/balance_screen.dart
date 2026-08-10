import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/balance_cubit.dart';
import '../widgets/pay_balance_dialog.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../suppliers/presentation/bloc/supplier_bloc.dart';
import '../../../../widgets/responsive_layout.dart';
import '../../../../widgets/stat_card.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _customerVerticalController = ScrollController();
  final ScrollController _customerHorizontalController = ScrollController();
  final ScrollController _supplierVerticalController = ScrollController();
  final ScrollController _supplierHorizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BalanceCubit>().loadPayments();
    context.read<CustomerBloc>().add(LoadCustomers());
    context.read<SupplierBloc>().add(LoadSuppliers());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerVerticalController.dispose();
    _customerHorizontalController.dispose();
    _supplierVerticalController.dispose();
    _supplierHorizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final currencySymbol = 'currency_symbol'.tr();
    String formatCurrency(double val) =>
        '${val.toStringAsFixed(2)} $currencySymbol';

    return ResponsiveLayout(
      title: 'balance'.tr(),
      child: Column(
        children: [
          // Summary stat cards
          _buildStatCards(context, formatCurrency),

          // Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.15),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurface,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people, size: 18),
                        SizedBox(width: 6.w),
                        Text('customer_debts'.tr()),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_shipping, size: 18),
                        SizedBox(width: 6.w),
                        Text('supplier_debts'.tr()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCustomerDebtsTab(context, formatCurrency),
                _buildSupplierDebtsTab(context, formatCurrency),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(
    BuildContext context,
    String Function(double) formatCurrency,
  ) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, custState) {
        return BlocBuilder<SupplierBloc, SupplierState>(
          builder: (context, suppState) {
            return BlocBuilder<BalanceCubit, BalanceState>(
              builder: (context, balState) {
                double totalCustomerDebt = 0;
                double totalSupplierDebt = 0;
                double totalPaymentsMade = 0;

                if (custState is CustomerLoaded) {
                  for (final c in custState.allCustomers) {
                    totalCustomerDebt += c.balance;
                  }
                }
                if (suppState is SupplierLoaded) {
                  for (final s in suppState.allSuppliers) {
                    totalSupplierDebt += s.balance;
                  }
                }
                for (final p in balState.allPayments) {
                  totalPaymentsMade += p.amount;
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
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
                            title: 'total_customer_debt'.tr(),
                            value: formatCurrency(totalCustomerDebt),
                            icon: Icons.people,
                            color: Colors.red,
                          ),
                          StatCard(
                            title: 'total_supplier_debt'.tr(),
                            value: formatCurrency(totalSupplierDebt),
                            icon: Icons.local_shipping,
                            color: Colors.orange,
                          ),
                          StatCard(
                            title: 'payments_history'.tr(),
                            value: formatCurrency(totalPaymentsMade),
                            icon: Icons.payment,
                            color: Colors.green,
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCustomerDebtsTab(
    BuildContext context,
    String Function(double) formatCurrency,
  ) {
    final theme = Theme.of(context);

    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CustomerLoaded) {
          final debtors =
              state.allCustomers.where((c) => c.balance > 0).toList();
          debtors.sort((a, b) => b.balance.compareTo(a.balance));

          if (debtors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64.r,
                    color: Colors.green.withOpacity(0.4),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'no_outstanding_balance'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Scrollbar(
            controller: _customerVerticalController,
            thumbVisibility: true,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.vertical,
            child: Scrollbar(
              controller: _customerHorizontalController,
              thumbVisibility: true,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _customerVerticalController,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  controller: _customerHorizontalController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(label: Text('customer_name'.tr())),
                      DataColumn(label: Text('phone'.tr())),
                      DataColumn(label: Text('total_purchases'.tr())),
                      DataColumn(label: Text('paid'.tr())),
                      DataColumn(label: Text('remaining'.tr())),
                      DataColumn(label: Text('pay'.tr())),
                    ],
                    rows: debtors.map((c) {
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            c.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text(c.phone)),
                          DataCell(Text(formatCurrency(c.totalPurchases))),
                          DataCell(Text(
                            formatCurrency(c.totalPurchases - c.balance),
                            style: const TextStyle(color: Colors.green),
                          )),
                          DataCell(Text(
                            formatCurrency(c.balance),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          DataCell(
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => PayBalanceDialog(
                                    type: 'customer',
                                    targetId: c.id,
                                    targetName: c.name,
                                    currentBalance: c.balance,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.payment, size: 16, color: Colors.white),
                              label: Text(
                                'pay'.tr(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        }
        return Center(child: Text('no_data'.tr()));
      },
    );
  }

  Widget _buildSupplierDebtsTab(
    BuildContext context,
    String Function(double) formatCurrency,
  ) {
    final theme = Theme.of(context);

    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        if (state is SupplierLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SupplierLoaded) {
          final debtors =
              state.allSuppliers.where((s) => s.balance > 0).toList();
          debtors.sort((a, b) => b.balance.compareTo(a.balance));

          if (debtors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64.r,
                    color: Colors.green.withOpacity(0.4),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'no_outstanding_balance'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Scrollbar(
            controller: _supplierVerticalController,
            thumbVisibility: true,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.vertical,
            child: Scrollbar(
              controller: _supplierHorizontalController,
              thumbVisibility: true,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _supplierVerticalController,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  controller: _supplierHorizontalController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(label: Text('supplier_name'.tr())),
                      DataColumn(label: Text('phone'.tr())),
                      DataColumn(label: Text('company_name'.tr())),
                      DataColumn(label: Text('total_orders'.tr())),
                      DataColumn(label: Text('paid'.tr())),
                      DataColumn(label: Text('remaining'.tr())),
                      DataColumn(label: Text('pay'.tr())),
                    ],
                    rows: debtors.map((s) {
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text(s.phone)),
                          DataCell(Text(s.company)),
                          DataCell(Text(formatCurrency(s.totalOrders))),
                          DataCell(Text(
                            formatCurrency(s.totalOrders - s.balance),
                            style: const TextStyle(color: Colors.green),
                          )),
                          DataCell(Text(
                            formatCurrency(s.balance),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          DataCell(
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => PayBalanceDialog(
                                    type: 'supplier',
                                    targetId: s.id,
                                    targetName: s.name,
                                    currentBalance: s.balance,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.payment, size: 16, color: Colors.white),
                              label: Text(
                                'pay'.tr(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        }
        return Center(child: Text('no_data'.tr()));
      },
    );
  }
}
