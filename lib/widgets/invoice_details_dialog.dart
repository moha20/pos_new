import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/pos/domain/entities/sale_entity.dart';

void showInvoiceDetailsDialog(
  BuildContext context,
  SaleEntity sale,
  String customerName,
) {
  context.push(
    '/invoice-details',
    extra: {
      'sale': sale,
      'customerName': customerName,
    },
  );
}
