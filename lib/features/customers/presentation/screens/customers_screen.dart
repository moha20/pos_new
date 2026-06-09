import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/customer_bloc.dart';
import '../widgets/customer_form.dart';
import '../../../../widgets/responsive_layout.dart';
import '../../../../widgets/stat_card.dart';
import '../../domain/entities/customer_entity.dart';
import '../../../../widgets/invoice_details_dialog.dart';
import '../../../pos/domain/repositories/sale_repository.dart';
import '../../../pos/domain/entities/sale_entity.dart';
import '../../../../core/di/di.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';

    return ResponsiveLayout(
      title: 'customers'.tr(),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CustomerForm(),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('add_customer'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
          ),
        ),
      ],
      child: Column(
        children: [
          // Summary cards
          BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoaded) {
                double totalPurchases = 0;
                double totalRemaining = 0;
                for (final c in state.allCustomers) {
                  totalPurchases += c.totalPurchases;
                  totalRemaining += c.balance;
                }
                double totalPaid = totalPurchases - totalRemaining;

                final currencySymbol = 'currency_symbol'.tr();
                String formatCurrency(double val) => '${val.toStringAsFixed(2)} $currencySymbol';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 900 ? 3 : 1;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: crossAxisCount == 3 ? 2.8 : 4.0,
                        children: [
                          StatCard(
                            title: 'total_purchases'.tr(),
                            value: formatCurrency(totalPurchases),
                            icon: Icons.monetization_on,
                            color: Colors.teal,
                          ),
                          StatCard(
                            title: 'paid'.tr(),
                            value: formatCurrency(totalPaid),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                          StatCard(
                            title: 'remaining'.tr(),
                            value: formatCurrency(totalRemaining),
                            icon: Icons.hourglass_empty,
                            color: Colors.red,
                          ),
                        ],
                      );
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onChanged: (val) {
                context.read<CustomerBloc>().add(SearchCustomers(val));
              },
            ),
          ),

          // Customers Table
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CustomerLoaded) {
                  final customers = state.filteredCustomers;
                  if (customers.isEmpty) {
                    return Center(child: Text('no_data'.tr()));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: [
                          DataColumn(label: Text('customer_name'.tr())),
                          DataColumn(label: Text('phone'.tr())),
                          DataColumn(label: Text('address'.tr())),
                          DataColumn(label: Text('price_tier'.tr())),
                          DataColumn(label: Text('total_purchases'.tr())),
                          DataColumn(label: Text('paid'.tr())),
                          DataColumn(label: Text('remaining'.tr())),
                          DataColumn(label: Text('settings'.tr())),
                        ],
                        rows: customers.map((c) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              if (selected == true) {
                                _showCustomerHistory(context, c);
                              }
                            },
                            cells: [
                              DataCell(Text(c.name)),
                              DataCell(Text(c.phone)),
                              DataCell(Text(c.address)),
                              DataCell(
                                Chip(
                                  label: Text(
                                    _getTierBadgeText(c.priceLevel, isArabic),
                                    style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: theme.colorScheme.secondary,
                                ),
                              ),
                              DataCell(Text('${c.totalPurchases.toStringAsFixed(2)} EGP')),
                              DataCell(Text('${(c.totalPurchases - c.balance).toStringAsFixed(2)} EGP')),
                              DataCell(
                                Text(
                                  '${c.balance.toStringAsFixed(2)} EGP',
                                  style: TextStyle(
                                    color: c.balance > 0 ? Colors.red : Colors.green,
                                    fontWeight: c.balance > 0 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => CustomerForm(customer: c),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(context, c.id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
                if (state is CustomerError) {
                  return Center(child: Text(state.message));
                }
                return Center(child: Text('no_data'.tr()));
              },
            ),
          ),
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

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('confirm'.tr()),
          content: Text('confirm_delete'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CustomerBloc>().add(DeleteCustomerEvent(id));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('delete'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showCustomerHistory(BuildContext context, CustomerEntity customer) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final currencySymbol = isArabic ? 'ج.م' : 'EGP';
    String formatCurrency(double val) => '${val.toStringAsFixed(2)} $currencySymbol';

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isMaximized = false;
        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isMaximized ? screenWidth * 0.95 : 700.w,
                height: isMaximized ? screenHeight * 0.95 : 600.h,
                padding: EdgeInsets.all(24.0.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic 
                              ? 'سجل تعاملات العميل: ${customer.name}' 
                              : 'Business History: ${customer.name}',
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
                    SizedBox(height: 16.h),
                    
                    // Totals row inside dialog
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.teal.shade50,
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Column(
                                children: [
                                  Text('total_purchases'.tr(), style: TextStyle(fontSize: 11.sp, color: Colors.teal.shade800)),
                                  SizedBox(height: 4.h),
                                  Text(formatCurrency(customer.totalPurchases), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Card(
                            color: Colors.green.shade50,
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Column(
                                children: [
                                  Text('paid'.tr(), style: TextStyle(fontSize: 11.sp, color: Colors.green.shade800)),
                                  SizedBox(height: 4.h),
                                  Text(formatCurrency(customer.totalPurchases - customer.balance), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Card(
                            color: Colors.red.shade50,
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Column(
                                children: [
                                  Text('remaining'.tr(), style: TextStyle(fontSize: 11.sp, color: Colors.red.shade800)),
                                  SizedBox(height: 4.h),
                                  Text(formatCurrency(customer.balance), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Invoices Table
                    Expanded(
                      child: FutureBuilder<List<SaleEntity>>(
                        future: Gravity.find<SaleRepository>().getSales(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text(snapshot.error.toString()));
                          }
                          final allSales = snapshot.data ?? [];
                          final customerSales = allSales
                              .where((s) => s.customerId == customer.id)
                              .toList();
                          customerSales.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                          if (customerSales.isEmpty) {
                            return Center(
                              child: Text(
                                isArabic ? 'لا توجد فواتير مبيعات لهذا العميل' : 'No sales invoices found for this customer',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                showCheckboxColumn: false,
                                columns: [
                                  DataColumn(label: Text('invoice_number'.tr())),
                                  DataColumn(label: Text('date'.tr())),
                                  DataColumn(label: Text('total'.tr())),
                                  DataColumn(label: Text('paid'.tr())),
                                  DataColumn(label: Text('remaining'.tr())),
                                  DataColumn(label: Text('payment_method'.tr())),
                                  DataColumn(label: Text('settings'.tr())),
                                ],
                                rows: customerSales.map((sale) {
                                  final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt);
                                  return DataRow(
                                    onSelectChanged: (selected) {
                                      if (selected == true) {
                                        showInvoiceDetailsDialog(context, sale, customer.name);
                                      }
                                    },
                                    cells: [
                                      DataCell(Text(sale.invoiceNumber)),
                                      DataCell(Text(formattedDate)),
                                      DataCell(Text(formatCurrency(sale.total))),
                                      DataCell(Text(formatCurrency(sale.amountPaid))),
                                      DataCell(
                                        Text(
                                          formatCurrency(sale.amountRemaining),
                                          style: TextStyle(
                                            color: sale.amountRemaining > 0 ? Colors.red : Colors.green,
                                            fontWeight: sale.amountRemaining > 0 ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(sale.paymentMethod.tr())),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(Icons.visibility, color: theme.colorScheme.primary),
                                          onPressed: () {
                                            showInvoiceDetailsDialog(context, sale, customer.name);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
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
}
