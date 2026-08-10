import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../domain/repositories/activity_log_repository.dart';

// States
abstract class ActivityLogState {}

class ActivityLogInitial extends ActivityLogState {}
class ActivityLogLoading extends ActivityLogState {}

class ActivityLogLoaded extends ActivityLogState {
  final List<ActivityLogEntity> logs;
  final String? activeCategory;

  ActivityLogLoaded(this.logs, {this.activeCategory});
}

class ActivityLogError extends ActivityLogState {
  final String message;
  ActivityLogError(this.message);
}

// Cubit
class ActivityLogCubit extends Cubit<ActivityLogState> {
  final ActivityLogRepository _repository;

  ActivityLogCubit(this._repository) : super(ActivityLogInitial());

  void loadAll() {
    emit(ActivityLogLoading());
    try {
      final logs = _repository.getAllLogs();
      emit(ActivityLogLoaded(logs));
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }

  // Map plural filter keys to also match singular logged values
  static const Map<String, List<String>> _categoryVariants = {
    'customers': ['customers', 'customer'],
    'suppliers': ['suppliers', 'supplier'],
  };

  void filterByCategory(String? category) {
    emit(ActivityLogLoading());
    try {
      if (category == null || category.isEmpty || category == 'all') {
        final logs = _repository.getAllLogs();
        emit(ActivityLogLoaded(logs, activeCategory: null));
      } else {
        // Get all category variants to match
        final variants = _categoryVariants[category] ?? [category];
        final List<ActivityLogEntity> allLogs = [];
        for (final variant in variants) {
          allLogs.addAll(_repository.getLogsByCategory(variant));
        }
        // Remove duplicates and sort by timestamp descending
        final uniqueIds = <String>{};
        final uniqueLogs = allLogs.where((log) => uniqueIds.add(log.id)).toList();
        uniqueLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        emit(ActivityLogLoaded(uniqueLogs, activeCategory: category));
      }
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }

  void filterByDateRange(DateTime start, DateTime end) {
    emit(ActivityLogLoading());
    try {
      final logs = _repository.getLogsByDateRange(start, end);
      emit(ActivityLogLoaded(logs));
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }
}
