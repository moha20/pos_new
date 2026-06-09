import 'package:realm/realm.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class _PriceTier {
  late String level;        // 'retail' | 'salesman' | 'company' | 'wholesale'
  late String labelAr;      // 'تجزئة' | 'مندوب' | 'شركة' | 'جملة'
  late String labelEn;      // 'Retail' | 'Salesman' | 'Company' | 'Wholesale'
  late double price;
}

@RealmModel()
class _Product {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late String barcode;
  late String category;
  late String brand;
  late double costPrice;     // purchase price (hidden from cashier role)
  late int    stock;
  late int    minStock;
  late String unit;
  late bool   isActive;
  late List<_PriceTier> prices;  // embedded list of 4 tiers
  late String? imagePath;
}

extension PriceTierMapper on PriceTier {
  PriceTierEntity toEntity() => PriceTierEntity(
    level: level,
    labelAr: labelAr,
    labelEn: labelEn,
    price: price,
  );
}

extension ProductMapper on Product {
  ProductEntity toEntity() {
    return ProductEntity(
      id: id.toString(),
      name: name,
      barcode: barcode,
      category: category,
      brand: brand,
      costPrice: costPrice,
      stock: stock,
      minStock: minStock,
      unit: unit,
      isActive: isActive,
      prices: prices.map((p) => p.toEntity()).toList(),
      imagePath: imagePath,
    );
  }
}
