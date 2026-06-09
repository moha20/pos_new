class UserEntity {
  final String id;
  final String name;
  final String username;
  final String role; // 'admin' | 'cashier' | 'viewer'
  final bool isActive;

  UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.isActive,
  });

  bool get isAdmin => role == 'admin';
  bool get isCashier => role == 'cashier';
  bool get isViewer => role == 'viewer';
}
