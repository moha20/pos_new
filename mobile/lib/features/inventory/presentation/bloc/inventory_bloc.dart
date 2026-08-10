import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../core/di/di.dart';
import '../../../../services/activity_log_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

// Events
abstract class InventoryEvent {}

class LoadInventory extends InventoryEvent {}

class SearchInventory extends InventoryEvent {
  final String query;
  SearchInventory(this.query);
}

class AddProductEvent extends InventoryEvent {
  final ProductEntity product;
  AddProductEvent(this.product);
}

class UpdateProductEvent extends InventoryEvent {
  final ProductEntity product;
  UpdateProductEvent(this.product);
}

class DeleteProductEvent extends InventoryEvent {
  final String id;
  DeleteProductEvent(this.id);
}

class DeleteMultipleProductsEvent extends InventoryEvent {
  final List<String> ids;
  DeleteMultipleProductsEvent(this.ids);
}

// States
abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<ProductEntity> allProducts;
  final List<ProductEntity> filteredProducts;
  InventoryLoaded(this.allProducts, this.filteredProducts);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}

// Bloc
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final ProductRepository productRepository;
  List<ProductEntity> _allProducts = [];

  InventoryBloc(this.productRepository) : super(InventoryInitial()) {
    on<LoadInventory>((event, emit) async {
      emit(InventoryLoading());
      try {
        _allProducts = await productRepository.getProducts();
        emit(InventoryLoaded(_allProducts, _allProducts));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });

    on<SearchInventory>((event, emit) {
      if (state is InventoryLoaded) {
        final query = event.query.toLowerCase().trim();
        if (query.isEmpty) {
          emit(InventoryLoaded(_allProducts, _allProducts));
        } else {
          final filtered = _allProducts.where((p) =>
              p.id.toLowerCase().contains(query) ||
              p.name.toLowerCase().contains(query) ||
              p.barcode.contains(query) ||
              p.category.toLowerCase().contains(query) ||
              p.brand.toLowerCase().contains(query)).toList();
          emit(InventoryLoaded(_allProducts, filtered));
        }
      }
    });

    on<AddProductEvent>((event, emit) async {
      emit(InventoryLoading());
      try {
        await productRepository.addProduct(event.product);
        _allProducts = await productRepository.getProducts();
        emit(InventoryLoaded(_allProducts, _allProducts));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'product_added',
            category: 'inventory',
            description: 'Added product: ${event.product.name} (Barcode: ${event.product.barcode})',
            userId: user?.username ?? 'system',
            referenceId: event.product.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });

    on<UpdateProductEvent>((event, emit) async {
      emit(InventoryLoading());
      try {
        await productRepository.updateProduct(event.product);
        _allProducts = await productRepository.getProducts();
        emit(InventoryLoaded(_allProducts, _allProducts));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'product_edited',
            category: 'inventory',
            description: 'Updated product: ${event.product.name}',
            userId: user?.username ?? 'system',
            referenceId: event.product.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });

    on<DeleteProductEvent>((event, emit) async {
      emit(InventoryLoading());
      try {
        String prodName = event.id;
        try {
          final existing = _allProducts.firstWhere((p) => p.id == event.id);
          prodName = existing.name;
        } catch (_) {}
        await productRepository.deleteProduct(event.id);
        _allProducts = await productRepository.getProducts();
        emit(InventoryLoaded(_allProducts, _allProducts));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'product_deleted',
            category: 'inventory',
            description: 'Deleted product: $prodName',
            userId: user?.username ?? 'system',
            referenceId: event.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });

    on<DeleteMultipleProductsEvent>((event, emit) async {
      emit(InventoryLoading());
      try {
        final List<String> deletedNames = [];
        for (final id in event.ids) {
          try {
            final existing = _allProducts.firstWhere((p) => p.id == id);
            deletedNames.add(existing.name);
          } catch (_) {
            deletedNames.add(id);
          }
          await productRepository.deleteProduct(id);
        }
        _allProducts = await productRepository.getProducts();
        emit(InventoryLoaded(_allProducts, _allProducts));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'product_deleted',
            category: 'inventory',
            description: 'Deleted products: ${deletedNames.join(", ")}',
            userId: user?.username ?? 'system',
            referenceId: event.ids.join(","),
          );
        } catch (_) {}
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });
  }
}
