import 'package:realm/realm.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/entities/supplier_entity.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final Realm realm;

  SupplierRepositoryImpl(this.realm);

  ObjectId _parseId(String idStr) {
    try {
      return ObjectId.fromHexString(idStr);
    } catch (_) {
      return ObjectId();
    }
  }

  @override
  Future<List<SupplierEntity>> getSuppliers() async {
    return realm.all<Supplier>().map((s) => s.toEntity()).toList();
  }

  @override
  Future<SupplierEntity?> getSupplierById(String id) async {
    final s = realm.find<Supplier>(_parseId(id));
    return s?.toEntity();
  }

  @override
  Future<void> addSupplier(SupplierEntity supplier) async {
    realm.write(() {
      realm.add(Supplier(
        ObjectId(),
        supplier.name,
        supplier.phone,
        supplier.company,
        supplier.totalOrders,
        supplier.balance,
      ));
    });
  }

  @override
  Future<void> updateSupplier(SupplierEntity supplier) async {
    final dbSupplier = realm.find<Supplier>(_parseId(supplier.id));
    if (dbSupplier != null) {
      realm.write(() {
        dbSupplier.name = supplier.name;
        dbSupplier.phone = supplier.phone;
        dbSupplier.company = supplier.company;
        dbSupplier.totalOrders = supplier.totalOrders;
        dbSupplier.balance = supplier.balance;
      });
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    final dbSupplier = realm.find<Supplier>(_parseId(id));
    if (dbSupplier != null) {
      realm.write(() {
        realm.delete(dbSupplier);
      });
    }
  }

  @override
  Future<void> updateOrders(String id, double orderAmount, double balanceAmount) async {
    final dbSupplier = realm.find<Supplier>(_parseId(id));
    if (dbSupplier != null) {
      realm.write(() {
        dbSupplier.totalOrders += orderAmount;
        dbSupplier.balance += balanceAmount;
      });
    }
  }
}
