class ActivityLogEntity {
  final String id;
  final DateTime timestamp;
  final String action;
  final String category;
  final String description;
  final String userId;
  final String? referenceId;

  ActivityLogEntity({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.category,
    required this.description,
    required this.userId,
    this.referenceId,
  });
}
