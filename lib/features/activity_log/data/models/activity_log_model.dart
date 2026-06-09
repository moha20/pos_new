import 'package:realm/realm.dart';
import '../../domain/entities/activity_log_entity.dart';

part 'activity_log_model.realm.dart';

@RealmModel()
class _ActivityLog {
  @PrimaryKey()
  late ObjectId id;
  late DateTime timestamp;
  late String action;
  late String category;
  late String description;
  late String userId;
  late String? referenceId;
}

extension ActivityLogMapper on ActivityLog {
  ActivityLogEntity toEntity() {
    return ActivityLogEntity(
      id: id.toString(),
      timestamp: timestamp,
      action: action,
      category: category,
      description: description,
      userId: userId,
      referenceId: referenceId,
    );
  }
}
