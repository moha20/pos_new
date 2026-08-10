import 'package:flutter_test/flutter_test.dart';
import 'package:almohandis_pos/core/di/di.dart';
import 'package:almohandis_pos/features/inventory/domain/entities/product_entity.dart';

void main() {
  group('Gravity DI Container Tests', () {
    test('Should register and find dependency successfully', () {
      const dependency = 'TestInstance';
      Gravity.put<String>(dependency);
      expect(Gravity.find<String>(), equals('TestInstance'));
    });

    test('Should throw exception for unregistered dependency', () {
      expect(() => Gravity.find<int>(), throwsStateError);
    });
  });

  group('ProductEntity Price Tier Selection Tests', () {
    final product = ProductEntity(
      id: 'abc',
      name: 'Copper Cable 2.5mm',
      barcode: '6221000000010',
      category: 'Cables',
      brand: 'El Sewedy',
      costPrice: 18.0,
      stock: 100,
      minStock: 10,
      unit: 'Meter',
      isActive: true,
      prices: [
        PriceTierEntity(level: 'retail', labelAr: 'تجزئة', labelEn: 'Retail', price: 28.0),
        PriceTierEntity(level: 'salesman', labelAr: 'مندوب', labelEn: 'Salesman', price: 25.0),
        PriceTierEntity(level: 'company', labelAr: 'شركة', labelEn: 'Company', price: 23.0),
        PriceTierEntity(level: 'wholesale', labelAr: 'جملة', labelEn: 'Wholesale', price: 21.0),
      ],
    );

    test('Should select correct Retail price', () {
      expect(product.priceFor('retail'), equals(28.0));
    });

    test('Should select correct Wholesale price', () {
      expect(product.priceFor('wholesale'), equals(21.0));
    });

    test('Should fallback to first price (Retail) if level does not exist', () {
      expect(product.priceFor('unknown_tier'), equals(28.0));
    });
  });
}
