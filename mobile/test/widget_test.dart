import 'package:flutter_test/flutter_test.dart';
import 'package:almohandis_pos/core/di/di.dart';
import 'package:almohandis_pos/features/inventory/domain/entities/product_entity.dart';
import 'package:almohandis_pos/widgets/invoice_format_widgets.dart';

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

  group('InvoiceStoreInfo Company Name Tests', () {
    test('Should preserve custom company name exactly as entered', () {
      final name = InvoiceStoreInfo.resolveCompanyName(
        name: 'شركة النور للتجارة الحديثة',
        isArabic: true,
      );
      expect(name, equals('شركة النور للتجارة الحديثة'));
    });

    test('Should preserve custom company name when updated', () {
      var name = InvoiceStoreInfo.resolveCompanyName(
        name: 'CyperFusion',
        isArabic: true,
      );
      expect(name, equals('CyperFusion'));

      // User changes company name
      name = InvoiceStoreInfo.resolveCompanyName(
        name: 'شركة المهندس للأدوات الكهربائية',
        isArabic: true,
      );
      expect(name, equals('شركة المهندس للأدوات الكهربائية'));
    });

    test('Should fallback to default Arabic name when candidate is empty or placeholder', () {
      expect(
        InvoiceStoreInfo.resolveCompanyName(name: '', isArabic: true),
        equals('المهندس للبرمجيات'),
      );
      expect(
        InvoiceStoreInfo.resolveCompanyName(name: 'اسم الشركة / الفرع', isArabic: true),
        equals('المهندس للبرمجيات'),
      );
      expect(
        InvoiceStoreInfo.resolveCompanyName(name: 'Company / Branch Name', isArabic: true),
        equals('المهندس للبرمجيات'),
      );
    });

    test('Should fallback to default English name when candidate is empty or placeholder in English', () {
      expect(
        InvoiceStoreInfo.resolveCompanyName(name: '', isArabic: false),
        equals('Elmohands software'),
      );
      expect(
        InvoiceStoreInfo.resolveCompanyName(name: 'Company / Branch Name', isArabic: false),
        equals('Elmohands software'),
      );
    });

    test('Should localize Elmohands software to Arabic when isArabic is true', () {
      expect(
        InvoiceStoreInfo.resolveCompanyName(name: 'Elmohands software', isArabic: true),
        equals('المهندس للبرمجيات'),
      );
    });

    test('Should use fallbackUserCompany if name is empty', () {
      expect(
        InvoiceStoreInfo.resolveCompanyName(
          name: '',
          fallbackUserCompany: 'مؤسسة الأمل',
          isArabic: true,
        ),
        equals('مؤسسة الأمل'),
      );
    });
  });
}
