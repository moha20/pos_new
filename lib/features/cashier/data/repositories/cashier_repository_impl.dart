import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/cashier_repository.dart';
import '../../domain/entities/expense_entity.dart';
import '../models/expense_model.dart';
import '../../../../core/db/hive_config.dart';

class CashierRepositoryImpl implements CashierRepository {
  final Box _box;
  final SharedPreferences prefs;

  CashierRepositoryImpl(this._box, this.prefs);

  @override
  Future<List<ExpenseEntity>> getExpenses() async {
    return _box.values
        .map((v) => ExpenseModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    final id = generateId();
    final model = ExpenseModel(
      id: id,
      description: expense.description,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      shiftId: expense.shiftId,
    );
    await _box.put(id, model.toMap());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> openShift(double startingCash) async {
    final shiftId = generateId();
    await prefs.setBool('is_shift_open', true);
    await prefs.setDouble('starting_cash', startingCash);
    await prefs.setString('active_shift_id', shiftId);
  }

  @override
  Future<void> closeShift(double endingCash) async {
    await prefs.setBool('is_shift_open', false);
    await prefs.remove('starting_cash');
    await prefs.remove('active_shift_id');
  }

  @override
  Future<bool> isShiftOpen() async {
    return prefs.getBool('is_shift_open') ?? false;
  }

  @override
  Future<double> getStartingCash() async {
    return prefs.getDouble('starting_cash') ?? 0.0;
  }

  @override
  Future<String?> getActiveShiftId() async {
    return prefs.getString('active_shift_id');
  }
}
