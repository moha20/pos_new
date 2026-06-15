import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/reports_bloc.dart';
import '../../../../widgets/stat_card.dart';
import '../../../../widgets/responsive_layout.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(LoadReportsEvent());
  }

  String getLocalizedCategory(String dbCategory) {
    if (dbCategory.contains('Stock Purchase') || dbCategory.contains('شراء بضاعة')) {
      return 'expense_stock_purchase'.tr();
    }
    if (dbCategory.contains('Bills') || dbCategory.contains('فواتير ومنافع')) {
      return 'expense_bills'.tr();
    }
    if (dbCategory.contains('Salaries') || dbCategory.contains('رواتب')) {
      return 'expense_salaries'.tr();
    }
    if (dbCategory.contains('Maintenance') || dbCategory.contains('صيانة ونظافة')) {
      return 'expense_maintenance'.tr();
    }
    if (dbCategory.contains('Miscellaneous') || dbCategory.contains('نثريات')) {
      return 'expense_miscellaneous'.tr();
    }
    return dbCategory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: ResponsiveLayout(
        title: 'reports'.tr(),
        child: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            if (state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ReportsLoaded) {
              return Column(
                children: [
                  // TabBar
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
                        indicatorSize: TabBarIndicatorSize.tab,
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
                                const Icon(Icons.bar_chart, size: 18),
                                SizedBox(width: 6.w),
                                Text('sales_report'.tr()),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.trending_down, size: 18),
                                SizedBox(width: 6.w),
                                Text('expenses_profit'.tr()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSalesTab(state, theme, isArabic, screenWidth),
                        _buildExpensesTab(state, theme, isArabic, screenWidth),
                      ],
                    ),
                  ),
                ],
              );
            }
            if (state is ReportsError) {
              return Center(child: Text(state.message));
            }
            return Center(child: Text('no_data'.tr()));
          },
        ),
      ),
    );
  }

  Widget _buildSalesTab(ReportsLoaded state, ThemeData theme, bool isArabic, double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPI cards grid
          GridView.count(
            crossAxisCount: screenWidth > 900
                ? 3
                : (screenWidth > 600 ? 2 : 1),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: screenWidth > 600 ? 2.2 : 3.2,
            children: [
              StatCard(
                title: 'today_sales'.tr(),
                value: '${state.todaySales.toStringAsFixed(2)} EGP',
                icon: Icons.today,
                color: Colors.teal,
              ),
              StatCard(
                title: 'this_week'.tr(),
                value: '${state.weeklySales.toStringAsFixed(2)} EGP',
                icon: Icons.date_range,
                color: Colors.indigo,
              ),
              StatCard(
                title: 'this_month'.tr(),
                value: '${state.monthlySales.toStringAsFixed(2)} EGP',
                icon: Icons.calendar_month,
                color: Colors.amber[800]!,
              ),
              StatCard(
                title: 'revenue'.tr(),
                value: '${state.totalRevenue.toStringAsFixed(2)} EGP',
                icon: Icons.monetization_on,
                color: Colors.green,
              ),
              StatCard(
                title: 'invoices_count'.tr(),
                value: '${state.invoicesCount}',
                icon: Icons.receipt_long,
                color: Colors.purple,
              ),
              StatCard(
                title: 'avg_sale'.tr(),
                value: '${state.avgSale.toStringAsFixed(2)} EGP',
                icon: Icons.analytics,
                color: Colors.blue,
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Charts Layout
          screenWidth > 900
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildBarChart(state, theme, isArabic),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 2,
                      child: _buildPieChart(state, theme, isArabic),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildBarChart(state, theme, isArabic),
                    SizedBox(height: 16.h),
                    _buildPieChart(state, theme, isArabic),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(ReportsLoaded state, ThemeData theme, bool isArabic, double screenWidth) {
    final netProfit = state.totalRevenue - state.totalExpenses;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPI cards grid for Expenses & Profit
          GridView.count(
            crossAxisCount: screenWidth > 900
                ? 3
                : (screenWidth > 600 ? 2 : 1),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: screenWidth > 600 ? 2.2 : 3.2,
            children: [
              StatCard(
                title: 'today_expenses'.tr(),
                value: '${state.todayExpenses.toStringAsFixed(2)} EGP',
                icon: Icons.money_off,
                color: Colors.pink[400]!,
              ),
              StatCard(
                title: 'this_week_expenses'.tr(),
                value: '${state.weeklyExpenses.toStringAsFixed(2)} EGP',
                icon: Icons.date_range,
                color: Colors.deepOrange,
              ),
              StatCard(
                title: 'this_month_expenses'.tr(),
                value: '${state.monthlyExpenses.toStringAsFixed(2)} EGP',
                icon: Icons.calendar_month,
                color: Colors.amber[800]!,
              ),
              StatCard(
                title: 'total_expenses'.tr().replaceAll(':', ''),
                value: '${state.totalExpenses.toStringAsFixed(2)} EGP',
                icon: Icons.trending_down,
                color: Colors.red[700]!,
              ),
              StatCard(
                title: 'net_profit'.tr(),
                value: '${netProfit.toStringAsFixed(2)} EGP',
                icon: Icons.account_balance,
                color: netProfit >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Visualizations
          screenWidth > 900
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildExpensePieChart(state, theme, isArabic),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 1,
                      child: _buildExpenseList(state, theme, isArabic),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildExpensePieChart(state, theme, isArabic),
                    SizedBox(height: 16.h),
                    _buildExpenseList(state, theme, isArabic),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ReportsLoaded state, ThemeData theme, bool isArabic) {
    final history = state.dailySalesHistory.entries.toList();
    // Grab last 7 days sorted by date
    history.sort((a, b) => a.key.compareTo(b.key));
    final displayHistory = history.length > 7
        ? history.sublist(history.length - 7)
        : history;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'today_sales'.tr()} / ${'sales_timeline'.tr()}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 220.h,
              child: displayHistory.isEmpty
                  ? Center(child: Text('no_data'.tr()))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: const BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double val, TitleMeta meta) {
                                final idx = val.toInt();
                                if (idx >= 0 && idx < displayHistory.length) {
                                  // Format date key to show day/month
                                  final dateStr = displayHistory[idx].key;
                                  final parts = dateStr.split('-');
                                  if (parts.length >= 3) {
                                    return Text(
                                      '${parts[2]}/${parts[1]}',
                                      style: TextStyle(fontSize: 9.sp),
                                    );
                                  }
                                  return Text(
                                    dateStr,
                                    style: TextStyle(fontSize: 9.sp),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(displayHistory.length, (
                          index,
                        ) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: displayHistory[index].value,
                                color: theme.colorScheme.primary,
                                width: 16.w,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(ReportsLoaded state, ThemeData theme, bool isArabic) {
    final total = state.tierSplit.values.fold(0.0, (sum, val) => sum + val);

    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.teal,
      Colors.purple,
      Colors.red,
      Colors.indigo,
      Colors.amber,
      Colors.pink,
    ];

    int colorIdx = 0;
    state.tierSplit.forEach((level, value) {
      if (value > 0) {
        String title = level;
        if (level == 'retail') {
          title = 'price_retail'.tr();
        } else if (level == 'salesman')
          title = 'price_salesman'.tr();
        else if (level == 'company')
          title = 'price_company'.tr();
        else if (level == 'wholesale')
          title = 'price_wholesale'.tr();

        sections.add(
          PieChartSectionData(
            value: value,
            title: title,
            color: colors[colorIdx % colors.length],
            radius: 55,
            titleStyle: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        colorIdx++;
      }
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'price_tier'.tr()} / ${'sales_split_by_tier'.tr()}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 220.h,
              child: total <= 0
                  ? Center(child: Text('no_data'.tr()))
                  : PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensePieChart(ReportsLoaded state, ThemeData theme, bool isArabic) {
    final total = state.expenseCategorySplit.values.fold(0.0, (sum, val) => sum + val);

    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.red[400]!,
      Colors.blue[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.teal[400]!,
    ];

    int colorIdx = 0;
    state.expenseCategorySplit.forEach((category, value) {
      if (value > 0) {
        String title = getLocalizedCategory(category);
        sections.add(
          PieChartSectionData(
            value: value,
            title: title,
            color: colors[colorIdx % colors.length],
            radius: 55,
            titleStyle: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        colorIdx++;
      }
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'expense_breakdown'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 220.h,
              child: total <= 0
                  ? Center(child: Text('no_expenses_recorded'.tr()))
                  : PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList(ReportsLoaded state, ThemeData theme, bool isArabic) {
    final total = state.expenseCategorySplit.values.fold(0.0, (sum, val) => sum + val);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'expenses'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            if (total <= 0)
              SizedBox(
                height: 228.h,
                child: Center(
                  child: Text('no_expenses_recorded'.tr()),
                ),
              )
            else
              SizedBox(
                height: 228.h,
                child: ListView(
                  shrinkWrap: true,
                  children: state.expenseCategorySplit.entries
                      .where((entry) => entry.value > 0)
                      .map((entry) {
                    final categoryName = getLocalizedCategory(entry.key);
                    final amount = entry.value;
                    final percent = (amount / total) * 100;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categoryName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                              Text(
                                '${amount.toStringAsFixed(2)} EGP (${percent.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[600],
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          LinearProgressIndicator(
                            value: amount / total,
                            backgroundColor: theme.dividerColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
                            minHeight: 6.h,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
