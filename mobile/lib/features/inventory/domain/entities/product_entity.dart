class PriceTierEntity {
  final String level;        // 'retail' | 'salesman' | 'company' | 'wholesale'
  final String labelAr;      // 'تجزئة' | 'مندوب' | 'شركة' | 'جملة'
  final String labelEn;      // 'Retail' | 'Salesman' | 'Company' | 'Wholesale'
  final double price;

  PriceTierEntity({
    required this.level,
    required this.labelAr,
    required this.labelEn,
    required this.price,
  });
}

class ProductEntity {
  final String id;
  final String name;
  final String barcode;
  final String category;
  final String brand;
  final double costPrice;
  final int stock;
  final int minStock;
  final String unit;
  final bool isActive;
  final List<PriceTierEntity> prices;
  final String? imagePath;

  ProductEntity({
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

  double priceFor(String level) {
    // 1. Exact match
    for (final p in prices) {
      if (p.level == level) {
        return p.price;
      }
    }
    // 2. Case-insensitive match
    for (final p in prices) {
      if (p.level.toLowerCase() == level.toLowerCase()) {
        return p.price;
      }
    }
    // 3. Fallback to first price
    return prices.isNotEmpty ? prices.first.price : 0.0;
  }

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;
}
