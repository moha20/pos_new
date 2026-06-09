import '../entities/activity_log_entity.dart';

abstract class ActivityLogRepository {
  List<ActivityLogEntity> getAllLogs();
  List<ActivityLogEntity> getLogsByCategory(String category);
  List<ActivityLogEntity> getLogsByDateRange(DateTime start, DateTime end);
  void addLog({
    required String action,
    required String category,
    required String description,
    required String userId,
    String? referenceId,
  });
}
