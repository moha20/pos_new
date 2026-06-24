import '../entities/supplier_invoice_entity.dart';

abstract class SupplierInvoiceRepository {
  Future<List<SupplierInvoiceEntity>> getSupplierInvoices();
  Future<void> saveSupplierInvoice(SupplierInvoiceEntity invoice);
  Future<int> getNextInvoiceNumber();
}
