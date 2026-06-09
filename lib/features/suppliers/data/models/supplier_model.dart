import 'package:realm/realm.dart';
import '../../domain/entities/supplier_entity.dart';

part 'supplier_model.realm.dart';

@RealmModel()
class _Supplier {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late String phone;
  late String company;
  late double totalOrders;
  late double balance;
}

extension SupplierMapper on Supplier {
  SupplierEntity toEntity() {
    return SupplierEntity(
      id: id.toString(),
      name: name,
      phone: phone,
      company: company,
      totalOrders: totalOrders,
      balance: balance,
    );
  }
}
