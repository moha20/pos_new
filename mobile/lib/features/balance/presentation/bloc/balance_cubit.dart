import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../../../../core/di/di.dart';
import '../../../../services/activity_log_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../suppliers/presentation/bloc/supplier_bloc.dart';

// State
class BalanceState {
  final List<PaymentEntity> allPayments;
  final String filterType; // 'all' | 'customer' | 'supplier'
  final bool isLoading;
  final String? errorMessage;

  BalanceState({
    required this.allPayments,
    required this.filterType,
    required this.isLoading,
    this.errorMessage,
  });

  BalanceState copyWith({
    List<PaymentEntity>? allPayments,
    String? filterType,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BalanceState(
      allPayments: allPayments ?? this.allPayments,
      filterType: filterType ?? this.filterType,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<PaymentEntity> get filteredPayments {
    if (filterType == 'all') return allPayments;
    return allPayments.where((p) => p.type == filterType).toList();
  }
}

// Cubit
class BalanceCubit extends Cubit<BalanceState> {
  final PaymentRepository paymentRepository;
  final CustomerRepository customerRepository;
  final SupplierRepository supplierRepository;

  BalanceCubit({
    required this.paymentRepository,
    required this.customerRepository,
    required this.supplierRepository,
  }) : super(BalanceState(
          allPayments: [],
          filterType: 'all',
          isLoading: false,
        ));

  Future<void> loadPayments() async {
    emit(state.copyWith(isLoading: true));
    try {
      final payments = await paymentRepository.getPayments();
      payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(allPayments: payments, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void filterByType(String type) {
    emit(state.copyWith(filterType: type));
  }

  Future<void> addPayment(PaymentEntity payment) async {
    emit(state.copyWith(isLoading: true));
    try {
      await paymentRepository.addPayment(payment);

      // Update the target's balance (reduce by payment amount)
      if (payment.type == 'customer') {
        await customerRepository.updatePurchases(
          payment.targetId,
          0, // no new sale amount
          -payment.amount, // negative to reduce balance
        );
        // Reload customer bloc
        try {
          Gravity.find<CustomerBloc>().add(LoadCustomers());
        } catch (_) {}
      } else if (payment.type == 'supplier') {
        await supplierRepository.updateOrders(
          payment.targetId,
          0, // no new order amount
          -payment.amount, // negative to reduce balance
        );
        // Reload supplier bloc
        try {
          Gravity.find<SupplierBloc>().add(LoadSuppliers());
        } catch (_) {}
      }

      // Log activity
      try {
        final user = Gravity.find<AuthBloc>().currentUser;
        Gravity.find<ActivityLogService>().log(
          action: 'balance_payment',
          category: payment.type,
          description:
              'Payment of ${payment.amount.toStringAsFixed(2)} EGP to ${payment.type}: ${payment.targetName} via ${payment.paymentMethod}',
          userId: user?.username ?? payment.createdBy,
          referenceId: payment.targetId,
        );
      } catch (_) {}

      await loadPayments();
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
