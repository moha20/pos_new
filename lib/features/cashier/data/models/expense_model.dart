import '../../domain/entities/expense_entity.dart';

class ExpenseModel {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String? shiftId;

  ExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.shiftId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'description': description,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'shiftId': shiftId,
  };

  factory ExpenseModel.fromMap(Map<dynamic, dynamic> map) => ExpenseModel(
    id: map['id'] as String,
    description: map['description'] as String,
    amount: (map['amount'] as num).toDouble(),
    category: map['category'] as String,
    date: DateTime.parse(map['date'] as String),
    shiftId: map['shiftId'] as String?,
  );

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      description: description,
      amount: amount,
      category: category,
      date: date,
      shiftId: shiftId,
    );
  }
}
