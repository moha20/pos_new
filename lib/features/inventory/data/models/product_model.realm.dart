// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class PriceTier extends _PriceTier
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  PriceTier(String level, String labelAr, String labelEn, double price) {
    RealmObjectBase.set(this, 'level', level);
    RealmObjectBase.set(this, 'labelAr', labelAr);
    RealmObjectBase.set(this, 'labelEn', labelEn);
    RealmObjectBase.set(this, 'price', price);
  }

  PriceTier._();

  @override
  String get level => RealmObjectBase.get<String>(this, 'level') as String;
  @override
  set level(String value) => RealmObjectBase.set(this, 'level', value);

  @override
  String get labelAr => RealmObjectBase.get<String>(this, 'labelAr') as String;
  @override
  set labelAr(String value) => RealmObjectBase.set(this, 'labelAr', value);

  @override
  String get labelEn => RealmObjectBase.get<String>(this, 'labelEn') as String;
  @override
  set labelEn(String value) => RealmObjectBase.set(this, 'labelEn', value);

  @override
  double get price => RealmObjectBase.get<double>(this, 'price') as double;
  @override
  set price(double value) => RealmObjectBase.set(this, 'price', value);

  @override
  Stream<RealmObjectChanges<PriceTier>> get changes =>
      RealmObjectBase.getChanges<PriceTier>(this);

  @override
  Stream<RealmObjectChanges<PriceTier>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<PriceTier>(this, keyPaths);

  @override
  PriceTier freeze() => RealmObjectBase.freezeObject<PriceTier>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'level': level.toEJson(),
      'labelAr': labelAr.toEJson(),
      'labelEn': labelEn.toEJson(),
      'price': price.toEJson(),
    };
  }

  static EJsonValue _toEJson(PriceTier value) => value.toEJson();
  static PriceTier _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'level': EJsonValue level,
        'labelAr': EJsonValue labelAr,
        'labelEn': EJsonValue labelEn,
        'price': EJsonValue price,
      } =>
        PriceTier(
          fromEJson(level),
          fromEJson(labelAr),
          fromEJson(labelEn),
          fromEJson(price),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PriceTier._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.embeddedObject,
      PriceTier,
      'PriceTier',
      [
        SchemaProperty('level', RealmPropertyType.string),
        SchemaProperty('labelAr', RealmPropertyType.string),
        SchemaProperty('labelEn', RealmPropertyType.string),
        SchemaProperty('price', RealmPropertyType.double),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Product extends _Product with RealmEntity, RealmObjectBase, RealmObject {
  Product(
    ObjectId id,
    String name,
    String barcode,
    String category,
    String brand,
    double costPrice,
    int stock,
    int minStock,
    String unit,
    bool isActive, {
    Iterable<PriceTier> prices = const [],
    String? imagePath,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'barcode', barcode);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'brand', brand);
    RealmObjectBase.set(this, 'costPrice', costPrice);
    RealmObjectBase.set(this, 'stock', stock);
    RealmObjectBase.set(this, 'minStock', minStock);
    RealmObjectBase.set(this, 'unit', unit);
    RealmObjectBase.set(this, 'isActive', isActive);
    RealmObjectBase.set<RealmList<PriceTier>>(
      this,
      'prices',
      RealmList<PriceTier>(prices),
    );
    RealmObjectBase.set(this, 'imagePath', imagePath);
  }

  Product._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get barcode => RealmObjectBase.get<String>(this, 'barcode') as String;
  @override
  set barcode(String value) => RealmObjectBase.set(this, 'barcode', value);

  @override
  String get category =>
      RealmObjectBase.get<String>(this, 'category') as String;
  @override
  set category(String value) => RealmObjectBase.set(this, 'category', value);

  @override
  String get brand => RealmObjectBase.get<String>(this, 'brand') as String;
  @override
  set brand(String value) => RealmObjectBase.set(this, 'brand', value);

  @override
  double get costPrice =>
      RealmObjectBase.get<double>(this, 'costPrice') as double;
  @override
  set costPrice(double value) => RealmObjectBase.set(this, 'costPrice', value);

  @override
  int get stock => RealmObjectBase.get<int>(this, 'stock') as int;
  @override
  set stock(int value) => RealmObjectBase.set(this, 'stock', value);

  @override
  int get minStock => RealmObjectBase.get<int>(this, 'minStock') as int;
  @override
  set minStock(int value) => RealmObjectBase.set(this, 'minStock', value);

  @override
  String get unit => RealmObjectBase.get<String>(this, 'unit') as String;
  @override
  set unit(String value) => RealmObjectBase.set(this, 'unit', value);

  @override
  bool get isActive => RealmObjectBase.get<bool>(this, 'isActive') as bool;
  @override
  set isActive(bool value) => RealmObjectBase.set(this, 'isActive', value);

  @override
  RealmList<PriceTier> get prices =>
      RealmObjectBase.get<PriceTier>(this, 'prices') as RealmList<PriceTier>;
  @override
  set prices(covariant RealmList<PriceTier> value) =>
      throw RealmUnsupportedSetError();

  @override
  String? get imagePath =>
      RealmObjectBase.get<String>(this, 'imagePath') as String?;
  @override
  set imagePath(String? value) => RealmObjectBase.set(this, 'imagePath', value);

  @override
  Stream<RealmObjectChanges<Product>> get changes =>
      RealmObjectBase.getChanges<Product>(this);

  @override
  Stream<RealmObjectChanges<Product>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Product>(this, keyPaths);

  @override
  Product freeze() => RealmObjectBase.freezeObject<Product>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'barcode': barcode.toEJson(),
      'category': category.toEJson(),
      'brand': brand.toEJson(),
      'costPrice': costPrice.toEJson(),
      'stock': stock.toEJson(),
      'minStock': minStock.toEJson(),
      'unit': unit.toEJson(),
      'isActive': isActive.toEJson(),
      'prices': prices.toEJson(),
      'imagePath': imagePath.toEJson(),
    };
  }

  static EJsonValue _toEJson(Product value) => value.toEJson();
  static Product _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'barcode': EJsonValue barcode,
        'category': EJsonValue category,
        'brand': EJsonValue brand,
        'costPrice': EJsonValue costPrice,
        'stock': EJsonValue stock,
        'minStock': EJsonValue minStock,
        'unit': EJsonValue unit,
        'isActive': EJsonValue isActive,
      } =>
        Product(
          fromEJson(id),
          fromEJson(name),
          fromEJson(barcode),
          fromEJson(category),
          fromEJson(brand),
          fromEJson(costPrice),
          fromEJson(stock),
          fromEJson(minStock),
          fromEJson(unit),
          fromEJson(isActive),
          prices: fromEJson(ejson['prices']),
          imagePath: fromEJson(ejson['imagePath']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Product._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Product, 'Product', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('barcode', RealmPropertyType.string),
      SchemaProperty('category', RealmPropertyType.string),
      SchemaProperty('brand', RealmPropertyType.string),
      SchemaProperty('costPrice', RealmPropertyType.double),
      SchemaProperty('stock', RealmPropertyType.int),
      SchemaProperty('minStock', RealmPropertyType.int),
      SchemaProperty('unit', RealmPropertyType.string),
      SchemaProperty('isActive', RealmPropertyType.bool),
      SchemaProperty(
        'prices',
        RealmPropertyType.object,
        linkTarget: 'PriceTier',
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty('imagePath', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
