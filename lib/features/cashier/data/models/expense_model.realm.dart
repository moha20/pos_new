// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Expense extends _Expense with RealmEntity, RealmObjectBase, RealmObject {
  Expense(
    ObjectId id,
    String description,
    double amount,
    String category,
    DateTime date, {
    String? shiftId,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'shiftId', shiftId);
  }

  Expense._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  @override
  set description(String value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String get category =>
      RealmObjectBase.get<String>(this, 'category') as String;
  @override
  set category(String value) => RealmObjectBase.set(this, 'category', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get shiftId =>
      RealmObjectBase.get<String>(this, 'shiftId') as String?;
  @override
  set shiftId(String? value) => RealmObjectBase.set(this, 'shiftId', value);

  @override
  Stream<RealmObjectChanges<Expense>> get changes =>
      RealmObjectBase.getChanges<Expense>(this);

  @override
  Stream<RealmObjectChanges<Expense>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Expense>(this, keyPaths);

  @override
  Expense freeze() => RealmObjectBase.freezeObject<Expense>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'description': description.toEJson(),
      'amount': amount.toEJson(),
      'category': category.toEJson(),
      'date': date.toEJson(),
      'shiftId': shiftId.toEJson(),
    };
  }

  static EJsonValue _toEJson(Expense value) => value.toEJson();
  static Expense _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'description': EJsonValue description,
        'amount': EJsonValue amount,
        'category': EJsonValue category,
        'date': EJsonValue date,
      } =>
        Expense(
          fromEJson(id),
          fromEJson(description),
          fromEJson(amount),
          fromEJson(category),
          fromEJson(date),
          shiftId: fromEJson(ejson['shiftId']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Expense._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Expense, 'Expense', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('description', RealmPropertyType.string),
      SchemaProperty('amount', RealmPropertyType.double),
      SchemaProperty('category', RealmPropertyType.string),
      SchemaProperty('date', RealmPropertyType.timestamp),
      SchemaProperty('shiftId', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
