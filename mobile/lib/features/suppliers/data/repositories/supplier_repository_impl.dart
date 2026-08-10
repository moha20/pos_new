import 'package:hive/hive.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/entities/supplier_entity.dart';
import '../models/supplier_model.dart';
import '../../../../core/db/hive_config.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final Box _box;

  SupplierRepositoryImpl(this._box);

  @override
  Future<List<SupplierEntity>> getSuppliers() async {
    return _box.values
        .map((v) => SupplierModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<SupplierEntity?> getSupplierById(String id) async {
    final data = _box.get(id);
    if (data != null) {
      return SupplierModel.fromMap(data as Map<dynamic, dynamic>).toEntity();
    }
    return null;
  }

  @override
  Future<void> addSupplier(SupplierEntity supplier) async {
    final id = generateId();
    final model = SupplierModel(
      id: id,
      name: supplier.name,
      phone: supplier.phone,
      company: supplier.company,
      totalOrders: supplier.totalOrders,
      balance: supplier.balance,
    );
    await _box.put(id, model.toMap());
  }

  @override
  Future<void> updateSupplier(SupplierEntity supplier) async {
    if (_box.containsKey(supplier.id)) {
      final model = SupplierModel(
        id: supplier.id,
        name: supplier.name,
        phone: supplier.phone,
        company: supplier.company,
        totalOrders: supplier.totalOrders,
        balance: supplier.balance,
      );
      await _box.put(supplier.id, model.toMap());
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> updateOrders(String id, double orderAmount, double balanceAmount) async {
    final data = _box.get(id);
    if (data != null) {
      final supplier = SupplierModel.fromMap(data as Map<dynamic, dynamic>);
      final updated = SupplierModel(
        id: supplier.id,
        name: supplier.name,
        phone: supplier.phone,
        company: supplier.company,
        totalOrders: supplier.totalOrders + orderAmount,
        balance: supplier.balance + balanceAmount,
      );
      await _box.put(id, updated.toMap());
    }
  }
}
