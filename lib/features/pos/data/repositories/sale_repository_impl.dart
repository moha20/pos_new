import 'package:realm/realm.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/entities/sale_entity.dart';
import '../models/sale_model.dart';
import '../../../inventory/data/models/product_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  final Realm realm;

  SaleRepositoryImpl(this.realm);

  @override
  Future<List<SaleEntity>> getSales() async {
    return realm.all<Sale>().map((s) => s.toEntity()).toList();
  }

  @override
  Future<List<SaleEntity>> getSalesForRange(DateTime start, DateTime end) async {
    final results = realm.query<Sale>('createdAt >= \$0 AND createdAt <= \$1', [start, end]);
    return results.map((s) => s.toEntity()).toList();
  }

  @override
  Future<void> saveSale(SaleEntity sale) async {
    realm.write(() {
      // 1. Create Sale Item embedded objects
      final dbItems = sale.items.map((i) => SaleItem(
        i.productId,
        i.productName,
        i.barcode,
        i.qty,
        i.unitPrice,
        i.totalPrice,
        i.priceLevel,
      )).toList();

      // 2. Add Sale record
      realm.add(Sale(
        ObjectId(),
        sale.invoiceNumber,
        sale.createdAt,
        sale.subtotal,
        sale.discount,
        sale.tax,
        sale.total,
        sale.paymentMethod,
        sale.cashierId,
        sale.amountPaid,
        sale.amountRemaining,
        customerId: sale.customerId,
        note: sale.note,
        items: dbItems,
      ));

      // 3. Deduct stock levels for each sold product
      for (final item in sale.items) {
        try {
          final prodId = ObjectId.fromHexString(item.productId);
          final product = realm.find<Product>(prodId);
          if (product != null) {
            product.stock -= item.qty;
          }
        } catch (_) {}
      }
    });
  }

  @override
  Future<int> getNextInvoiceNumber() async {
    final count = realm.all<Sale>().length;
    return count + 1001; // Starting invoice offset
  }
}
