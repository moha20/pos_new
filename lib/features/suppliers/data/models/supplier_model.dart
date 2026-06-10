import '../../domain/entities/supplier_entity.dart';

class SupplierModel {
  final String id;
  final String name;
  final String phone;
  final String company;
  final double totalOrders;
  final double balance;

  SupplierModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.company,
    required this.totalOrders,
    required this.balance,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'company': company,
    'totalOrders': totalOrders,
    'balance': balance,
  };

  factory SupplierModel.fromMap(Map<dynamic, dynamic> map) => SupplierModel(
    id: map['id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String,
    company: map['company'] as String,
    totalOrders: (map['totalOrders'] as num).toDouble(),
    balance: (map['balance'] as num).toDouble(),
  );

  SupplierEntity toEntity() {
    return SupplierEntity(
      id: id,
      name: name,
      phone: phone,
      company: company,
      totalOrders: totalOrders,
      balance: balance,
    );
  }
}
