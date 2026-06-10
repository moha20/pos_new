import '../../domain/entities/customer_entity.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double totalPurchases;
  final double balance;
  final DateTime createdAt;
  final String priceLevel;   // 'retail' | 'salesman' | 'company' | 'wholesale'

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.totalPurchases,
    required this.balance,
    required this.createdAt,
    required this.priceLevel,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'totalPurchases': totalPurchases,
    'balance': balance,
    'createdAt': createdAt.toIso8601String(),
    'priceLevel': priceLevel,
  };

  factory CustomerModel.fromMap(Map<dynamic, dynamic> map) => CustomerModel(
    id: map['id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String,
    address: map['address'] as String,
    totalPurchases: (map['totalPurchases'] as num).toDouble(),
    balance: (map['balance'] as num).toDouble(),
    createdAt: DateTime.parse(map['createdAt'] as String),
    priceLevel: map['priceLevel'] as String,
  );

  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      name: name,
      phone: phone,
      address: address,
      totalPurchases: totalPurchases,
      balance: balance,
      createdAt: createdAt,
      priceLevel: priceLevel,
    );
  }
}
