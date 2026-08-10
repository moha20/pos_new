import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/supplier_invoice_entity.dart';
import '../../domain/repositories/supplier_invoice_repository.dart';
import '../../../inventory/domain/entities/product_entity.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../../../core/di/di.dart';
import '../../../../services/activity_log_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierInvoiceCartItem {
  final ProductEntity product;
  final int qty;
  final double unitCostPrice;

  SupplierInvoiceCartItem({
    required this.product,
    required this.qty,
    required this.unitCostPrice,
  });

  SupplierInvoiceCartItem copyWith({
    ProductEntity? product,
    int? qty,
    double? unitCostPrice,
  }) {
    return SupplierInvoiceCartItem(
      product: product ?? this.product,
      qty: qty ?? this.qty,
      unitCostPrice: unitCostPrice ?? this.unitCostPrice,
    );
  }

  double get totalPrice => qty * unitCostPrice;
}

enum SupplierInvoiceStatus { initial, loading, cartUpdated, checkoutSuccess, error }

class SupplierInvoiceState {
  final List<SupplierInvoiceCartItem> cartItems;
  final SupplierEntity? selectedSupplier;
  final double discount;
  final double taxRate;
  final String invoiceNumber;
  final SupplierInvoiceStatus status;
  final String? errorMessage;
  final SupplierInvoiceEntity? lastCompletedInvoice;

  SupplierInvoiceState({
    required this.cartItems,
    this.selectedSupplier,
    required this.discount,
    required this.taxRate,
    required this.invoiceNumber,
    required this.status,
    this.errorMessage,
    this.lastCompletedInvoice,
  });

  SupplierInvoiceState copyWith({
    List<SupplierInvoiceCartItem>? cartItems,
    SupplierEntity? Function()? selectedSupplier,
    double? discount,
    double? taxRate,
    String? invoiceNumber,
    SupplierInvoiceStatus? status,
    String? errorMessage,
    SupplierInvoiceEntity? lastCompletedInvoice,
  }) {
    return SupplierInvoiceState(
      cartItems: cartItems ?? this.cartItems,
      selectedSupplier: selectedSupplier != null ? selectedSupplier() : this.selectedSupplier,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      status: status ?? this.status,
      errorMessage: errorMessage,
      lastCompletedInvoice: lastCompletedInvoice ?? this.lastCompletedInvoice,
    );
  }

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get taxAmount => (subtotal - discount) * (taxRate / 100);
  double get total => subtotal - discount + taxAmount;
}

// Events
abstract class SupplierInvoiceEvent {}

class SupplierInvoiceInit extends SupplierInvoiceEvent {}

class SupplierInvoiceAddProduct extends SupplierInvoiceEvent {
  final ProductEntity product;
  SupplierInvoiceAddProduct(this.product);
}

class SupplierInvoiceRemoveProduct extends SupplierInvoiceEvent {
  final String productId;
  SupplierInvoiceRemoveProduct(this.productId);
}

class SupplierInvoiceUpdateQty extends SupplierInvoiceEvent {
  final String productId;
  final int qty;
  SupplierInvoiceUpdateQty(this.productId, this.qty);
}

class SupplierInvoiceUpdateCostPrice extends SupplierInvoiceEvent {
  final String productId;
  final double costPrice;
  SupplierInvoiceUpdateCostPrice(this.productId, this.costPrice);
}

class SupplierInvoiceSelectSupplier extends SupplierInvoiceEvent {
  final SupplierEntity? supplier;
  SupplierInvoiceSelectSupplier(this.supplier);
}

class SupplierInvoiceSetDiscount extends SupplierInvoiceEvent {
  final double discount;
  SupplierInvoiceSetDiscount(this.discount);
}

class SupplierInvoiceSetTaxRate extends SupplierInvoiceEvent {
  final double taxRate;
  SupplierInvoiceSetTaxRate(this.taxRate);
}

class SupplierInvoiceScanBarcode extends SupplierInvoiceEvent {
  final String barcode;
  SupplierInvoiceScanBarcode(this.barcode);
}

class SupplierInvoiceClearCart extends SupplierInvoiceEvent {}

class SupplierInvoiceCheckout extends SupplierInvoiceEvent {
  final String paymentMethod;
  final String cashierId;
  final String? note;
  final double amountPaid;
  final double amountRemaining;
  SupplierInvoiceCheckout(
    this.paymentMethod,
    this.cashierId,
    this.note,
    this.amountPaid,
    this.amountRemaining,
  );
}

// Bloc
class SupplierInvoiceBloc extends Bloc<SupplierInvoiceEvent, SupplierInvoiceState> {
  final SupplierInvoiceRepository supplierInvoiceRepository;
  final ProductRepository productRepository;
  final SupplierRepository supplierRepository;

  SupplierInvoiceBloc({
    required this.supplierInvoiceRepository,
    required this.productRepository,
    required this.supplierRepository,
  }) : super(SupplierInvoiceState(
          cartItems: [],
          discount: 0.0,
          taxRate: Gravity.find<SharedPreferences>().getDouble('tax_percent') ?? 0.0,
          invoiceNumber: '',
          status: SupplierInvoiceStatus.initial,
        )) {
    on<SupplierInvoiceInit>((event, emit) async {
      final nextNum = await supplierInvoiceRepository.getNextInvoiceNumber();
      final currentTax = Gravity.find<SharedPreferences>().getDouble('tax_percent') ?? 0.0;
      emit(state.copyWith(
        invoiceNumber: '#$nextNum',
        taxRate: currentTax,
      ));
    });

    on<SupplierInvoiceAddProduct>((event, emit) {
      final existingIndex = state.cartItems.indexWhere((i) => i.product.id == event.product.id);
      final list = List<SupplierInvoiceCartItem>.from(state.cartItems);

      if (existingIndex >= 0) {
        final existingItem = list[existingIndex];
        list[existingIndex] = existingItem.copyWith(qty: existingItem.qty + 1);
      } else {
        list.add(SupplierInvoiceCartItem(
          product: event.product,
          qty: 1,
          unitCostPrice: event.product.costPrice,
        ));
      }

      emit(state.copyWith(cartItems: list, status: SupplierInvoiceStatus.cartUpdated));
    });

    on<SupplierInvoiceRemoveProduct>((event, emit) {
      final list = state.cartItems.where((i) => i.product.id != event.productId).toList();
      emit(state.copyWith(cartItems: list, status: SupplierInvoiceStatus.cartUpdated));
    });

    on<SupplierInvoiceUpdateQty>((event, emit) {
      final list = List<SupplierInvoiceCartItem>.from(state.cartItems);
      final idx = list.indexWhere((i) => i.product.id == event.productId);
      if (idx >= 0) {
        if (event.qty <= 0) {
          list.removeAt(idx);
        } else {
          list[idx] = list[idx].copyWith(qty: event.qty);
        }
        emit(state.copyWith(cartItems: list, status: SupplierInvoiceStatus.cartUpdated));
      }
    });

    on<SupplierInvoiceUpdateCostPrice>((event, emit) {
      final list = List<SupplierInvoiceCartItem>.from(state.cartItems);
      final idx = list.indexWhere((i) => i.product.id == event.productId);
      if (idx >= 0) {
        list[idx] = list[idx].copyWith(unitCostPrice: event.costPrice);
        emit(state.copyWith(cartItems: list, status: SupplierInvoiceStatus.cartUpdated));
      }
    });

    on<SupplierInvoiceSelectSupplier>((event, emit) {
      emit(state.copyWith(
        selectedSupplier: () => event.supplier,
        status: SupplierInvoiceStatus.cartUpdated,
      ));
    });

    on<SupplierInvoiceSetDiscount>((event, emit) {
      emit(state.copyWith(discount: event.discount, status: SupplierInvoiceStatus.cartUpdated));
    });

    on<SupplierInvoiceSetTaxRate>((event, emit) {
      emit(state.copyWith(taxRate: event.taxRate, status: SupplierInvoiceStatus.cartUpdated));
    });

    on<SupplierInvoiceScanBarcode>((event, emit) async {
      emit(state.copyWith(status: SupplierInvoiceStatus.loading));
      try {
        ProductEntity? product;
        try {
          product = await productRepository.getProductByBarcode(event.barcode);
        } catch (_) {}
        if (product == null) {
          try {
            if (event.barcode.length == 24 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(event.barcode)) {
              product = await productRepository.getProductById(event.barcode);
            }
          } catch (_) {}
        }
        if (product != null && product.isActive) {
          add(SupplierInvoiceAddProduct(product));
        } else {
          emit(state.copyWith(status: SupplierInvoiceStatus.error, errorMessage: 'product_not_found'));
        }
      } catch (e) {
        emit(state.copyWith(status: SupplierInvoiceStatus.error, errorMessage: e.toString()));
      }
    });

    on<SupplierInvoiceClearCart>((event, emit) async {
      final nextNum = await supplierInvoiceRepository.getNextInvoiceNumber();
      final currentTax = Gravity.find<SharedPreferences>().getDouble('tax_percent') ?? 0.0;
      emit(SupplierInvoiceState(
        cartItems: [],
        selectedSupplier: null,
        discount: 0.0,
        taxRate: currentTax,
        invoiceNumber: '#$nextNum',
        status: SupplierInvoiceStatus.initial,
      ));
    });

    on<SupplierInvoiceCheckout>((event, emit) async {
      if (state.cartItems.isEmpty) {
        emit(state.copyWith(status: SupplierInvoiceStatus.error, errorMessage: 'cart_empty'));
        return;
      }
      if (state.selectedSupplier == null) {
        emit(state.copyWith(status: SupplierInvoiceStatus.error, errorMessage: 'select_supplier_required'));
        return;
      }
      emit(state.copyWith(status: SupplierInvoiceStatus.loading));
      try {
        final invoiceItems = state.cartItems.map((i) => SupplierInvoiceItemEntity(
          productId: i.product.id,
          productName: i.product.name,
          barcode: i.product.barcode,
          qty: i.qty,
          unitCostPrice: i.unitCostPrice,
          totalPrice: i.totalPrice,
        )).toList();

        final rawInvoiceNum = state.invoiceNumber.replaceAll('#', '');

        final invoice = SupplierInvoiceEntity(
          id: '', // Generated in repository impl
          invoiceNumber: rawInvoiceNum,
          createdAt: DateTime.now(),
          items: invoiceItems,
          subtotal: state.subtotal,
          discount: state.discount,
          tax: state.taxAmount,
          total: state.total,
          paymentMethod: event.paymentMethod,
          supplierId: state.selectedSupplier!.id,
          cashierId: event.cashierId,
          note: event.note,
          amountPaid: event.amountPaid,
          amountRemaining: event.amountRemaining,
        );

        // Save invoice, update product stock levels/costPrice, and update supplier balance/total orders
        await supplierInvoiceRepository.saveSupplierInvoice(invoice);

        emit(state.copyWith(
          status: SupplierInvoiceStatus.checkoutSuccess,
          lastCompletedInvoice: invoice,
        ));

        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'supplier_invoice_completed',
            category: 'supplier',
            description: 'Completed purchase invoice #$rawInvoiceNum from ${state.selectedSupplier!.name}, total: ${state.total.toStringAsFixed(2)} EGP',
            userId: user?.username ?? event.cashierId,
            referenceId: rawInvoiceNum,
          );
        } catch (_) {}
      } catch (e) {
        emit(state.copyWith(status: SupplierInvoiceStatus.error, errorMessage: e.toString()));
      }
    });
  }
}
