import '../../domain/entities/product_entity.dart';

class PriceTierModel {
  final String level;        // 'retail' | 'salesman' | 'company' | 'wholesale'
  final String labelAr;      // 'تجزئة' | 'مندوب' | 'شركة' | 'جملة'
  final String labelEn;      // 'Retail' | 'Salesman' | 'Company' | 'Wholesale'
  final double price;

  PriceTierModel({
    required this.level,
    required this.labelAr,
    required this.labelEn,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'level': level,
    'labelAr': labelAr,
    'labelEn': labelEn,
    'price': price,
  };

  factory PriceTierModel.fromMap(Map<dynamic, dynamic> map) => PriceTierModel(
    level: map['level'] as String,
    labelAr: map['labelAr'] as String,
    labelEn: map['labelEn'] as String,
    price: (map['price'] as num).toDouble(),
  );

  PriceTierEntity toEntity() => PriceTierEntity(
    level: level,
    labelAr: labelAr,
    labelEn: labelEn,
    price: price,
  );
}

class ProductModel {
  final String id;
  final String name;
  final String barcode;
  final String category;
  final String brand;
  final double costPrice;     // purchase price (hidden from cashier role)
  final int    stock;
  final int    minStock;
  final String unit;
  final bool   isActive;
  final List<PriceTierModel> prices;  // list of 4 tiers
  final String? imagePath;

  ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.brand,
    required this.costPrice,
    required this.stock,
    required this.minStock,
    required this.unit,
    required this.isActive,
    required this.prices,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'barcode': barcode,
    'category': category,
    'brand': brand,
    'costPrice': costPrice,
    'stock': stock,
    'minStock': minStock,
    'unit': unit,
    'isActive': isActive,
    'prices': prices.map((p) => p.toMap()).toList(),
    'imagePath': imagePath,
  };

  factory ProductModel.fromMap(Map<dynamic, dynamic> map) => ProductModel(
    id: map['id'] as String,
    name: map['name'] as String,
    barcode: map['barcode'] as String,
    category: map['category'] as String,
    brand: map['brand'] as String,
    costPrice: (map['costPrice'] as num).toDouble(),
    stock: (map['stock'] as num).toInt(),
    minStock: (map['minStock'] as num).toInt(),
    unit: map['unit'] as String,
    isActive: map['isActive'] as bool,
    prices: (map['prices'] as List).map((p) => PriceTierModel.fromMap(p as Map<dynamic, dynamic>)).toList(),
    imagePath: map['imagePath'] as String?,
  );

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
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
