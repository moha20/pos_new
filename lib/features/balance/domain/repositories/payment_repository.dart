import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentEntity>> getPayments();
  Future<void> addPayment(PaymentEntity payment);
  Future<List<PaymentEntity>> getPaymentsByTarget(String type, String targetId);
}
