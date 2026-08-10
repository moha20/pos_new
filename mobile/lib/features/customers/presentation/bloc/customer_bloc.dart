import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../../../core/di/di.dart';
import '../../../../services/activity_log_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

// Events
abstract class CustomerEvent {}

class LoadCustomers extends CustomerEvent {}

class SearchCustomers extends CustomerEvent {
  final String query;
  SearchCustomers(this.query);
}

class AddCustomerEvent extends CustomerEvent {
  final CustomerEntity customer;
  AddCustomerEvent(this.customer);
}

class UpdateCustomerEvent extends CustomerEvent {
  final CustomerEntity customer;
  UpdateCustomerEvent(this.customer);
}

class DeleteCustomerEvent extends CustomerEvent {
  final String id;
  DeleteCustomerEvent(this.id);
}

class DeleteMultipleCustomersEvent extends CustomerEvent {
  final List<String> ids;
  DeleteMultipleCustomersEvent(this.ids);
}

// States
abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> allCustomers;
  final List<CustomerEntity> filteredCustomers;
  CustomerLoaded(this.allCustomers, this.filteredCustomers);
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}

// Bloc
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository customerRepository;
  List<CustomerEntity> _allCustomers = [];

  CustomerBloc(this.customerRepository) : super(CustomerInitial()) {
    on<LoadCustomers>((event, emit) async {
      emit(CustomerLoading());
      try {
        _allCustomers = await customerRepository.getCustomers();
        emit(CustomerLoaded(_allCustomers, _allCustomers));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<SearchCustomers>((event, emit) {
      if (state is CustomerLoaded) {
        final query = event.query.toLowerCase().trim();
        if (query.isEmpty) {
          emit(CustomerLoaded(_allCustomers, _allCustomers));
        } else {
          final filtered = _allCustomers.where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.phone.contains(query) ||
              c.address.toLowerCase().contains(query)).toList();
          emit(CustomerLoaded(_allCustomers, filtered));
        }
      }
    });

    on<AddCustomerEvent>((event, emit) async {
      emit(CustomerLoading());
      try {
        await customerRepository.addCustomer(event.customer);
        _allCustomers = await customerRepository.getCustomers();
        emit(CustomerLoaded(_allCustomers, _allCustomers));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'customer_added',
            category: 'customer',
            description: 'Added customer: ${event.customer.name} (${event.customer.phone})',
            userId: user?.username ?? 'system',
            referenceId: event.customer.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<UpdateCustomerEvent>((event, emit) async {
      emit(CustomerLoading());
      try {
        await customerRepository.updateCustomer(event.customer);
        _allCustomers = await customerRepository.getCustomers();
        emit(CustomerLoaded(_allCustomers, _allCustomers));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'customer_edited',
            category: 'customer',
            description: 'Updated customer: ${event.customer.name}',
            userId: user?.username ?? 'system',
            referenceId: event.customer.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<DeleteCustomerEvent>((event, emit) async {
      emit(CustomerLoading());
      try {
        String custName = event.id;
        try {
          final existing = _allCustomers.firstWhere((c) => c.id == event.id);
          custName = existing.name;
        } catch (_) {}
        await customerRepository.deleteCustomer(event.id);
        _allCustomers = await customerRepository.getCustomers();
        emit(CustomerLoaded(_allCustomers, _allCustomers));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'customer_deleted',
            category: 'customer',
            description: 'Deleted customer: $custName',
            userId: user?.username ?? 'system',
            referenceId: event.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<DeleteMultipleCustomersEvent>((event, emit) async {
      emit(CustomerLoading());
      try {
        final List<String> deletedNames = [];
        for (final id in event.ids) {
          try {
            final existing = _allCustomers.firstWhere((c) => c.id == id);
            deletedNames.add(existing.name);
          } catch (_) {
            deletedNames.add(id);
          }
          await customerRepository.deleteCustomer(id);
        }
        _allCustomers = await customerRepository.getCustomers();
        emit(CustomerLoaded(_allCustomers, _allCustomers));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'customer_deleted',
            category: 'customer',
            description: 'Deleted customers: ${deletedNames.join(", ")}',
            userId: user?.username ?? 'system',
            referenceId: event.ids.join(","),
          );
        } catch (_) {}
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });
  }
}
