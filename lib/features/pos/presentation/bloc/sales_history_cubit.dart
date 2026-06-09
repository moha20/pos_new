import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sale_repository.dart';

abstract class SalesHistoryState {}

class SalesHistoryInitial extends SalesHistoryState {}

class SalesHistoryLoading extends SalesHistoryState {}

class SalesHistoryLoaded extends SalesHistoryState {
  final List<SaleEntity> allSales;
  final List<SaleEntity> filteredSales;
  final double totalSalesAmount;
  final double totalPaidAmount;
  final double totalRemainingAmount;

  SalesHistoryLoaded({
    required this.allSales,
    required this.filteredSales,
    required this.totalSalesAmount,
    required this.totalPaidAmount,
    required this.totalRemainingAmount,
  });

  SalesHistoryLoaded copyWith({
    List<SaleEntity>? allSales,
    List<SaleEntity>? filteredSales,
    double? totalSalesAmount,
    double? totalPaidAmount,
    double? totalRemainingAmount,
  }) {
    return SalesHistoryLoaded(
      allSales: allSales ?? this.allSales,
      filteredSales: filteredSales ?? this.filteredSales,
      totalSalesAmount: totalSalesAmount ?? this.totalSalesAmount,
      totalPaidAmount: totalPaidAmount ?? this.totalPaidAmount,
      totalRemainingAmount: totalRemainingAmount ?? this.totalRemainingAmount,
    );
  }
}

class SalesHistoryError extends SalesHistoryState {
  final String message;
  SalesHistoryError(this.message);
}

class SalesHistoryCubit extends Cubit<SalesHistoryState> {
  final SaleRepository saleRepository;

  SalesHistoryCubit(this.saleRepository) : super(SalesHistoryInitial());

  Future<void> loadSales() async {
    emit(SalesHistoryLoading());
    try {
      final sales = await saleRepository.getSales();
      // Sort sales by date descending
      sales.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      double totalSales = 0;
      double totalPaid = 0;
      double totalRemaining = 0;

      for (final s in sales) {
        totalSales += s.total;
        totalPaid += s.amountPaid;
        totalRemaining += s.amountRemaining;
      }

      emit(SalesHistoryLoaded(
        allSales: sales,
        filteredSales: sales,
        totalSalesAmount: totalSales,
        totalPaidAmount: totalPaid,
        totalRemainingAmount: totalRemaining,
      ));
    } catch (e) {
      emit(SalesHistoryError(e.toString()));
    }
  }

  void searchSales(String query) {
    if (state is SalesHistoryLoaded) {
      final sState = state as SalesHistoryLoaded;
      if (query.isEmpty) {
        emit(sState.copyWith(filteredSales: sState.allSales));
        return;
      }

      final filtered = sState.allSales.where((s) {
        final invoiceMatch = s.invoiceNumber.toLowerCase().contains(query.toLowerCase());
        final customerMatch = s.customerId != null &&
            s.customerId!.toLowerCase().contains(query.toLowerCase());
        final noteMatch = s.note != null && s.note!.toLowerCase().contains(query.toLowerCase());
        final methodMatch = s.paymentMethod.toLowerCase().contains(query.toLowerCase());
        return invoiceMatch || customerMatch || noteMatch || methodMatch;
      }).toList();

      emit(sState.copyWith(filteredSales: filtered));
    }
  }
}
