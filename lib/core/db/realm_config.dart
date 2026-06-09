import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:realm/realm.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/inventory/data/models/product_model.dart';
import '../../features/customers/data/models/customer_model.dart';
import '../../features/suppliers/data/models/supplier_model.dart';
import '../../features/pos/data/models/sale_model.dart';
import '../../features/cashier/data/models/expense_model.dart';
import '../../features/activity_log/data/models/activity_log_model.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class RealmConfig {
  static late final Realm realm;

  static void init() {
    final config = Configuration.local([
      User.schema,
      Product.schema,
      PriceTier.schema,
      Customer.schema,
      Supplier.schema,
      SaleItem.schema,
      Sale.schema,
      Expense.schema,
      ActivityLog.schema,
    ], schemaVersion: 5); // v5: Added ActivityLog schema
    
    realm = Realm(config);
    _seedIfNeeded();
  }

  static void _seedIfNeeded() {
    if (realm.all<User>().isEmpty) {
      realm.write(() {
        // Seed users
        realm.add(User(
          ObjectId(),
          'Admin Owner',
          'admin',
          hashPassword('admin123'),
          'admin',
          true,
        ));
        realm.add(User(
          ObjectId(),
          'Cashier User',
          'cashier',
          hashPassword('cashier123'),
          'cashier',
          true,
        ));

        // Seed 10 products with multi-tier pricing
        final productsData = [
          {
            'name': 'كابل نحاس 2.5مم / Copper Cable 2.5mm',
            'barcode': '6221000000010',
            'category': 'كابلات / Cables',
            'brand': 'السويدي / El Sewedy',
            'costPrice': 18.0,
            'stock': 150,
            'minStock': 20,
            'unit': 'متر / Meter',
            'retail': 28.0,
            'salesman': 25.0,
            'company': 23.0,
            'wholesale': 21.0,
          },
          {
            'name': 'كابل نحاس 4مم / Copper Cable 4mm',
            'barcode': '6221000000027',
            'category': 'كابلات / Cables',
            'brand': 'السويدي / El Sewedy',
            'costPrice': 30.0,
            'stock': 100,
            'minStock': 15,
            'unit': 'متر / Meter',
            'retail': 45.0,
            'salesman': 41.0,
            'company': 38.0,
            'wholesale': 35.0,
          },
          {
            'name': 'لمبة ليد 9 وات / LED Bulb 9W',
            'barcode': '6222000000031',
            'category': 'إضاءة / Lighting',
            'brand': 'توشيبا / Toshiba',
            'costPrice': 15.0,
            'stock': 80,
            'minStock': 10,
            'unit': 'قطعة / Piece',
            'retail': 25.0,
            'salesman': 22.0,
            'company': 20.0,
            'wholesale': 18.0,
          },
          {
            'name': 'لمبة ليد 12 وات / LED Bulb 12W',
            'barcode': '6222000000048',
            'category': 'إضاءة / Lighting',
            'brand': 'توشيبا / Toshiba',
            'costPrice': 20.0,
            'stock': 70,
            'minStock': 10,
            'unit': 'قطعة / Piece',
            'retail': 32.0,
            'salesman': 29.0,
            'company': 27.0,
            'wholesale': 24.0,
          },
          {
            'name': 'مفتاح كهربائي فردي / Single Light Switch',
            'barcode': '6223000000052',
            'category': 'مفاتيح / Switches',
            'brand': 'سانشي / Sanchi',
            'costPrice': 8.0,
            'stock': 200,
            'minStock': 25,
            'unit': 'قطعة / Piece',
            'retail': 15.0,
            'salesman': 13.0,
            'company': 12.0,
            'wholesale': 10.5,
          },
          {
            'name': 'بريزة كهربائية ثنائية / Double Power Socket',
            'barcode': '6223000000069',
            'category': 'مفاتيح / Switches',
            'brand': 'سانشي / Sanchi',
            'costPrice': 12.0,
            'stock': 180,
            'minStock': 20,
            'unit': 'قطعة / Piece',
            'retail': 22.0,
            'salesman': 19.5,
            'company': 18.0,
            'wholesale': 16.0,
          },
          {
            'name': 'مفتاح أوتوماتيك 16 أمبير / Circuit Breaker 16A',
            'barcode': '6224000000073',
            'category': 'لوحات وقواطع / Breakers',
            'brand': 'شنايدر / Schneider',
            'costPrice': 45.0,
            'stock': 50,
            'minStock': 8,
            'unit': 'قطعة / Piece',
            'retail': 75.0,
            'salesman': 68.0,
            'company': 63.0,
            'wholesale': 58.0,
          },
          {
            'name': 'مفتاح أوتوماتيك 32 أمبير / Circuit Breaker 32A',
            'barcode': '6224000000080',
            'category': 'لوحات وقواطع / Breakers',
            'brand': 'شنايدر / Schneider',
            'costPrice': 55.0,
            'stock': 40,
            'minStock': 8,
            'unit': 'قطعة / Piece',
            'retail': 90.0,
            'salesman': 82.0,
            'company': 76.0,
            'wholesale': 70.0,
          },
          {
            'name': 'شريط لاصق عازل / Insulating Tape',
            'barcode': '6225000000094',
            'category': 'إكسسوارات / Accessories',
            'brand': 'ثري إم / 3M',
            'costPrice': 3.5,
            'stock': 300,
            'minStock': 50,
            'unit': 'بكرة / Roll',
            'retail': 7.0,
            'salesman': 6.0,
            'company': 5.5,
            'wholesale': 4.8,
          },
          {
            'name': 'علبة فيشر بلاستيك / Plastic Wall Plugs Box',
            'barcode': '6225000000100',
            'category': 'إكسسوارات / Accessories',
            'brand': 'محلية / Local',
            'costPrice': 10.0,
            'stock': 90,
            'minStock': 15,
            'unit': 'علبة / Box',
            'retail': 20.0,
            'salesman': 18.0,
            'company': 16.5,
            'wholesale': 14.5,
          }
        ];

        for (final data in productsData) {
          realm.add(Product(
            ObjectId(),
            data['name'] as String,
            data['barcode'] as String,
            data['category'] as String,
            data['brand'] as String,
            data['costPrice'] as double,
            data['stock'] as int,
            data['minStock'] as int,
            data['unit'] as String,
            true,
            prices: [
              PriceTier('retail', 'تجزئة', 'Retail', data['retail'] as double),
              PriceTier('salesman', 'مندوب', 'Salesman', data['salesman'] as double),
              PriceTier('company', 'شركة', 'Company', data['company'] as double),
              PriceTier('wholesale', 'جملة', 'Wholesale', data['wholesale'] as double),
            ],
          ));
        }

        // Seed 1 default Customer for quick Retail sales
        realm.add(Customer(
          ObjectId(),
          'عميل نقدي / Cash Customer',
          '0000000000',
          'Local Store',
          0.0,
          0.0,
          DateTime.now(),
          'retail',
        ));
      });
    }
  }
}
