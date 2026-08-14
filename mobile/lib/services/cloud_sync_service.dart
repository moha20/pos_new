import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../features/pos/domain/entities/sale_entity.dart';
import '../core/di/di.dart';

class OnlineSaleRecord {
  final String id;
  final String companyName;
  final String cashierId;
  final String invoiceNumber;
  final double total;
  final String paymentMethod;
  final int itemsCount;
  final DateTime createdAt;

  OnlineSaleRecord({
    required this.id,
    required this.companyName,
    required this.cashierId,
    required this.invoiceNumber,
    required this.total,
    required this.paymentMethod,
    required this.itemsCount,
    required this.createdAt,
  });

  factory OnlineSaleRecord.fromJson(Map<String, dynamic> json) {
    return OnlineSaleRecord(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? 'Default Store',
      cashierId: json['cashierId']?.toString() ?? 'Cashier',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'Cash',
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyName': companyName,
        'cashierId': cashierId,
        'invoiceNumber': invoiceNumber,
        'total': total,
        'paymentMethod': paymentMethod,
        'itemsCount': itemsCount,
        'createdAt': createdAt.toIso8601String(),
      };
}

class CloudSyncService {
  static const String _storageKey = 'online_cloud_sales_cache';
  static const String defaultApiUrl = 'https://apipharmacy.official-web.online';

  Future<String> _getBaseUrl() async {
    final prefs = Gravity.find<SharedPreferences>();
    final customUrl = prefs.getString('cloud_endpoint');
    if (customUrl != null && customUrl.isNotEmpty && !customUrl.contains('jsonbin')) {
      return customUrl.endsWith('/') ? customUrl.substring(0, customUrl.length - 1) : customUrl;
    }
    return defaultApiUrl;
  }

  /// Verify if company is active on Hostinger server backend
  /// Returns null if active, or error message String if inactive/disabled
  Future<String?> checkCompanyActive(String companyName) async {
    try {
      final baseUrl = await _getBaseUrl();
      final url = Uri.parse('$baseUrl/login.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'company_name': companyName}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 403) {
        final body = jsonDecode(response.body);
        if (body['code'] == 'COMPANY_INACTIVE') {
          return 'COMPANY_INACTIVE';
        }
      }
    } catch (e) {
      debugPrint('Company active check notice: $e');
    }
    return null; // Null means check passed or offline fallback
  }

  /// Authenticate company admin / user online from Hostinger API
  Future<Map<String, dynamic>?> authenticateOnline(String companyName, String username, String password) async {
    try {
      final baseUrl = await _getBaseUrl();
      final url = Uri.parse('$baseUrl/login.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'company_name': companyName,
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 404) {
        final body = jsonDecode(response.body);
        if (body['code'] == 'COMPANY_NOT_FOUND') {
          throw Exception('COMPANY_NOT_FOUND');
        }
      }

      if (response.statusCode == 403) {
        final body = jsonDecode(response.body);
        if (body['code'] == 'COMPANY_INACTIVE') {
          throw Exception('COMPANY_INACTIVE');
        }
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json;
        }
      }
    } catch (e) {
      if (e.toString().contains('COMPANY_INACTIVE') || e.toString().contains('COMPANY_NOT_FOUND')) rethrow;
    }
    return null;
  }

  /// Sync single sale to online cloud backend
  Future<bool> uploadSale(SaleEntity sale, {String? companyName}) async {
    try {
      final prefs = Gravity.find<SharedPreferences>();
      final company = companyName ?? prefs.getString('company_name') ?? 'Al-Mohandis POS';

      final record = OnlineSaleRecord(
        id: sale.id,
        companyName: company,
        cashierId: sale.cashierId.isNotEmpty ? sale.cashierId : 'admin',
        invoiceNumber: sale.invoiceNumber,
        total: sale.total,
        paymentMethod: sale.paymentMethod,
        itemsCount: sale.items.length,
        createdAt: sale.createdAt,
      );

      // Cache locally for instant admin inspection
      await _cacheSaleLocally(record);

      final baseUrl = await _getBaseUrl();
      final url = Uri.parse('$baseUrl/api/sales.php');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(record.toJson()),
      ).timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('Cloud Sync Notice: Stored locally for sync. ($e)');
    }
    return false;
  }

  /// Store sale record in shared memory cache for online admin monitoring view
  Future<void> _cacheSaleLocally(OnlineSaleRecord record) async {
    final prefs = Gravity.find<SharedPreferences>();
    final List<String> list = prefs.getStringList(_storageKey) ?? [];
    final jsonStr = jsonEncode(record.toJson());
    // Avoid duplicate invoice records
    list.removeWhere((item) {
      try {
        final map = jsonDecode(item);
        return map['invoiceNumber'] == record.invoiceNumber;
      } catch (_) {
        return false;
      }
    });
    list.insert(0, jsonStr);
    // Keep last 200 sales in cache
    if (list.length > 200) list.removeLast();
    await prefs.setStringList(_storageKey, list);
  }

  /// Retrieve all online sales for Admin dashboard, filtered by company and cashier
  Future<List<OnlineSaleRecord>> fetchOnlineSales({
    String? filterCompany,
    String? filterCashier,
  }) async {
    try {
      final baseUrl = await _getBaseUrl();
      final companyQuery = (filterCompany != null && filterCompany != 'All') ? filterCompany : '';
      final url = Uri.parse('$baseUrl/api/sales.php?company=${Uri.encodeComponent(companyQuery)}');
      final res = await http.get(url).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == 'success' && json['data'] != null) {
          final List list = json['data'];
          return list.map((item) {
            return OnlineSaleRecord(
              id: item['sale_id'] ?? item['id']?.toString() ?? '',
              companyName: item['company_name'] ?? 'Store',
              cashierId: item['cashier_id'] ?? 'Cashier',
              invoiceNumber: item['invoice_number'] ?? '',
              total: (item['total'] as num?)?.toDouble() ?? 0.0,
              paymentMethod: item['payment_method'] ?? 'Cash',
              itemsCount: (item['items_count'] as num?)?.toInt() ?? 1,
              createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
            );
          }).toList();
        }
      }
    } catch (_) {}

    // Fallback to local memory cache
    final prefs = Gravity.find<SharedPreferences>();
    final List<String> rawList = prefs.getStringList(_storageKey) ?? [];

    List<OnlineSaleRecord> records = rawList.map((item) {
      return OnlineSaleRecord.fromJson(jsonDecode(item));
    }).toList();

    if (filterCompany != null && filterCompany.isNotEmpty && filterCompany != 'All') {
      records = records.where((r) => r.companyName.toLowerCase() == filterCompany.toLowerCase()).toList();
    }

    if (filterCashier != null && filterCashier.isNotEmpty && filterCashier != 'All') {
      records = records.where((r) => r.cashierId.toLowerCase() == filterCashier.toLowerCase()).toList();
    }

    return records;
  }
}
