import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/cashier_repository.dart';
import '../../domain/entities/expense_entity.dart';
import '../models/expense_model.dart';

class CashierRepositoryImpl implements CashierRepository {
  final Realm realm;
  final SharedPreferences prefs;

  CashierRepositoryImpl(this.realm, this.prefs);

  ObjectId _parseId(String idStr) {
    try {
      return ObjectId.fromHexString(idStr);
    } catch (_) {
      return ObjectId();
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpenses() async {
    return realm.all<Expense>().map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    realm.write(() {
      realm.add(Expense(
        ObjectId(),
        expense.description,
        expense.amount,
        expense.category,
        expense.date,
        shiftId: expense.shiftId,
      ));
    });
  }

  @override
  Future<void> deleteExpense(String id) async {
    final dbExp = realm.find<Expense>(_parseId(id));
    if (dbExp != null) {
      realm.write(() {
        realm.delete(dbExp);
      });
    }
  }

  @override
  Future<void> openShift(double startingCash) async {
    final shiftId = ObjectId().toString();
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
