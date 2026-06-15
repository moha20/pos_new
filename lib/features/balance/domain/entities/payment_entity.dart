class PaymentEntity {
  final String id;
  final String type; // 'customer' | 'supplier'
  final String targetId;
  final String targetName;
  final double amount;
  final String paymentMethod; // 'cash' | 'card' | 'wallet'
  final String? note;
  final DateTime createdAt;
  final String createdBy;

  PaymentEntity({
    required this.id,
    required this.type,
    required this.targetId,
    required this.targetName,
    required this.amount,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.createdBy,
  });
}
