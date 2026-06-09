// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Customer extends _Customer
    with RealmEntity, RealmObjectBase, RealmObject {
  Customer(
    ObjectId id,
    String name,
    String phone,
    String address,
    double totalPurchases,
    double balance,
    DateTime createdAt,
    String priceLevel,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'totalPurchases', totalPurchases);
    RealmObjectBase.set(this, 'balance', balance);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'priceLevel', priceLevel);
  }

  Customer._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get phone => RealmObjectBase.get<String>(this, 'phone') as String;
  @override
  set phone(String value) => RealmObjectBase.set(this, 'phone', value);

  @override
  String get address => RealmObjectBase.get<String>(this, 'address') as String;
  @override
  set address(String value) => RealmObjectBase.set(this, 'address', value);

  @override
  double get totalPurchases =>
      RealmObjectBase.get<double>(this, 'totalPurchases') as double;
  @override
  set totalPurchases(double value) =>
      RealmObjectBase.set(this, 'totalPurchases', value);

  @override
  double get balance => RealmObjectBase.get<double>(this, 'balance') as double;
  @override
  set balance(double value) => RealmObjectBase.set(this, 'balance', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  String get priceLevel =>
      RealmObjectBase.get<String>(this, 'priceLevel') as String;
  @override
  set priceLevel(String value) =>
      RealmObjectBase.set(this, 'priceLevel', value);

  @override
  Stream<RealmObjectChanges<Customer>> get changes =>
      RealmObjectBase.getChanges<Customer>(this);

  @override
  Stream<RealmObjectChanges<Customer>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Customer>(this, keyPaths);

  @override
  Customer freeze() => RealmObjectBase.freezeObject<Customer>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'phone': phone.toEJson(),
      'address': address.toEJson(),
      'totalPurchases': totalPurchases.toEJson(),
      'balance': balance.toEJson(),
      'createdAt': createdAt.toEJson(),
      'priceLevel': priceLevel.toEJson(),
    };
  }

  static EJsonValue _toEJson(Customer value) => value.toEJson();
  static Customer _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'phone': EJsonValue phone,
        'address': EJsonValue address,
        'totalPurchases': EJsonValue totalPurchases,
        'balance': EJsonValue balance,
        'createdAt': EJsonValue createdAt,
        'priceLevel': EJsonValue priceLevel,
      } =>
        Customer(
          fromEJson(id),
          fromEJson(name),
          fromEJson(phone),
          fromEJson(address),
          fromEJson(totalPurchases),
          fromEJson(balance),
          fromEJson(createdAt),
          fromEJson(priceLevel),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Customer._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Customer, 'Customer', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('phone', RealmPropertyType.string),
      SchemaProperty('address', RealmPropertyType.string),
      SchemaProperty('totalPurchases', RealmPropertyType.double),
      SchemaProperty('balance', RealmPropertyType.double),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('priceLevel', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
