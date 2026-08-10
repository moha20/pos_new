import 'package:hive/hive.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../domain/repositories/activity_log_repository.dart';
import '../models/activity_log_model.dart';
import '../../../../core/db/hive_config.dart';

class ActivityLogRepositoryImpl implements ActivityLogRepository {
  final Box _box;

  ActivityLogRepositoryImpl(this._box);

  @override
  List<ActivityLogEntity> getAllLogs() {
    final results = _box.values
        .map((v) => ActivityLogModel.fromMap(v as Map<dynamic, dynamic>))
        .toList();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results.map((e) => e.toEntity()).toList();
  }

  @override
  List<ActivityLogEntity> getLogsByCategory(String category) {
    final results = _box.values
        .map((v) => ActivityLogModel.fromMap(v as Map<dynamic, dynamic>))
        .where((e) => e.category == category)
        .toList();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results.map((e) => e.toEntity()).toList();
  }

  @override
  List<ActivityLogEntity> getLogsByDateRange(DateTime start, DateTime end) {
    final results = _box.values
        .map((v) => ActivityLogModel.fromMap(v as Map<dynamic, dynamic>))
        .where((e) => !e.timestamp.isBefore(start) && !e.timestamp.isAfter(end))
        .toList();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results.map((e) => e.toEntity()).toList();
  }

  @override
  void addLog({
    required String action,
    required String category,
    required String description,
    required String userId,
    String? referenceId,
  }) {
    final id = generateId();
    final model = ActivityLogModel(
      id: id,
      timestamp: DateTime.now(),
      action: action,
      category: category,
      description: description,
      userId: userId,
      referenceId: referenceId,
    );
    _box.put(id, model.toMap());
  }
}
