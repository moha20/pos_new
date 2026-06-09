import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../pos/domain/repositories/sale_repository.dart';

// Events
abstract class ReportsEvent {}

class LoadReportsEvent extends ReportsEvent {}

// State
abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final double todaySales;
  final double weeklySales;
  final double monthlySales;
  final double totalRevenue;
  final int invoicesCount;
  final double avgSale;
  final Map<String, double> tierSplit; // 'retail', 'salesman', 'company', 'wholesale' -> double
  final Map<String, double> dailySalesHistory; // 'YYYY-MM-DD' -> double

  ReportsLoaded({
    required this.todaySales,
    required this.weeklySales,
    required this.monthlySales,
    required this.totalRevenue,
    required this.invoicesCount,
    required this.avgSale,
    required this.tierSplit,
    required this.dailySalesHistory,
  });
}

class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}

// Bloc
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final SaleRepository saleRepository;

  ReportsBloc(this.saleRepository) : super(ReportsInitial()) {
    on<LoadReportsEvent>((event, emit) async {
      emit(ReportsLoading());
      try {
        final sales = await saleRepository.getSales();
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final weekAgo = todayStart.subtract(const Duration(days: 7));
        final monthAgo = todayStart.subtract(const Duration(days: 30));

        double todaySales = 0.0;
        double weeklySales = 0.0;
        double monthlySales = 0.0;
        double totalRevenue = 0.0;
        int invoicesCount = sales.length;

        final Map<String, double> tierSplit = {
          'retail': 0.0,
          'salesman': 0.0,
          'company': 0.0,
          'wholesale': 0.0,
        };

        final Map<String, double> dailySalesHistory = {};

        for (final sale in sales) {
          totalRevenue += sale.total;
          
          if (sale.createdAt.isAfter(todayStart)) {
            todaySales += sale.total;
          }
          if (sale.createdAt.isAfter(weekAgo)) {
            weeklySales += sale.total;
          }
          if (sale.createdAt.isAfter(monthAgo)) {
            monthlySales += sale.total;
          }

          // Accumulate daily history (last 7 days for the chart)
          final dateKey = DateFormat('yyyy-MM-dd').format(sale.createdAt);
          dailySalesHistory[dateKey] = (dailySalesHistory[dateKey] ?? 0.0) + sale.total;

          // Accumulate price tier split
          for (final item in sale.items) {
            final level = item.priceLevel.isEmpty ? 'retail' : item.priceLevel;
            tierSplit[level] = (tierSplit[level] ?? 0.0) + item.totalPrice;
          }
        }

        double avgSale = invoicesCount > 0 ? totalRevenue / invoicesCount : 0.0;

        emit(ReportsLoaded(
          todaySales: todaySales,
          weeklySales: weeklySales,
          monthlySales: monthlySales,
          totalRevenue: totalRevenue,
          invoicesCount: invoicesCount,
          avgSale: avgSale,
          tierSplit: tierSplit,
          dailySalesHistory: dailySalesHistory,
        ));
      } catch (e) {
        emit(ReportsError(e.toString()));
      }
    });
  }
}
