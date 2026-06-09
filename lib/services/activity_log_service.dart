import '../features/activity_log/domain/repositories/activity_log_repository.dart';

class ActivityLogService {
  final ActivityLogRepository _repository;

  ActivityLogService(this._repository);

  void log({
    required String action,
    required String category,
    required String description,
    required String userId,
    String? referenceId,
  }) {
    _repository.addLog(
      action: action,
      category: category,
      description: description,
      userId: userId,
      referenceId: referenceId,
    );
  }
}
