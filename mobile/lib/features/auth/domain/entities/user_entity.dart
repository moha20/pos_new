class UserEntity {
  final String id;
  final String name;
  final String username;
  final String role; // 'admin' | 'cashier' | 'viewer'
  final bool isActive;
  final String companyName;

  UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.isActive,
    this.companyName = '',
  });

  bool get isAdmin => role == 'admin';
  bool get isCashier => role == 'cashier';
  bool get isViewer => role == 'viewer';

  UserEntity copyWith({
    String? id,
    String? name,
    String? username,
    String? role,
    bool? isActive,
    String? companyName,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      companyName: companyName ?? this.companyName,
    );
  }
}
