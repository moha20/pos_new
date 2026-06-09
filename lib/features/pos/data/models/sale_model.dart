import 'package:realm/realm.dart';
import '../../domain/entities/sale_entity.dart';

part 'sale_model.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class _SaleItem {
  late String productId;
  late String productName;
  late String barcode;
  late int qty;
  late double unitPrice;
  late double totalPrice;
  late String priceLevel; // 'retail' | 'salesman' | 'company' | 'wholesale'
}

@RealmModel()
class _Sale {
  @PrimaryKey()
  late ObjectId id;
  late String invoiceNumber;
  late DateTime createdAt;
  late List<_SaleItem> items;
  late double subtotal;
  late double discount;
  late double tax;
  late double total;
  late String paymentMethod; // 'cash' | 'card' | 'wallet'
  late String? customerId;
  late String cashierId;
  late String? note;
  late double amountPaid;
  late double amountRemaining;
}

extension SaleItemMapper on SaleItem {
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

extension SaleMapper on Sale {
  SaleEntity toEntity() {
    return SaleEntity(
      id: id.toString(),
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
