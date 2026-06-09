// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class SaleItem extends _SaleItem
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  SaleItem(
    String productId,
    String productName,
    String barcode,
    int qty,
    double unitPrice,
    double totalPrice,
    String priceLevel,
  ) {
    RealmObjectBase.set(this, 'productId', productId);
    RealmObjectBase.set(this, 'productName', productName);
    RealmObjectBase.set(this, 'barcode', barcode);
    RealmObjectBase.set(this, 'qty', qty);
    RealmObjectBase.set(this, 'unitPrice', unitPrice);
    RealmObjectBase.set(this, 'totalPrice', totalPrice);
    RealmObjectBase.set(this, 'priceLevel', priceLevel);
  }

  SaleItem._();

  @override
  String get productId =>
      RealmObjectBase.get<String>(this, 'productId') as String;
  @override
  set productId(String value) => RealmObjectBase.set(this, 'productId', value);

  @override
  String get productName =>
      RealmObjectBase.get<String>(this, 'productName') as String;
  @override
  set productName(String value) =>
      RealmObjectBase.set(this, 'productName', value);

  @override
  String get barcode => RealmObjectBase.get<String>(this, 'barcode') as String;
  @override
  set barcode(String value) => RealmObjectBase.set(this, 'barcode', value);

  @override
  int get qty => RealmObjectBase.get<int>(this, 'qty') as int;
  @override
  set qty(int value) => RealmObjectBase.set(this, 'qty', value);

  @override
  double get unitPrice =>
      RealmObjectBase.get<double>(this, 'unitPrice') as double;
  @override
  set unitPrice(double value) => RealmObjectBase.set(this, 'unitPrice', value);

  @override
  double get totalPrice =>
      RealmObjectBase.get<double>(this, 'totalPrice') as double;
  @override
  set totalPrice(double value) =>
      RealmObjectBase.set(this, 'totalPrice', value);

  @override
  String get priceLevel =>
      RealmObjectBase.get<String>(this, 'priceLevel') as String;
  @override
  set priceLevel(String value) =>
      RealmObjectBase.set(this, 'priceLevel', value);

  @override
  Stream<RealmObjectChanges<SaleItem>> get changes =>
      RealmObjectBase.getChanges<SaleItem>(this);

  @override
  Stream<RealmObjectChanges<SaleItem>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<SaleItem>(this, keyPaths);

  @override
  SaleItem freeze() => RealmObjectBase.freezeObject<SaleItem>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'productId': productId.toEJson(),
      'productName': productName.toEJson(),
      'barcode': barcode.toEJson(),
      'qty': qty.toEJson(),
      'unitPrice': unitPrice.toEJson(),
      'totalPrice': totalPrice.toEJson(),
      'priceLevel': priceLevel.toEJson(),
    };
  }

  static EJsonValue _toEJson(SaleItem value) => value.toEJson();
  static SaleItem _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'productId': EJsonValue productId,
        'productName': EJsonValue productName,
        'barcode': EJsonValue barcode,
        'qty': EJsonValue qty,
        'unitPrice': EJsonValue unitPrice,
        'totalPrice': EJsonValue totalPrice,
        'priceLevel': EJsonValue priceLevel,
      } =>
        SaleItem(
          fromEJson(productId),
          fromEJson(productName),
          fromEJson(barcode),
          fromEJson(qty),
          fromEJson(unitPrice),
          fromEJson(totalPrice),
          fromEJson(priceLevel),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SaleItem._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.embeddedObject, SaleItem, 'SaleItem', [
      SchemaProperty('productId', RealmPropertyType.string),
      SchemaProperty('productName', RealmPropertyType.string),
      SchemaProperty('barcode', RealmPropertyType.string),
      SchemaProperty('qty', RealmPropertyType.int),
      SchemaProperty('unitPrice', RealmPropertyType.double),
      SchemaProperty('totalPrice', RealmPropertyType.double),
      SchemaProperty('priceLevel', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Sale extends _Sale with RealmEntity, RealmObjectBase, RealmObject {
  Sale(
    ObjectId id,
    String invoiceNumber,
    DateTime createdAt,
    double subtotal,
    double discount,
    double tax,
    double total,
    String paymentMethod,
    String cashierId,
    double amountPaid,
    double amountRemaining, {
    Iterable<SaleItem> items = const [],
    String? customerId,
    String? note,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'invoiceNumber', invoiceNumber);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set<RealmList<SaleItem>>(
      this,
      'items',
      RealmList<SaleItem>(items),
    );
    RealmObjectBase.set(this, 'subtotal', subtotal);
    RealmObjectBase.set(this, 'discount', discount);
    RealmObjectBase.set(this, 'tax', tax);
    RealmObjectBase.set(this, 'total', total);
    RealmObjectBase.set(this, 'paymentMethod', paymentMethod);
    RealmObjectBase.set(this, 'customerId', customerId);
    RealmObjectBase.set(this, 'cashierId', cashierId);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'amountPaid', amountPaid);
    RealmObjectBase.set(this, 'amountRemaining', amountRemaining);
  }

  Sale._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get invoiceNumber =>
      RealmObjectBase.get<String>(this, 'invoiceNumber') as String;
  @override
  set invoiceNumber(String value) =>
      RealmObjectBase.set(this, 'invoiceNumber', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  RealmList<SaleItem> get items =>
      RealmObjectBase.get<SaleItem>(this, 'items') as RealmList<SaleItem>;
  @override
  set items(covariant RealmList<SaleItem> value) =>
      throw RealmUnsupportedSetError();

  @override
  double get subtotal =>
      RealmObjectBase.get<double>(this, 'subtotal') as double;
  @override
  set subtotal(double value) => RealmObjectBase.set(this, 'subtotal', value);

  @override
  double get discount =>
      RealmObjectBase.get<double>(this, 'discount') as double;
  @override
  set discount(double value) => RealmObjectBase.set(this, 'discount', value);

  @override
  double get tax => RealmObjectBase.get<double>(this, 'tax') as double;
  @override
  set tax(double value) => RealmObjectBase.set(this, 'tax', value);

  @override
  double get total => RealmObjectBase.get<double>(this, 'total') as double;
  @override
  set total(double value) => RealmObjectBase.set(this, 'total', value);

  @override
  String get paymentMethod =>
      RealmObjectBase.get<String>(this, 'paymentMethod') as String;
  @override
  set paymentMethod(String value) =>
      RealmObjectBase.set(this, 'paymentMethod', value);

  @override
  String? get customerId =>
      RealmObjectBase.get<String>(this, 'customerId') as String?;
  @override
  set customerId(String? value) =>
      RealmObjectBase.set(this, 'customerId', value);

  @override
  String get cashierId =>
      RealmObjectBase.get<String>(this, 'cashierId') as String;
  @override
  set cashierId(String value) => RealmObjectBase.set(this, 'cashierId', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  double get amountPaid =>
      RealmObjectBase.get<double>(this, 'amountPaid') as double;
  @override
  set amountPaid(double value) =>
      RealmObjectBase.set(this, 'amountPaid', value);

  @override
  double get amountRemaining =>
      RealmObjectBase.get<double>(this, 'amountRemaining') as double;
  @override
  set amountRemaining(double value) =>
      RealmObjectBase.set(this, 'amountRemaining', value);

  @override
  Stream<RealmObjectChanges<Sale>> get changes =>
      RealmObjectBase.getChanges<Sale>(this);

  @override
  Stream<RealmObjectChanges<Sale>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Sale>(this, keyPaths);

  @override
  Sale freeze() => RealmObjectBase.freezeObject<Sale>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'invoiceNumber': invoiceNumber.toEJson(),
      'createdAt': createdAt.toEJson(),
      'items': items.toEJson(),
      'subtotal': subtotal.toEJson(),
      'discount': discount.toEJson(),
      'tax': tax.toEJson(),
      'total': total.toEJson(),
      'paymentMethod': paymentMethod.toEJson(),
      'customerId': customerId.toEJson(),
      'cashierId': cashierId.toEJson(),
      'note': note.toEJson(),
      'amountPaid': amountPaid.toEJson(),
      'amountRemaining': amountRemaining.toEJson(),
    };
  }

  static EJsonValue _toEJson(Sale value) => value.toEJson();
  static Sale _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'invoiceNumber': EJsonValue invoiceNumber,
        'createdAt': EJsonValue createdAt,
        'subtotal': EJsonValue subtotal,
        'discount': EJsonValue discount,
        'tax': EJsonValue tax,
        'total': EJsonValue total,
        'paymentMethod': EJsonValue paymentMethod,
        'cashierId': EJsonValue cashierId,
        'amountPaid': EJsonValue amountPaid,
        'amountRemaining': EJsonValue amountRemaining,
      } =>
        Sale(
          fromEJson(id),
          fromEJson(invoiceNumber),
          fromEJson(createdAt),
          fromEJson(subtotal),
          fromEJson(discount),
          fromEJson(tax),
          fromEJson(total),
          fromEJson(paymentMethod),
          fromEJson(cashierId),
          fromEJson(amountPaid),
          fromEJson(amountRemaining),
          items: fromEJson(ejson['items']),
          customerId: fromEJson(ejson['customerId']),
          note: fromEJson(ejson['note']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Sale._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Sale, 'Sale', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('invoiceNumber', RealmPropertyType.string),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty(
        'items',
        RealmPropertyType.object,
        linkTarget: 'SaleItem',
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty('subtotal', RealmPropertyType.double),
      SchemaProperty('discount', RealmPropertyType.double),
      SchemaProperty('tax', RealmPropertyType.double),
      SchemaProperty('total', RealmPropertyType.double),
      SchemaProperty('paymentMethod', RealmPropertyType.string),
      SchemaProperty('customerId', RealmPropertyType.string, optional: true),
      SchemaProperty('cashierId', RealmPropertyType.string),
      SchemaProperty('note', RealmPropertyType.string, optional: true),
      SchemaProperty('amountPaid', RealmPropertyType.double),
      SchemaProperty('amountRemaining', RealmPropertyType.double),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
