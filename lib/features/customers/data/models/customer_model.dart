import 'package:realm/realm.dart';
import '../../domain/entities/customer_entity.dart';

part 'customer_model.realm.dart';

@RealmModel()
class _Customer {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late String phone;
  late String address;
  late double totalPurchases;
  late double balance;
  late DateTime createdAt;
  late String priceLevel;   // 'retail' | 'salesman' | 'company' | 'wholesale'
}

extension CustomerMapper on Customer {
  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id.toString(),
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
