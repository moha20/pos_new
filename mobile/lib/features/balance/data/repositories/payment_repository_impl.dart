import 'package:hive/hive.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/entities/payment_entity.dart';
import '../models/payment_model.dart';
import '../../../../core/db/hive_config.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final Box _box;

  PaymentRepositoryImpl(this._box);

  @override
  Future<List<PaymentEntity>> getPayments() async {
    return _box.values
        .map((v) => PaymentModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<void> addPayment(PaymentEntity payment) async {
    final id = generateId();
    final model = PaymentModel(
      id: id,
      type: payment.type,
      targetId: payment.targetId,
      targetName: payment.targetName,
      amount: payment.amount,
      paymentMethod: payment.paymentMethod,
      note: payment.note,
      createdAt: payment.createdAt,
      createdBy: payment.createdBy,
    );
    await _box.put(id, model.toMap());
  }

  @override
  Future<List<PaymentEntity>> getPaymentsByTarget(String type, String targetId) async {
    return _box.values
        .map((v) => PaymentModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .where((p) => p.type == type && p.targetId == targetId)
        .toList();
  }
}
