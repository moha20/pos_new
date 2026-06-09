// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Supplier extends _Supplier
    with RealmEntity, RealmObjectBase, RealmObject {
  Supplier(
    ObjectId id,
    String name,
    String phone,
    String company,
    double totalOrders,
    double balance,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'company', company);
    RealmObjectBase.set(this, 'totalOrders', totalOrders);
    RealmObjectBase.set(this, 'balance', balance);
  }

  Supplier._();

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
  String get company => RealmObjectBase.get<String>(this, 'company') as String;
  @override
  set company(String value) => RealmObjectBase.set(this, 'company', value);

  @override
  double get totalOrders =>
      RealmObjectBase.get<double>(this, 'totalOrders') as double;
  @override
  set totalOrders(double value) =>
      RealmObjectBase.set(this, 'totalOrders', value);

  @override
  double get balance => RealmObjectBase.get<double>(this, 'balance') as double;
  @override
  set balance(double value) => RealmObjectBase.set(this, 'balance', value);

  @override
  Stream<RealmObjectChanges<Supplier>> get changes =>
      RealmObjectBase.getChanges<Supplier>(this);

  @override
  Stream<RealmObjectChanges<Supplier>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Supplier>(this, keyPaths);

  @override
  Supplier freeze() => RealmObjectBase.freezeObject<Supplier>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'phone': phone.toEJson(),
      'company': company.toEJson(),
      'totalOrders': totalOrders.toEJson(),
      'balance': balance.toEJson(),
    };
  }

  static EJsonValue _toEJson(Supplier value) => value.toEJson();
  static Supplier _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'phone': EJsonValue phone,
        'company': EJsonValue company,
        'totalOrders': EJsonValue totalOrders,
        'balance': EJsonValue balance,
      } =>
        Supplier(
          fromEJson(id),
          fromEJson(name),
          fromEJson(phone),
          fromEJson(company),
          fromEJson(totalOrders),
          fromEJson(balance),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Supplier._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Supplier, 'Supplier', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('phone', RealmPropertyType.string),
      SchemaProperty('company', RealmPropertyType.string),
      SchemaProperty('totalOrders', RealmPropertyType.double),
      SchemaProperty('balance', RealmPropertyType.double),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
