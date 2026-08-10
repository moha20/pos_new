import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../../inventory/domain/entities/product_entity.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import '../../../../core/di/di.dart';
import '../../../../services/activity_log_service.dart';
import '../../../../services/cloud_sync_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper class for cart item
class CartItem {
  final ProductEntity product;
  final int qty;
  final double unitPrice;
  final String priceLevel; // 'retail' | 'salesman' | 'company' | 'wholesale'

  CartItem({
    required this.product,
    required this.qty,
    required this.unitPrice,
    required this.priceLevel,
  });

  CartItem copyWith({
    ProductEntity? product,
    int? qty,
    double? unitPrice,
    String? priceLevel,
  }) {
    return CartItem(
      product: product ?? this.product,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      priceLevel: priceLevel ?? this.priceLevel,
    );
  }

  double get totalPrice => qty * unitPrice;
}

enum POSStatus { initial, loading, cartUpdated, checkoutSuccess, error }

// State
class POSState {
  final List<CartItem> cartItems;
  final CustomerEntity? selectedCustomer;
  final double discount;
  final double taxRate;
  final String invoiceNumber;
  final POSStatus status;
  final String? errorMessage;
  final SaleEntity? lastCompletedSale; // For printable invoice rendering after checkout

  POSState({
    required this.cartItems,
    this.selectedCustomer,
    required this.discount,
    required this.taxRate,
    required this.invoiceNumber,
    required this.status,
    this.errorMessage,
    this.lastCompletedSale,
  });

  POSState copyWith({
    List<CartItem>? cartItems,
    CustomerEntity? Function()? selectedCustomer,
    double? discount,
    double? taxRate,
    String? invoiceNumber,
    POSStatus? status,
    String? errorMessage,
    SaleEntity? lastCompletedSale,
  }) {
    return POSState(
      cartItems: cartItems ?? this.cartItems,
      selectedCustomer: selectedCustomer != null ? selectedCustomer() : this.selectedCustomer,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      status: status ?? this.status,
      errorMessage: errorMessage,
      lastCompletedSale: lastCompletedSale ?? this.lastCompletedSale,
    );
  }

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get taxAmount => (subtotal - discount) * (taxRate / 100);
  double get total => subtotal - discount + taxAmount;
}

// Events
abstract class POSEvent {}

class POSInit extends POSEvent {}

class POSAddProduct extends POSEvent {
  final ProductEntity product;
  POSAddProduct(this.product);
}

class POSRemoveProduct extends POSEvent {
  final String productId;
  POSRemoveProduct(this.productId);
}

class POSUpdateQty extends POSEvent {
  final String productId;
  final int qty;
  POSUpdateQty(this.productId, this.qty);
}

class POSUpdateItemPriceLevel extends POSEvent {
  final String productId;
  final String level;
  POSUpdateItemPriceLevel(this.productId, this.level);
}

class POSUpdateItemPrice extends POSEvent {
  final String productId;
  final double unitPrice;
  POSUpdateItemPrice(this.productId, this.unitPrice);
}

class POSSelectCustomer extends POSEvent {
  final CustomerEntity? customer;
  POSSelectCustomer(this.customer);
}

class POSSetDiscount extends POSEvent {
  final double discount;
  POSSetDiscount(this.discount);
}

class POSSetTaxRate extends POSEvent {
  final double taxRate;
  POSSetTaxRate(this.taxRate);
}

class POSScanBarcode extends POSEvent {
  final String barcode;
  POSScanBarcode(this.barcode);
}

class POSClearCart extends POSEvent {}

class POSCheckout extends POSEvent {
  final String paymentMethod;
  final String cashierId;
  final String? note;
  final double amountPaid;
  final double amountRemaining;
  POSCheckout(this.paymentMethod, this.cashierId, this.note, this.amountPaid, this.amountRemaining);
}

// Bloc
class POSBloc extends Bloc<POSEvent, POSState> {
  final SaleRepository saleRepository;
  final ProductRepository productRepository;
  final CustomerRepository customerRepository;

  POSBloc({
    required this.saleRepository,
    required this.productRepository,
    required this.customerRepository,
  }) : super(POSState(
          cartItems: [],
          discount: 0.0,
          taxRate: Gravity.find<SharedPreferences>().getDouble('tax_percent') ?? 0.0,
          invoiceNumber: '',
          status: POSStatus.initial,
        )) {
    on<POSInit>((event, emit) async {
      final nextNum = await saleRepository.getNextInvoiceNumber();
      final currentTax = Gravity.find<SharedPreferences>().getDouble('tax_percent') ?? 0.0;
      emit(state.copyWith(
        invoiceNumber: '#$nextNum',
        taxRate: currentTax,
      ));
    });

    on<POSAddProduct>((event, emit) {
      final level = state.selectedCustomer?.priceLevel ?? 'retail';
      final existingIndex = state.cartItems.indexWhere((i) => i.product.id == event.product.id);
      final list = List<CartItem>.from(state.cartItems);

      if (existingIndex >= 0) {
        final existingItem = list[existingIndex];
        list[existingIndex] = existingItem.copyWith(qty: existingItem.qty + 1);
      } else {
        list.add(CartItem(
          product: event.product,
          qty: 1,
          unitPrice: event.product.priceFor(level),
          priceLevel: level,
        ));
      }

      emit(state.copyWith(cartItems: list, status: POSStatus.cartUpdated));
    });

    on<POSRemoveProduct>((event, emit) {
      final list = state.cartItems.where((i) => i.product.id != event.productId).toList();
      emit(state.copyWith(cartItems: list, status: POSStatus.cartUpdated));
    });

    on<POSUpdateQty>((event, emit) {
      final list = List<CartItem>.from(state.cartItems);
      final idx = list.indexWhere((i) => i.product.id == event.productId);
      if (idx >= 0) {
        if (event.qty <= 0) {
          list.removeAt(idx);
        } else {
          list[idx] = list[idx].copyWith(qty: event.qty);
        }
        emit(state.copyWith(cartItems: list, status: POSStatus.cartUpdated));
      }
    });

    on<POSUpdateItemPriceLevel>((event, emit) {
      final list = List<CartItem>.from(state.cartItems);
      final idx = list.indexWhere((i) => i.product.id == event.productId);
      if (idx >= 0) {
        final item = list[idx];
        final newPrice = item.product.priceFor(event.level);
        list[idx] = item.copyWith(priceLevel: event.level, unitPrice: newPrice);
        emit(state.copyWith(cartItems: list, status: POSStatus.cartUpdated));
      }
    });

    on<POSUpdateItemPrice>((event, emit) {
      final list = List<CartItem>.from(state.cartItems);
      final idx = list.indexWhere((i) => i.product.id == event.productId);
      if (idx >= 0) {
        final item = list[idx];
        list[idx] = item.copyWith(unitPrice: event.unitPrice);
        emit(state.copyWith(cartItems: list, status: POSStatus.cartUpdated));
      }
    });

    on<POSSelectCustomer>((event, emit) {
      final level = event.customer?.priceLevel ?? 'retail';
      // Auto update price levels for all items in the cart
      final updatedCart = state.cartItems.map((item) {
        return item.copyWith(
          priceLevel: level,
          unitPrice: item.product.priceFor(level),
        );
      }).toList();

      emit(state.copyWith(
        selectedCustomer: () => event.customer,
        cartItems: updatedCart,
        status: POSStatus.cartUpdated,
      ));
    });

    on<POSSetDiscount>((event, emit) {
      emit(state.copyWith(discount: event.discount, status: POSStatus.cartUpdated));
    });

    on<POSSetTaxRate>((event, emit) {
      emit(state.copyWith(taxRate: event.taxRate, status: POSStatus.cartUpdated));
    });

    on<POSScanBarcode>((event, emit) async {
      emit(state.copyWith(status: POSStatus.loading));
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
          add(POSAddProduct(product));
        } else {
          emit(state.copyWith(status: POSStatus.error, errorMessage: 'product_not_found'));
        }
      } catch (e) {
        emit(state.copyWith(status: POSStatus.error, errorMessage: e.toString()));
      }
    });

    on<POSClearCart>((event, emit) async {
      final nextNum = await saleRepository.getNextInvoiceNumber();
      final currentTax = Gravity.find<SharedPreferences>().getDouble('tax_percent') ?? 0.0;
      emit(POSState(
        cartItems: [],
        selectedCustomer: null,
        discount: 0.0,
        taxRate: currentTax,
        invoiceNumber: '#$nextNum',
        status: POSStatus.initial,
      ));
      try {
        final user = Gravity.find<AuthBloc>().currentUser;
        Gravity.find<ActivityLogService>().log(
          action: 'clear_cart',
          category: 'pos',
          description: 'Cart was cleared',
          userId: user?.username ?? 'system',
        );
      } catch (_) {}
    });

    on<POSCheckout>((event, emit) async {
      if (state.cartItems.isEmpty) {
        emit(state.copyWith(status: POSStatus.error, errorMessage: 'cart_empty'));
        return;
      }
      emit(state.copyWith(status: POSStatus.loading));
      try {
        final saleItems = state.cartItems.map((i) => SaleItemEntity(
          productId: i.product.id,
          productName: i.product.name,
          barcode: i.product.barcode,
          qty: i.qty,
          unitPrice: i.unitPrice,
          totalPrice: i.totalPrice,
          priceLevel: i.priceLevel,
        )).toList();

        final rawInvoiceNum = state.invoiceNumber.replaceAll('#', '');

        final sale = SaleEntity(
          id: '', // Will be generated by Realm
          invoiceNumber: rawInvoiceNum,
          createdAt: DateTime.now(),
          items: saleItems,
          subtotal: state.subtotal,
          discount: state.discount,
          tax: state.taxAmount,
          total: state.total,
          paymentMethod: event.paymentMethod,
          customerId: state.selectedCustomer?.id,
          cashierId: event.cashierId,
          note: event.note,
          amountPaid: event.amountPaid,
          amountRemaining: event.amountRemaining,
        );

        // Save sale and deduct stock
        await saleRepository.saveSale(sale);

        // Upload sale to Cloud Sync for online admin access
        try {
          final cloudSync = Gravity.find<CloudSyncService>();
          await cloudSync.uploadSale(sale);
        } catch (_) {}

        // Update customer total purchases and balance if customer selected
        if (state.selectedCustomer != null) {
          await customerRepository.updatePurchases(
            state.selectedCustomer!.id,
            state.total,
            event.amountRemaining,
          );
        }

        emit(state.copyWith(
          status: POSStatus.checkoutSuccess,
          lastCompletedSale: sale,
        ));

        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'sale_completed',
            category: 'pos',
            description: 'Completed sale with invoice #$rawInvoiceNum, total: ${state.total.toStringAsFixed(2)} EGP',
            userId: user?.username ?? event.cashierId,
            referenceId: rawInvoiceNum,
          );
        } catch (_) {}
      } catch (e) {
        emit(state.copyWith(status: POSStatus.error, errorMessage: e.toString()));
      }
    });
  }
}
