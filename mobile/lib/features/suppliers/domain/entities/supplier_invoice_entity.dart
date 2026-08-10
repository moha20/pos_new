class SupplierInvoiceItemEntity {
  final String productId;
  final String productName;
  final String barcode;
  final int qty;
  final double unitCostPrice;
  final double totalPrice;

  SupplierInvoiceItemEntity({
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.qty,
    required this.unitCostPrice,
    required this.totalPrice,
  });
}

class SupplierInvoiceEntity {
  final String id;
  final String invoiceNumber;
  final DateTime createdAt;
  final List<SupplierInvoiceItemEntity> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod; // 'cash' | 'card' | 'wallet'
  final String supplierId;
  final String cashierId;
  final String? note;
  final double amountPaid;
  final double amountRemaining;

  SupplierInvoiceEntity({
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
}
