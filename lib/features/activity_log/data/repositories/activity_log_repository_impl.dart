import '../../domain/entities/activity_log_entity.dart';
import '../../domain/repositories/activity_log_repository.dart';
import '../models/activity_log_model.dart';
import 'package:realm/realm.dart';

class ActivityLogRepositoryImpl implements ActivityLogRepository {
  final Realm _realm;

  ActivityLogRepositoryImpl(this._realm);

  @override
  List<ActivityLogEntity> getAllLogs() {
    final results = _realm.all<ActivityLog>().toList();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results.map((e) => e.toEntity()).toList();
  }

  @override
  List<ActivityLogEntity> getLogsByCategory(String category) {
    final results = _realm.all<ActivityLog>()
        .query(r'category == $0', [category]).toList();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results.map((e) => e.toEntity()).toList();
  }

  @override
  List<ActivityLogEntity> getLogsByDateRange(DateTime start, DateTime end) {
    final results = _realm.all<ActivityLog>()
        .query(r'timestamp >= $0 AND timestamp <= $1', [start, end]).toList();
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
    _realm.write(() {
      _realm.add(ActivityLog(
        ObjectId(),
        DateTime.now(),
        action,
        category,
        description,
        userId,
        referenceId: referenceId,
      ));
    });
  }
}
