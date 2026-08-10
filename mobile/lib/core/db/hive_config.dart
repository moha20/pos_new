import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/inventory/data/models/product_model.dart';
import '../../features/customers/data/models/customer_model.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

String generateId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final hash = sha256.convert(utf8.encode('$now${DateTime.now()}')).toString();
  return hash.substring(0, 24);
}

class HiveConfig {
  static late final Box usersBox;
  static late final Box productsBox;
  static late final Box customersBox;
  static late final Box suppliersBox;
  static late final Box salesBox;
  static late final Box expensesBox;
  static late final Box activityLogsBox;
  static late final Box paymentsBox;
  static late final Box supplierInvoicesBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    usersBox = await Hive.openBox('users');
    productsBox = await Hive.openBox('products');
    customersBox = await Hive.openBox('customers');
    suppliersBox = await Hive.openBox('suppliers');
    salesBox = await Hive.openBox('sales');
    expensesBox = await Hive.openBox('expenses');
    activityLogsBox = await Hive.openBox('activity_logs');
    paymentsBox = await Hive.openBox('payments');
    supplierInvoicesBox = await Hive.openBox('supplier_invoices');

    _seedIfNeeded();
  }

  static void _seedIfNeeded() {
    if (usersBox.isEmpty) {
      // Seed users
      final adminId = generateId();
      usersBox.put(
        adminId,
        UserModel(
          id: adminId,
          name: 'Admin Owner',
          username: 'admin',
          passwordHash: hashPassword('admin123'),
          role: 'admin',
          isActive: true,
        ).toMap(),
      );

      final cashierId = '${generateId()}1';
      usersBox.put(
        cashierId,
        UserModel(
          id: cashierId,
          name: 'Cashier User',
          username: 'cashier',
          passwordHash: hashPassword('cashier123'),
          role: 'cashier',
          isActive: true,
        ).toMap(),
      );

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
        },
      ];

      for (final data in productsData) {
        final prodId = generateId() + data['barcode'].toString();
        productsBox.put(
          prodId,
          ProductModel(
            id: prodId,
            name: data['name'] as String,
            barcode: data['barcode'] as String,
            category: data['category'] as String,
            brand: data['brand'] as String,
            costPrice: data['costPrice'] as double,
            stock: data['stock'] as int,
            minStock: data['minStock'] as int,
            unit: data['unit'] as String,
            isActive: true,
            prices: [
              PriceTierModel(
                level: 'retail',
                labelAr: 'تجزئة',
                labelEn: 'Retail',
                price: data['retail'] as double,
              ),
              PriceTierModel(
                level: 'salesman',
                labelAr: 'مندوب',
                labelEn: 'Salesman',
                price: data['salesman'] as double,
              ),
              PriceTierModel(
                level: 'company',
                labelAr: 'شركة',
                labelEn: 'Company',
                price: data['company'] as double,
              ),
              PriceTierModel(
                level: 'wholesale',
                labelAr: 'جملة',
                labelEn: 'Wholesale',
                price: data['wholesale'] as double,
              ),
            ],
          ).toMap(),
        );
      }

      // Seed 1 default Customer for quick Retail sales
      final custId = '${generateId()}cust';
      customersBox.put(
        custId,
        CustomerModel(
          id: custId,
          name: 'عميل نقدي / Cash Customer',
          phone: '0000000000',
          address: 'Local Store',
          totalPurchases: 0.0,
          balance: 0.0,
          createdAt: DateTime.now(),
          priceLevel: 'retail',
        ).toMap(),
      );
    }
  }
}
