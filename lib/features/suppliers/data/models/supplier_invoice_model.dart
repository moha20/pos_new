import '../../domain/entities/supplier_invoice_entity.dart';

class SupplierInvoiceItemModel {
  final String productId;
  final String productName;
  final String barcode;
  final int qty;
  final double unitCostPrice;
  final double totalPrice;

  SupplierInvoiceItemModel({
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.qty,
    required this.unitCostPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'barcode': barcode,
        'qty': qty,
        'unitCostPrice': unitCostPrice,
        'totalPrice': totalPrice,
      };

  factory SupplierInvoiceItemModel.fromMap(Map<dynamic, dynamic> map) =>
      SupplierInvoiceItemModel(
        productId: map['productId'] as String,
        productName: map['productName'] as String,
        barcode: map['barcode'] as String,
        qty: (map['qty'] as num).toInt(),
        unitCostPrice: (map['unitCostPrice'] as num).toDouble(),
        totalPrice: (map['totalPrice'] as num).toDouble(),
      );

  SupplierInvoiceItemEntity toEntity() => SupplierInvoiceItemEntity(
        productId: productId,
        productName: productName,
        barcode: barcode,
        qty: qty,
        unitCostPrice: unitCostPrice,
        totalPrice: totalPrice,
      );
}

class SupplierInvoiceModel {
  final String id;
  final String invoiceNumber;
  final DateTime createdAt;
  final List<SupplierInvoiceItemModel> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod;
  final String supplierId;
  final String cashierId;
  final String? note;
  final double amountPaid;
  final double amountRemaining;

  SupplierInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.supplierId,
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
        'supplierId': supplierId,
        'cashierId': cashierId,
        'note': note,
        'amountPaid': amountPaid,
        'amountRemaining': amountRemaining,
      };

  factory SupplierInvoiceModel.fromMap(Map<dynamic, dynamic> map) =>
      SupplierInvoiceModel(
        id: map['id'] as String,
        invoiceNumber: map['invoiceNumber'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        items: (map['items'] as List)
            .map((i) =>
                SupplierInvoiceItemModel.fromMap(i as Map<dynamic, dynamic>))
            .toList(),
        subtotal: (map['subtotal'] as num).toDouble(),
        discount: (map['discount'] as num).toDouble(),
        tax: (map['tax'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
        paymentMethod: map['paymentMethod'] as String,
        supplierId: map['supplierId'] as String,
        cashierId: map['cashierId'] as String,
        note: map['note'] as String?,
        amountPaid: (map['amountPaid'] as num).toDouble(),
        amountRemaining: (map['amountRemaining'] as num).toDouble(),
      );

  SupplierInvoiceEntity toEntity() => SupplierInvoiceEntity(
        id: id,
        invoiceNumber: invoiceNumber,
        createdAt: createdAt,
        items: items.map((i) => i.toEntity()).toList(),
        subtotal: subtotal,
        discount: discount,
        tax: tax,
        total: total,
        paymentMethod: paymentMethod,
        supplierId: supplierId,
        cashierId: cashierId,
        note: note,
        amountPaid: amountPaid,
        amountRemaining: amountRemaining,
      );
}
