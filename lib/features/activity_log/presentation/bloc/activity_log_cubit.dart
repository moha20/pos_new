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

  void filterByCategory(String? category) {
    emit(ActivityLogLoading());
    try {
      if (category == null || category.isEmpty || category == 'all') {
        final logs = _repository.getAllLogs();
        emit(ActivityLogLoaded(logs, activeCategory: null));
      } else {
        final logs = _repository.getLogsByCategory(category);
        emit(ActivityLogLoaded(logs, activeCategory: category));
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
