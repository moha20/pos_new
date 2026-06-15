import '../../domain/entities/payment_entity.dart';

class PaymentModel {
  final String id;
  final String type;
  final String targetId;
  final String targetName;
  final double amount;
  final String paymentMethod;
  final String? note;
  final DateTime createdAt;
  final String createdBy;

  PaymentModel({
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'targetId': targetId,
    'targetName': targetName,
    'amount': amount,
    'paymentMethod': paymentMethod,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };

  factory PaymentModel.fromMap(Map<dynamic, dynamic> map) => PaymentModel(
    id: map['id'] as String,
    type: map['type'] as String,
    targetId: map['targetId'] as String,
    targetName: map['targetName'] as String,
    amount: (map['amount'] as num).toDouble(),
    paymentMethod: map['paymentMethod'] as String,
    note: map['note'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String),
    createdBy: map['createdBy'] as String,
  );

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      type: type,
      targetId: targetId,
      targetName: targetName,
      amount: amount,
      paymentMethod: paymentMethod,
      note: note,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
