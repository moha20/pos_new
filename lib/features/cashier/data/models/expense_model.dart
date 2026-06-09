import 'package:realm/realm.dart';
import '../../domain/entities/expense_entity.dart';

part 'expense_model.realm.dart';

@RealmModel()
class _Expense {
  @PrimaryKey()
  late ObjectId id;
  late String description;
  late double amount;
  late String category;
  late DateTime date;
  late String? shiftId;
}

extension ExpenseMapper on Expense {
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id.toString(),
      description: description,
      amount: amount,
      category: category,
      date: date,
      shiftId: shiftId,
    );
  }
}
