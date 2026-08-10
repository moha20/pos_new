import '../entities/expense_entity.dart';

abstract class CashierRepository {
  Future<List<ExpenseEntity>> getExpenses();
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String id);

  // Shift management
  Future<void> openShift(double startingCash);
  Future<void> closeShift(double endingCash);
  Future<bool> isShiftOpen();
  Future<double> getStartingCash();
  Future<String?> getActiveShiftId();
}
