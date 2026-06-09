import 'package:realm/realm.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Realm realm;

  ProductRepositoryImpl(this.realm);

  ObjectId _parseId(String idStr) {
    try {
      return ObjectId.fromHexString(idStr);
    } catch (_) {
      return ObjectId();
    }
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    return realm.all<Product>().map((p) => p.toEntity()).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    final p = realm.find<Product>(_parseId(id));
    return p?.toEntity();
  }

  @override
  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    final results = realm.query<Product>('barcode == \$0', [barcode]);
    if (results.isNotEmpty) {
      return results.first.toEntity();
    }
    return null;
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    realm.write(() {
      realm.add(Product(
        ObjectId(),
        product.name,
        product.barcode,
        product.category,
        product.brand,
        product.costPrice,
        product.stock,
        product.minStock,
        product.unit,
        product.isActive,
        imagePath: product.imagePath,
        prices: product.prices.map((p) => PriceTier(
          p.level,
          p.labelAr,
          p.labelEn,
          p.price,
        )).toList(),
      ));
    });
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final dbProduct = realm.find<Product>(_parseId(product.id));
    if (dbProduct != null) {
      realm.write(() {
        dbProduct.name = product.name;
        dbProduct.barcode = product.barcode;
        dbProduct.category = product.category;
        dbProduct.brand = product.brand;
        dbProduct.costPrice = product.costPrice;
        dbProduct.stock = product.stock;
        dbProduct.minStock = product.minStock;
        dbProduct.unit = product.unit;
        dbProduct.isActive = product.isActive;
        dbProduct.imagePath = product.imagePath;
        
        // Rebuild price list
        dbProduct.prices.clear();
        for (final p in product.prices) {
          dbProduct.prices.add(PriceTier(
            p.level,
            p.labelAr,
            p.labelEn,
            p.price,
          ));
        }
      });
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    final dbProduct = realm.find<Product>(_parseId(id));
    if (dbProduct != null) {
      realm.write(() {
        realm.delete(dbProduct);
      });
    }
  }

  @override
  Future<void> updateStock(String id, int changeQty) async {
    final dbProduct = realm.find<Product>(_parseId(id));
    if (dbProduct != null) {
      realm.write(() {
        dbProduct.stock += changeQty;
      });
    }
  }
}
