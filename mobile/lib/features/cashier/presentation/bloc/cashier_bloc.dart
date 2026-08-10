import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/cashier_repository.dart';
import '../../../../core/di/di.dart';
import '../../../../services/activity_log_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

enum CashierStatus { initial, loading, loaded, error }

// State
class CashierState {
  final bool isShiftOpen;
  final double startingCash;
  final String? activeShiftId;
  final List<ExpenseEntity> expenses;
  final CashierStatus status;
  final String? message;

  CashierState({
    required this.isShiftOpen,
    required this.startingCash,
    this.activeShiftId,
    required this.expenses,
    required this.status,
    this.message,
  });

  CashierState copyWith({
    bool? isShiftOpen,
    double? startingCash,
    String? Function()? activeShiftId,
    List<ExpenseEntity>? expenses,
    CashierStatus? status,
    String? message,
  }) {
    return CashierState(
      isShiftOpen: isShiftOpen ?? this.isShiftOpen,
      startingCash: startingCash ?? this.startingCash,
      activeShiftId: activeShiftId != null ? activeShiftId() : this.activeShiftId,
      expenses: expenses ?? this.expenses,
      status: status ?? this.status,
      message: message,
    );
  }
}

// Events
abstract class CashierEvent {}

class LoadCashier extends CashierEvent {}

class OpenShiftEvent extends CashierEvent {
  final double startingCash;
  OpenShiftEvent(this.startingCash);
}

class CloseShiftEvent extends CashierEvent {
  final double endingCash;
  CloseShiftEvent(this.endingCash);
}

class AddExpenseEvent extends CashierEvent {
  final ExpenseEntity expense;
  AddExpenseEvent(this.expense);
}

class DeleteExpenseEvent extends CashierEvent {
  final String id;
  DeleteExpenseEvent(this.id);
}

class DeleteMultipleExpensesEvent extends CashierEvent {
  final List<String> ids;
  DeleteMultipleExpensesEvent(this.ids);
}

// Bloc
class CashierBloc extends Bloc<CashierEvent, CashierState> {
  final CashierRepository cashierRepository;

  CashierBloc(this.cashierRepository) : super(CashierState(
          isShiftOpen: false,
          startingCash: 0.0,
          expenses: [],
          status: CashierStatus.initial,
        )) {
    on<LoadCashier>((event, emit) async {
      emit(state.copyWith(status: CashierStatus.loading));
      try {
        final isOpen = await cashierRepository.isShiftOpen();
        final startingCash = await cashierRepository.getStartingCash();
        final shiftId = await cashierRepository.getActiveShiftId();
        final expenses = await cashierRepository.getExpenses();

        emit(CashierState(
          isShiftOpen: isOpen,
          startingCash: startingCash,
          activeShiftId: shiftId,
          expenses: expenses,
          status: CashierStatus.loaded,
        ));
      } catch (e) {
        emit(state.copyWith(status: CashierStatus.error, message: e.toString()));
      }
    });

    on<OpenShiftEvent>((event, emit) async {
      emit(state.copyWith(status: CashierStatus.loading));
      try {
        await cashierRepository.openShift(event.startingCash);
        add(LoadCashier());
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'shift_opened',
            category: 'cashier',
            description: 'Opened shift with starting cash: ${event.startingCash.toStringAsFixed(2)} EGP',
            userId: user?.username ?? 'system',
          );
        } catch (_) {}
      } catch (e) {
        emit(state.copyWith(status: CashierStatus.error, message: e.toString()));
      }
    });

    on<CloseShiftEvent>((event, emit) async {
      emit(state.copyWith(status: CashierStatus.loading));
      try {
        await cashierRepository.closeShift(event.endingCash);
        add(LoadCashier());
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'shift_closed',
            category: 'cashier',
            description: 'Closed shift with ending cash: ${event.endingCash.toStringAsFixed(2)} EGP',
            userId: user?.username ?? 'system',
          );
        } catch (_) {}
      } catch (e) {
        emit(state.copyWith(status: CashierStatus.error, message: e.toString()));
      }
    });

    on<AddExpenseEvent>((event, emit) async {
      emit(state.copyWith(status: CashierStatus.loading));
      try {
        await cashierRepository.addExpense(event.expense);
        add(LoadCashier());
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'expense_added',
            category: 'cashier',
            description: 'Added expense: ${event.expense.description} (${event.expense.amount.toStringAsFixed(2)} EGP)',
            userId: user?.username ?? 'system',
            referenceId: event.expense.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(state.copyWith(status: CashierStatus.error, message: e.toString()));
      }
    });

    on<DeleteExpenseEvent>((event, emit) async {
      emit(state.copyWith(status: CashierStatus.loading));
      try {
        String expenseReason = event.id;
        try {
          final existing = state.expenses.firstWhere((exp) => exp.id == event.id);
          expenseReason = '${existing.description} (${existing.amount.toStringAsFixed(2)} EGP)';
        } catch (_) {}
        await cashierRepository.deleteExpense(event.id);
        add(LoadCashier());
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'expense_deleted',
            category: 'cashier',
            description: 'Deleted expense: $expenseReason',
            userId: user?.username ?? 'system',
            referenceId: event.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(state.copyWith(status: CashierStatus.error, message: e.toString()));
      }
    });

    on<DeleteMultipleExpensesEvent>((event, emit) async {
      emit(state.copyWith(status: CashierStatus.loading));
      try {
        final List<String> deletedDetails = [];
        for (final id in event.ids) {
          try {
            final existing = state.expenses.firstWhere((exp) => exp.id == id);
            deletedDetails.add('${existing.description} (${existing.amount.toStringAsFixed(2)} EGP)');
          } catch (_) {
            deletedDetails.add(id);
          }
          await cashierRepository.deleteExpense(id);
        }
        add(LoadCashier());
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'expense_deleted',
            category: 'cashier',
            description: 'Deleted expenses: ${deletedDetails.join(", ")}',
            userId: user?.username ?? 'system',
            referenceId: event.ids.join(","),
          );
        } catch (_) {}
      } catch (e) {
        emit(state.copyWith(status: CashierStatus.error, message: e.toString()));
      }
    });
  }
}
