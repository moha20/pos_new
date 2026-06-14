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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;

    return ResponsiveLayout(
      title: 'reports'.tr(),
      child: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportsLoaded) {
            // Render KPI cards
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // KPI cards grid
                  GridView.count(
                    crossAxisCount: screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1),
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
                  MediaQuery.of(context).size.width > 900
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildBarChart(state, theme, isArabic)),
                            SizedBox(width: 16.w),
                            Expanded(flex: 2, child: _buildPieChart(state, theme, isArabic)),
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
          if (state is ReportsError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('no_data'.tr()));
        },
      ),
    );
  }

  Widget _buildBarChart(ReportsLoaded state, ThemeData theme, bool isArabic) {
    final history = state.dailySalesHistory.entries.toList();
    // Grab last 7 days sorted by date
    history.sort((a, b) => a.key.compareTo(b.key));
    final displayHistory = history.length > 7 ? history.sublist(history.length - 7) : history;

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
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                                    return Text('${parts[2]}/${parts[1]}', style: TextStyle(fontSize: 9.sp));
                                  }
                                  return Text(dateStr, style: TextStyle(fontSize: 9.sp));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(displayHistory.length, (index) {
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
        if (level == 'retail') title = 'price_retail'.tr();
        else if (level == 'salesman') title = 'price_salesman'.tr();
        else if (level == 'company') title = 'price_company'.tr();
        else if (level == 'wholesale') title = 'price_wholesale'.tr();

        sections.add(
          PieChartSectionData(
            value: value,
            title: title,
            color: colors[colorIdx % colors.length],
            radius: 55,
            titleStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white),
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
}
