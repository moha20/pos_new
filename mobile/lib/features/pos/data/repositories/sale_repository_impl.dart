import 'package:hive/hive.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/entities/sale_entity.dart';
import '../models/sale_model.dart';
import '../../../inventory/data/models/product_model.dart';
import '../../../../core/db/hive_config.dart';

class SaleRepositoryImpl implements SaleRepository {
  final Box _salesBox;
  final Box _productsBox;

  SaleRepositoryImpl(this._salesBox, this._productsBox);

  @override
  Future<List<SaleEntity>> getSales() async {
    return _salesBox.values
        .map((v) => SaleModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<SaleEntity>> getSalesForRange(DateTime start, DateTime end) async {
    return _salesBox.values
        .map((v) => SaleModel.fromMap(v as Map<dynamic, dynamic>))
        .where((s) => !s.createdAt.isBefore(start) && !s.createdAt.isAfter(end))
        .map((s) => s.toEntity())
        .toList();
  }

  @override
  Future<void> saveSale(SaleEntity sale) async {
    final id = generateId();

    // 1. Create Sale Item models
    final dbItems = sale.items.map((i) => SaleItemModel(
      productId: i.productId,
      productName: i.productName,
      barcode: i.barcode,
      qty: i.qty,
      unitPrice: i.unitPrice,
      totalPrice: i.totalPrice,
      priceLevel: i.priceLevel,
    )).toList();

    // 2. Add Sale record
    final model = SaleModel(
      id: id,
      invoiceNumber: sale.invoiceNumber,
      createdAt: sale.createdAt,
      items: dbItems,
      subtotal: sale.subtotal,
      discount: sale.discount,
      tax: sale.tax,
      total: sale.total,
      paymentMethod: sale.paymentMethod,
      customerId: sale.customerId,
      cashierId: sale.cashierId,
      note: sale.note,
      amountPaid: sale.amountPaid,
      amountRemaining: sale.amountRemaining,
    );
    await _salesBox.put(id, model.toMap());

    // 3. Deduct stock levels for each sold product
    for (final item in sale.items) {
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
            costPrice: product.costPrice,
            stock: product.stock - item.qty,
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
  }

  @override
  Future<int> getNextInvoiceNumber() async {
    final count = _salesBox.length;
    return count + 1001; // Starting invoice offset
  }
}
