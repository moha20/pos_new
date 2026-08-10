import 'package:hive/hive.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/entities/customer_entity.dart';
import '../models/customer_model.dart';
import '../../../../core/db/hive_config.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final Box _box;

  CustomerRepositoryImpl(this._box);

  @override
  Future<List<CustomerEntity>> getCustomers() async {
    return _box.values
        .map((v) => CustomerModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<CustomerEntity?> getCustomerById(String id) async {
    final data = _box.get(id);
    if (data != null) {
      return CustomerModel.fromMap(data as Map<dynamic, dynamic>).toEntity();
    }
    return null;
  }

  @override
  Future<void> addCustomer(CustomerEntity customer) async {
    final id = generateId();
    final model = CustomerModel(
      id: id,
      name: customer.name,
      phone: customer.phone,
      address: customer.address,
      totalPurchases: customer.totalPurchases,
      balance: customer.balance,
      createdAt: customer.createdAt,
      priceLevel: customer.priceLevel,
    );
    await _box.put(id, model.toMap());
  }

  @override
  Future<void> updateCustomer(CustomerEntity customer) async {
    if (_box.containsKey(customer.id)) {
      final old = CustomerModel.fromMap(_box.get(customer.id) as Map<dynamic, dynamic>);
      final model = CustomerModel(
        id: customer.id,
        name: customer.name,
        phone: customer.phone,
        address: customer.address,
        totalPurchases: customer.totalPurchases,
        balance: customer.balance,
        createdAt: old.createdAt,
        priceLevel: customer.priceLevel,
      );
      await _box.put(customer.id, model.toMap());
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> updatePurchases(String id, double saleAmount, double remainingAmount) async {
    final data = _box.get(id);
    if (data != null) {
      final customer = CustomerModel.fromMap(data as Map<dynamic, dynamic>);
      final updated = CustomerModel(
        id: customer.id,
        name: customer.name,
        phone: customer.phone,
        address: customer.address,
        totalPurchases: customer.totalPurchases + saleAmount,
        balance: customer.balance + remainingAmount,
        createdAt: customer.createdAt,
        priceLevel: customer.priceLevel,
      );
      await _box.put(id, updated.toMap());
    }
  }
}
