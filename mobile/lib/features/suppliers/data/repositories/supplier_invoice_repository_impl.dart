import 'package:hive/hive.dart';
import '../../domain/repositories/supplier_invoice_repository.dart';
import '../../domain/entities/supplier_invoice_entity.dart';
import '../models/supplier_invoice_model.dart';
import '../../../inventory/data/models/product_model.dart';
import '../models/supplier_model.dart';
import '../../../../core/db/hive_config.dart';

class SupplierInvoiceRepositoryImpl implements SupplierInvoiceRepository {
  final Box _invoicesBox;
  final Box _productsBox;
  final Box _suppliersBox;

  SupplierInvoiceRepositoryImpl(
    this._invoicesBox,
    this._productsBox,
    this._suppliersBox,
  );

  @override
  Future<List<SupplierInvoiceEntity>> getSupplierInvoices() async {
    return _invoicesBox.values
        .map((v) => SupplierInvoiceModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<void> saveSupplierInvoice(SupplierInvoiceEntity invoice) async {
    final id = generateId();

    // 1. Create Invoice Item models
    final dbItems = invoice.items.map((i) => SupplierInvoiceItemModel(
      productId: i.productId,
      productName: i.productName,
      barcode: i.barcode,
      qty: i.qty,
      unitCostPrice: i.unitCostPrice,
      totalPrice: i.totalPrice,
    )).toList();

    // 2. Add Invoice record
    final model = SupplierInvoiceModel(
      id: id,
      invoiceNumber: invoice.invoiceNumber,
      createdAt: invoice.createdAt,
      items: dbItems,
      subtotal: invoice.subtotal,
      discount: invoice.discount,
      tax: invoice.tax,
      total: invoice.total,
      paymentMethod: invoice.paymentMethod,
      supplierId: invoice.supplierId,
      cashierId: invoice.cashierId,
      note: invoice.note,
      amountPaid: invoice.amountPaid,
      amountRemaining: invoice.amountRemaining,
    );
    await _invoicesBox.put(id, model.toMap());

    // 3. Increment stock levels and update costPrice for each product
    for (final item in invoice.items) {
      try {
        final prodData = _productsBox.get(item.productId);
        if (prodData != null) {
          final product = ProductModel.fromMap(prodData as Map<dynamic, dynamic>);
          final updated = ProductModel(
            id: product.id,
            name: product.name,
            barcode: product.barcode,
            category: product.category,
            brand: product.brand,
            costPrice: item.unitCostPrice, // Update cost price to the new purchase price
            stock: product.stock + item.qty, // Increase stock
            minStock: product.minStock,
            unit: product.unit,
            isActive: product.isActive,
            imagePath: product.imagePath,
            prices: product.prices,
          );
          await _productsBox.put(item.productId, updated.toMap());
        }
      } catch (_) {}
    }

    // 4. Update Supplier total orders and balance
    try {
      final suppData = _suppliersBox.get(invoice.supplierId);
      if (suppData != null) {
        final supplier = SupplierModel.fromMap(suppData as Map<dynamic, dynamic>);
        final updatedSupplier = SupplierModel(
          id: supplier.id,
          name: supplier.name,
          phone: supplier.phone,
          company: supplier.company,
          totalOrders: supplier.totalOrders + invoice.total,
          balance: supplier.balance + invoice.amountRemaining,
        );
        await _suppliersBox.put(invoice.supplierId, updatedSupplier.toMap());
      }
    } catch (_) {}
  }

  @override
  Future<int> getNextInvoiceNumber() async {
    final count = _invoicesBox.length;
    return count + 5001; // Starting purchase invoice offset
  }
}
