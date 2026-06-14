import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cashier_bloc.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../../../../widgets/responsive_layout.dart';
import '../../../../services/print_service.dart';
import '../../../../core/di/di.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  final _startingCashController = TextEditingController();
  final _expenseDescController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  String _expenseCategory = 'شراء بضاعة / Stock Purchase';
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedExpenseIds = {};

  @override
  void initState() {
    super.initState();
    context.read<CashierBloc>().add(LoadCashier());
    context.read<ReportsBloc>().add(LoadReportsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveLayout(
      title: 'cashier'.tr(),
      child: BlocBuilder<CashierBloc, CashierState>(
        builder: (context, state) {
          if (state.status == CashierStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.isShiftOpen) {
            // Render register open dialog form
            return Center(
              child: Card(
                margin: EdgeInsets.all(24.0.r),
                child: Padding(
                  padding: EdgeInsets.all(32.0.r),
                  child: SizedBox(
                    width: 400.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.lock_open, size: 48, color: theme.colorScheme.primary),
                        SizedBox(height: 16.h),
                        Text(
                          'open_shift'.tr(),
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        TextField(
                          controller: _startingCashController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'starting_cash'.tr(),
                            prefixIcon: const Icon(Icons.payments),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            final cash = double.tryParse(_startingCashController.text) ?? 0.0;
                            context.read<CashierBloc>().add(OpenShiftEvent(cash));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text('confirm'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Active Shift Interface
          return Padding(
            padding: EdgeInsets.all(16.0.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Shift Info Summary
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'starting_cash'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${state.startingCash.toStringAsFixed(2)} EGP',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _handleCloseShift(context, state),
                          icon: const Icon(Icons.lock, color: Colors.white),
                          label: Text('close_shift'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Expense Management Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('expenses'.tr(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        if (_selectedExpenseIds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () => _confirmDeleteSelectedExpenses(context),
                              icon: const Icon(Icons.delete_sweep, color: Colors.white),
                              label: Text('${'delete'.tr()} (${_selectedExpenseIds.length})', style: const TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddExpenseDialog(context, state.activeShiftId),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text('add_expense'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Expenses table list
                Expanded(
                  child: state.expenses.isEmpty
                      ? Center(child: Text('no_data'.tr()))
                      : Card(
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                showCheckboxColumn: true,
                                columns: [
                                  DataColumn(label: Text('expense_description'.tr())),
                                  DataColumn(label: Text('amount'.tr())),
                                  DataColumn(label: Text('category'.tr())),
                                  DataColumn(label: Text('date'.tr())),
                                  DataColumn(label: Text('delete'.tr())),
                                ],
                                rows: state.expenses.map((e) {
                                  return DataRow(
                                    selected: _selectedExpenseIds.contains(e.id),
                                    onSelectChanged: (selected) {
                                      setState(() {
                                        if (selected == true) {
                                          _selectedExpenseIds.add(e.id);
                                        } else {
                                          _selectedExpenseIds.remove(e.id);
                                        }
                                      });
                                    },
                                    cells: [
                                      DataCell(Text(e.description)),
                                      DataCell(Text('${e.amount.toStringAsFixed(2)} EGP', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                                      DataCell(Text(e.category)),
                                      DataCell(Text(e.date.toString().substring(0, 16))),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _confirmDeleteExpense(context, e.id),
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
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, String? shiftId) {
    _expenseDescController.clear();
    _expenseAmountController.clear();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('add_expense'.tr()),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _expenseDescController,
                      decoration: InputDecoration(labelText: 'expense_description'.tr(), border: const OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'no_data'.tr() : null,
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _expenseAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'amount'.tr(), border: const OutlineInputBorder()),
                      validator: (v) => v == null || double.tryParse(v) == null ? 'no_data'.tr() : null,
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      value: _expenseCategory,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      dropdownColor: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      items: const [
                        DropdownMenuItem(value: 'شراء بضاعة / Stock Purchase', child: Text('شراء بضاعة / Stock Purchase')),
                        DropdownMenuItem(value: 'فواتير ومنافع / Bills', child: Text('فواتير ومنافع / Bills')),
                        DropdownMenuItem(value: 'رواتب / Salaries', child: Text('رواتب / Salaries')),
                        DropdownMenuItem(value: 'صيانة ونظافة / Maintenance', child: Text('صيانة ونظافة / Maintenance')),
                        DropdownMenuItem(value: 'نثريات / Miscellaneous', child: Text('نثريات / Miscellaneous')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _expenseCategory = val);
                      },
                      decoration: InputDecoration(
                        labelText: 'category'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgContext),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final exp = ExpenseEntity(
                        id: '',
                        description: _expenseDescController.text,
                        amount: double.parse(_expenseAmountController.text),
                        category: _expenseCategory,
                        date: DateTime.now(),
                        shiftId: shiftId,
                      );
                      context.read<CashierBloc>().add(AddExpenseEvent(exp));
                      Navigator.pop(dlgContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                  child: Text('confirm'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleCloseShift(BuildContext context, CashierState cashierState) async {
    // 1. Gather financials from ReportsBloc
    final reportsState = context.read<ReportsBloc>().state;
    double todaySales = 0.0;
    if (reportsState is ReportsLoaded) {
      todaySales = reportsState.todaySales;
    }

    double totalExpenses = cashierState.expenses.fold(0.0, (sum, e) => sum + e.amount);
    double expectedCash = cashierState.startingCash + todaySales - totalExpenses;

    // 2. Print Z-Report
    final printService = Gravity.find<PrintService>();
    final lang = context.locale.languageCode;
    await printService.printZReport(
      context,
      startingCash: cashierState.startingCash,
      totalSales: todaySales,
      totalExpenses: totalExpenses,
      expectedCash: expectedCash,
      lang: lang,
    );

    // 3. Dispatch Close Shift Event
    if (mounted) {
      context.read<CashierBloc>().add(CloseShiftEvent(expectedCash));
    }
  }

  void _confirmDeleteExpense(BuildContext context, String id) {
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
                context.read<CashierBloc>().add(DeleteExpenseEvent(id));
                setState(() {
                  _selectedExpenseIds.remove(id);
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

  void _confirmDeleteSelectedExpenses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('confirm'.tr()),
          content: Text(
            context.locale.languageCode == 'ar'
                ? 'هل أنت متأكد من حذف ${_selectedExpenseIds.length} من المصروفات المحددة؟'
                : 'Are you sure you want to delete ${_selectedExpenseIds.length} selected expense(s)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CashierBloc>().add(DeleteMultipleExpensesEvent(_selectedExpenseIds.toList()));
                setState(() {
                  _selectedExpenseIds.clear();
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
}
