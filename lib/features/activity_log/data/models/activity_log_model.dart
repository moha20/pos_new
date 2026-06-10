import '../../domain/entities/activity_log_entity.dart';

class ActivityLogModel {
  final String id;
  final DateTime timestamp;
  final String action;
  final String category;
  final String description;
  final String userId;
  final String? referenceId;

  ActivityLogModel({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.category,
    required this.description,
    required this.userId,
    this.referenceId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'action': action,
    'category': category,
    'description': description,
    'userId': userId,
    'referenceId': referenceId,
  };

  factory ActivityLogModel.fromMap(Map<dynamic, dynamic> map) => ActivityLogModel(
    id: map['id'] as String,
    timestamp: DateTime.parse(map['timestamp'] as String),
    action: map['action'] as String,
    category: map['category'] as String,
    description: map['description'] as String,
    userId: map['userId'] as String,
    referenceId: map['referenceId'] as String?,
  );

  ActivityLogEntity toEntity() {
    return ActivityLogEntity(
      id: id,
      timestamp: timestamp,
      action: action,
      category: category,
      description: description,
      userId: userId,
      referenceId: referenceId,
    );
  }
}
