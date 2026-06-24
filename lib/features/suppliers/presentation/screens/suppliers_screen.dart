import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supplier_bloc.dart';
import '../../domain/entities/supplier_entity.dart';
import '../widgets/supplier_form.dart';
import '../../../../widgets/responsive_layout.dart';
import '../../../../widgets/stat_card.dart';
import '../../../../core/di/di.dart';
import '../../../activity_log/domain/repositories/activity_log_repository.dart';
import '../../../balance/presentation/widgets/pay_balance_dialog.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedSupplierIds = {};
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(LoadSuppliers());
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
    final theme = Theme.of(context);

    return ResponsiveLayout(
      title: 'suppliers'.tr(),
      actions: [
        if (_selectedSupplierIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _confirmDeleteSelected(context),
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              label: Text('${'delete'.tr()} (${_selectedSupplierIds.length})', style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const SupplierForm(),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('add_supplier'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
          ),
        ),
      ],
      child: Column(
        children: [
          // Summary cards
          BlocBuilder<SupplierBloc, SupplierState>(
            builder: (context, state) {
              if (state is SupplierLoaded) {
                double totalOrders = 0;
                double totalRemaining = 0;
                for (final s in state.allSuppliers) {
                  totalOrders += s.totalOrders;
                  totalRemaining += s.balance;
                }
                double totalPaid = totalOrders - totalRemaining;

                final currencySymbol = 'currency_symbol'.tr();
                String formatCurrency(double val) => '${val.toStringAsFixed(2)} $currencySymbol';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 750 ? 3 : (constraints.maxWidth > 450 ? 2 : 1);
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: crossAxisCount == 3 ? 2.8 : (crossAxisCount == 2 ? 3.5 : 5.0),
                        children: [
                          StatCard(
                            title: 'total_orders'.tr(),
                            value: formatCurrency(totalOrders),
                            icon: Icons.local_shipping,
                            color: Colors.indigo,
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
                context.read<SupplierBloc>().add(SearchSuppliers(val));
              },
            ),
          ),

          // Suppliers Table
          Expanded(
            child: BlocBuilder<SupplierBloc, SupplierState>(
              builder: (context, state) {
                if (state is SupplierLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SupplierLoaded) {
                  final suppliers = state.filteredSuppliers;
                  if (suppliers.isEmpty) {
                    return Center(child: Text('no_data'.tr()));
                  }

                  return Scrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      scrollDirection: Axis.vertical,
                      child: Scrollbar(
                        controller: _horizontalScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            showCheckboxColumn: true,
                            columns: [
                              DataColumn(label: Text('supplier_name'.tr())),
                              DataColumn(label: Text('phone'.tr())),
                              DataColumn(label: Text('company_name'.tr())),
                              DataColumn(label: Text('total_orders'.tr())),
                              DataColumn(label: Text('paid'.tr())),
                              DataColumn(label: Text('remaining'.tr())),
                              DataColumn(label: Text('settings'.tr())),
                            ],
                            rows: suppliers.map((s) {
                              return DataRow(
                                selected: _selectedSupplierIds.contains(s.id),
                                onSelectChanged: (selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedSupplierIds.add(s.id);
                                    } else {
                                      _selectedSupplierIds.remove(s.id);
                                    }
                                  });
                                },
                                cells: [
                                  DataCell(Text(s.name)),
                                  DataCell(Text(s.phone)),
                                  DataCell(Text(s.company)),
                                  DataCell(Text('${s.totalOrders.toStringAsFixed(2)} EGP')),
                                  DataCell(Text('${(s.totalOrders - s.balance).toStringAsFixed(2)} EGP')),
                                  DataCell(
                                    Text(
                                      '${s.balance.toStringAsFixed(2)} EGP',
                                      style: TextStyle(
                                        color: s.balance > 0 ? Colors.red : Colors.green,
                                        fontWeight: s.balance > 0 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.history, color: Colors.teal),
                                          tooltip: context.locale.languageCode == 'ar' ? 'سجل المعاملات' : 'History',
                                          onPressed: () => _showSupplierHistory(context, s),
                                        ),
                                        if (s.balance > 0)
                                          IconButton(
                                            icon: const Icon(Icons.payment, color: Colors.green),
                                            tooltip: 'pay_balance'.tr(),
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
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => SupplierForm(supplier: s),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _confirmDelete(context, s.id),
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
                  );
                }
                if (state is SupplierError) {
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
                context.read<SupplierBloc>().add(DeleteSupplierEvent(id));
                setState(() {
                  _selectedSupplierIds.remove(id);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('delete'.tr(), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('confirm'.tr()),
          content: Text(
            context.locale.languageCode == 'ar'
                ? 'هل أنت متأكد من حذف ${_selectedSupplierIds.length} من الموردين المحددين؟'
                : 'Are you sure you want to delete ${_selectedSupplierIds.length} selected supplier(s)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SupplierBloc>().add(DeleteMultipleSuppliersEvent(_selectedSupplierIds.toList()));
                setState(() {
                  _selectedSupplierIds.clear();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('delete'.tr(), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSupplierHistory(BuildContext context, SupplierEntity supplier) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final currencySymbol = isArabic ? 'ج.م' : 'EGP';
    String formatCurrency(double val) => '${val.toStringAsFixed(2)} $currencySymbol';

    final allLogs = Gravity.find<ActivityLogRepository>().getAllLogs();
    final supplierLogs = allLogs.where((log) {
      if (log.category != 'supplier') return false;
      final desc = log.description.toLowerCase();
      final name = supplier.name.toLowerCase();
      return desc.contains(name);
    }).toList();
    // Sort logs descending by timestamp
    supplierLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
                              ? 'سجل تعاملات المورد: ${supplier.name}' 
                              : 'Business History: ${supplier.name}',
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
                            color: Colors.indigo.shade50,
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Column(
                                children: [
                                  Text('total_orders'.tr(), style: TextStyle(fontSize: 11.sp, color: Colors.indigo.shade800)),
                                  SizedBox(height: 4.h),
                                  Text(formatCurrency(supplier.totalOrders), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
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
                                  Text(formatCurrency(supplier.totalOrders - supplier.balance), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
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
                                  Text(formatCurrency(supplier.balance), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Log Feed list
                    Expanded(
                      child: supplierLogs.isEmpty
                          ? Center(
                              child: Text(
                                isArabic ? 'لا توجد حركات تعاملات مسجلة لهذا المورد' : 'No recorded logs or transactions for this supplier',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            )
                          : ListView.builder(
                              itemCount: supplierLogs.length,
                              itemBuilder: (context, index) {
                                final log = supplierLogs[index];
                                final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(log.timestamp);
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 4.h),
                                  child: ListTile(
                                    leading: Icon(
                                      log.action == 'purchase_return' 
                                          ? Icons.keyboard_return 
                                          : (log.action == 'add_supplier' ? Icons.person_add : Icons.edit),
                                      color: log.action == 'purchase_return' 
                                          ? Colors.orange 
                                          : theme.colorScheme.primary,
                                    ),
                                    title: Text(
                                      log.description,
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                    subtitle: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(formattedDate, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                                        Text(
                                          '${'cashier'.tr()}: ${log.userId}',
                                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                                        ),
                                      ],
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
