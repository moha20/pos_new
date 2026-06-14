import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../../../core/di/di.dart';
import '../../../../services/activity_log_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

// Events
abstract class SupplierEvent {}

class LoadSuppliers extends SupplierEvent {}

class SearchSuppliers extends SupplierEvent {
  final String query;
  SearchSuppliers(this.query);
}

class AddSupplierEvent extends SupplierEvent {
  final SupplierEntity supplier;
  AddSupplierEvent(this.supplier);
}

class UpdateSupplierEvent extends SupplierEvent {
  final SupplierEntity supplier;
  UpdateSupplierEvent(this.supplier);
}

class DeleteSupplierEvent extends SupplierEvent {
  final String id;
  DeleteSupplierEvent(this.id);
}

class DeleteMultipleSuppliersEvent extends SupplierEvent {
  final List<String> ids;
  DeleteMultipleSuppliersEvent(this.ids);
}

// States
abstract class SupplierState {}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<SupplierEntity> allSuppliers;
  final List<SupplierEntity> filteredSuppliers;
  SupplierLoaded(this.allSuppliers, this.filteredSuppliers);
}

class SupplierError extends SupplierState {
  final String message;
  SupplierError(this.message);
}

// Bloc
class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierRepository supplierRepository;
  List<SupplierEntity> _allSuppliers = [];

  SupplierBloc(this.supplierRepository) : super(SupplierInitial()) {
    on<LoadSuppliers>((event, emit) async {
      emit(SupplierLoading());
      try {
        _allSuppliers = await supplierRepository.getSuppliers();
        emit(SupplierLoaded(_allSuppliers, _allSuppliers));
      } catch (e) {
        emit(SupplierError(e.toString()));
      }
    });

    on<SearchSuppliers>((event, emit) {
      if (state is SupplierLoaded) {
        final query = event.query.toLowerCase().trim();
        if (query.isEmpty) {
          emit(SupplierLoaded(_allSuppliers, _allSuppliers));
        } else {
          final filtered = _allSuppliers.where((s) =>
              s.name.toLowerCase().contains(query) ||
              s.phone.contains(query) ||
              s.company.toLowerCase().contains(query)).toList();
          emit(SupplierLoaded(_allSuppliers, filtered));
        }
      }
    });

    on<AddSupplierEvent>((event, emit) async {
      emit(SupplierLoading());
      try {
        await supplierRepository.addSupplier(event.supplier);
        _allSuppliers = await supplierRepository.getSuppliers();
        emit(SupplierLoaded(_allSuppliers, _allSuppliers));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'supplier_added',
            category: 'supplier',
            description: 'Added supplier: ${event.supplier.name} (${event.supplier.company})',
            userId: user?.username ?? 'system',
            referenceId: event.supplier.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(SupplierError(e.toString()));
      }
    });

    on<UpdateSupplierEvent>((event, emit) async {
      emit(SupplierLoading());
      try {
        await supplierRepository.updateSupplier(event.supplier);
        _allSuppliers = await supplierRepository.getSuppliers();
        emit(SupplierLoaded(_allSuppliers, _allSuppliers));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'supplier_edited',
            category: 'supplier',
            description: 'Updated supplier: ${event.supplier.name}',
            userId: user?.username ?? 'system',
            referenceId: event.supplier.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(SupplierError(e.toString()));
      }
    });

    on<DeleteSupplierEvent>((event, emit) async {
      emit(SupplierLoading());
      try {
        String suppName = event.id;
        try {
          final existing = _allSuppliers.firstWhere((s) => s.id == event.id);
          suppName = existing.name;
        } catch (_) {}
        await supplierRepository.deleteSupplier(event.id);
        _allSuppliers = await supplierRepository.getSuppliers();
        emit(SupplierLoaded(_allSuppliers, _allSuppliers));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'supplier_deleted',
            category: 'supplier',
            description: 'Deleted supplier: $suppName',
            userId: user?.username ?? 'system',
            referenceId: event.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(SupplierError(e.toString()));
      }
    });

    on<DeleteMultipleSuppliersEvent>((event, emit) async {
      emit(SupplierLoading());
      try {
        final List<String> deletedNames = [];
        for (final id in event.ids) {
          try {
            final existing = _allSuppliers.firstWhere((s) => s.id == id);
            deletedNames.add(existing.name);
          } catch (_) {
            deletedNames.add(id);
          }
          await supplierRepository.deleteSupplier(id);
        }
        _allSuppliers = await supplierRepository.getSuppliers();
        emit(SupplierLoaded(_allSuppliers, _allSuppliers));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'supplier_deleted',
            category: 'supplier',
            description: 'Deleted suppliers: ${deletedNames.join(", ")}',
            userId: user?.username ?? 'system',
            referenceId: event.ids.join(","),
          );
        } catch (_) {}
      } catch (e) {
        emit(SupplierError(e.toString()));
      }
    });
  }
}
