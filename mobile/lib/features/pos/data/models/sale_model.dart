import '../../domain/entities/sale_entity.dart';

class SaleItemModel {
  final String productId;
  final String productName;
  final String barcode;
  final int qty;
  final double unitPrice;
  final double totalPrice;
  final String priceLevel; // 'retail' | 'salesman' | 'company' | 'wholesale'

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.qty,
    required this.unitPrice,
    required this.totalPrice,
    required this.priceLevel,
  });

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'barcode': barcode,
    'qty': qty,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
    'priceLevel': priceLevel,
  };

  factory SaleItemModel.fromMap(Map<dynamic, dynamic> map) => SaleItemModel(
    productId: map['productId'] as String,
    productName: map['productName'] as String,
    barcode: map['barcode'] as String,
    qty: (map['qty'] as num).toInt(),
    unitPrice: (map['unitPrice'] as num).toDouble(),
    totalPrice: (map['totalPrice'] as num).toDouble(),
    priceLevel: map['priceLevel'] as String,
  );

  SaleItemEntity toEntity() {
    return SaleItemEntity(
      productId: productId,
      productName: productName,
      barcode: barcode,
      qty: qty,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      priceLevel: priceLevel,
    );
  }
}

class SaleModel {
  final String id;
  final String invoiceNumber;
  final DateTime createdAt;
  final List<SaleItemModel> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod; // 'cash' | 'card' | 'wallet'
  final String? customerId;
  final String cashierId;
  final String? note;
  final double amountPaid;
  final double amountRemaining;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.customerId,
    required this.cashierId,
    this.note,
    required this.amountPaid,
    required this.amountRemaining,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'invoiceNumber': invoiceNumber,
    'createdAt': createdAt.toIso8601String(),
    'items': items.map((i) => i.toMap()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'tax': tax,
    'total': total,
    'paymentMethod': paymentMethod,
    'customerId': customerId,
    'cashierId': cashierId,
    'note': note,
    'amountPaid': amountPaid,
    'amountRemaining': amountRemaining,
  };

  factory SaleModel.fromMap(Map<dynamic, dynamic> map) => SaleModel(
    id: map['id'] as String,
    invoiceNumber: map['invoiceNumber'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    items: (map['items'] as List).map((i) => SaleItemModel.fromMap(i as Map<dynamic, dynamic>)).toList(),
    subtotal: (map['subtotal'] as num).toDouble(),
    discount: (map['discount'] as num).toDouble(),
    tax: (map['tax'] as num).toDouble(),
    total: (map['total'] as num).toDouble(),
    paymentMethod: map['paymentMethod'] as String,
    customerId: map['customerId'] as String?,
    cashierId: map['cashierId'] as String,
    note: map['note'] as String?,
    amountPaid: (map['amountPaid'] as num).toDouble(),
    amountRemaining: (map['amountRemaining'] as num).toDouble(),
  );

  SaleEntity toEntity() {
    return SaleEntity(
      id: id,
      invoiceNumber: invoiceNumber,
      createdAt: createdAt,
      items: items.map((i) => i.toEntity()).toList(),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      customerId: customerId,
      cashierId: cashierId,
      note: note,
      amountPaid: amountPaid,
      amountRemaining: amountRemaining,
    );
  }
}
