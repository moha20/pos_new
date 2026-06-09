import 'package:realm/realm.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/entities/customer_entity.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final Realm realm;

  CustomerRepositoryImpl(this.realm);

  ObjectId _parseId(String idStr) {
    try {
      return ObjectId.fromHexString(idStr);
    } catch (_) {
      return ObjectId();
    }
  }

  @override
  Future<List<CustomerEntity>> getCustomers() async {
    return realm.all<Customer>().map((c) => c.toEntity()).toList();
  }

  @override
  Future<CustomerEntity?> getCustomerById(String id) async {
    final c = realm.find<Customer>(_parseId(id));
    return c?.toEntity();
  }

  @override
  Future<void> addCustomer(CustomerEntity customer) async {
    realm.write(() {
      realm.add(Customer(
        ObjectId(),
        customer.name,
        customer.phone,
        customer.address,
        customer.totalPurchases,
        customer.balance,
        customer.createdAt,
        customer.priceLevel,
      ));
    });
  }

  @override
  Future<void> updateCustomer(CustomerEntity customer) async {
    final dbCustomer = realm.find<Customer>(_parseId(customer.id));
    if (dbCustomer != null) {
      realm.write(() {
        dbCustomer.name = customer.name;
        dbCustomer.phone = customer.phone;
        dbCustomer.address = customer.address;
        dbCustomer.totalPurchases = customer.totalPurchases;
        dbCustomer.balance = customer.balance;
        dbCustomer.priceLevel = customer.priceLevel;
      });
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final dbCustomer = realm.find<Customer>(_parseId(id));
    if (dbCustomer != null) {
      realm.write(() {
        realm.delete(dbCustomer);
      });
    }
  }

  @override
  Future<void> updatePurchases(String id, double saleAmount, double remainingAmount) async {
    final dbCustomer = realm.find<Customer>(_parseId(id));
    if (dbCustomer != null) {
      realm.write(() {
        dbCustomer.totalPurchases += saleAmount;
        dbCustomer.balance += remainingAmount;
      });
    }
  }
}
