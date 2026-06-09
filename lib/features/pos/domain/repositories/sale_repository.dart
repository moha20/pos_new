import '../entities/sale_entity.dart';

abstract class SaleRepository {
  Future<List<SaleEntity>> getSales();
  Future<List<SaleEntity>> getSalesForRange(DateTime start, DateTime end);
  Future<void> saveSale(SaleEntity sale);
  Future<int> getNextInvoiceNumber();
}
