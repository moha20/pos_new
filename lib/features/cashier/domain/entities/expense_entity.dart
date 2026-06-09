class ExpenseEntity {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String? shiftId;

  ExpenseEntity({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.shiftId,
  });
}
