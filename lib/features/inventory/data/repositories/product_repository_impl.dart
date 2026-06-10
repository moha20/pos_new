import 'package:hive/hive.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';
import '../../../../core/db/hive_config.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Box _box;

  ProductRepositoryImpl(this._box);

  @override
  Future<List<ProductEntity>> getProducts() async {
    return _box.values
        .map((v) => ProductModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    final data = _box.get(id);
    if (data != null) {
      return ProductModel.fromMap(data as Map<dynamic, dynamic>).toEntity();
    }
    return null;
  }

  @override
  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    for (final entry in _box.toMap().entries) {
      final product = ProductModel.fromMap(entry.value as Map<dynamic, dynamic>);
      if (product.barcode == barcode) {
        return product.toEntity();
      }
    }
    return null;
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    final id = generateId();
    final model = ProductModel(
      id: id,
      name: product.name,
      barcode: product.barcode,
      category: product.category,
      brand: product.brand,
      costPrice: product.costPrice,
      stock: product.stock,
      minStock: product.minStock,
      unit: product.unit,
      isActive: product.isActive,
      imagePath: product.imagePath,
      prices: product.prices.map((p) => PriceTierModel(
        level: p.level,
        labelAr: p.labelAr,
        labelEn: p.labelEn,
        price: p.price,
      )).toList(),
    );
    await _box.put(id, model.toMap());
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    if (_box.containsKey(product.id)) {
      final model = ProductModel(
        id: product.id,
        name: product.name,
        barcode: product.barcode,
        category: product.category,
        brand: product.brand,
        costPrice: product.costPrice,
        stock: product.stock,
        minStock: product.minStock,
        unit: product.unit,
        isActive: product.isActive,
        imagePath: product.imagePath,
        prices: product.prices.map((p) => PriceTierModel(
          level: p.level,
          labelAr: p.labelAr,
          labelEn: p.labelEn,
          price: p.price,
        )).toList(),
      );
      await _box.put(product.id, model.toMap());
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> updateStock(String id, int changeQty) async {
    final data = _box.get(id);
    if (data != null) {
      final product = ProductModel.fromMap(data as Map<dynamic, dynamic>);
      final updated = ProductModel(
        id: product.id,
        name: product.name,
        barcode: product.barcode,
        category: product.category,
        brand: product.brand,
        costPrice: product.costPrice,
        stock: product.stock + changeQty,
        minStock: product.minStock,
        unit: product.unit,
        isActive: product.isActive,
        imagePath: product.imagePath,
        prices: product.prices,
      );
      await _box.put(id, updated.toMap());
    }
  }
}
