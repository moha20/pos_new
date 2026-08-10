class SaleItemEntity {
  final String productId;
  final String productName;
  final String barcode;
  final int qty;
  final double unitPrice;
  final double totalPrice;
  final String priceLevel; // 'retail' | 'salesman' | 'company' | 'wholesale'

  SaleItemEntity({
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.qty,
    required this.unitPrice,
    required this.totalPrice,
    required this.priceLevel,
  });
}

class SaleEntity {
  final String id;
  final String invoiceNumber;
  final DateTime createdAt;
  final List<SaleItemEntity> items;
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

  SaleEntity({
    required this.id,
    required this.invoiceNumber,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.customerId,
    required this.cashierId,
    required this.note,
    required this.amountPaid,
    required this.amountRemaining,
  });
}
