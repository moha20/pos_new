import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String passwordHash;
  final String role; // 'admin' | 'cashier' | 'viewer'
  final bool isActive;
  final String companyName;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.isActive,
    this.companyName = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'username': username,
    'passwordHash': passwordHash,
    'role': role,
    'isActive': isActive,
    'companyName': companyName,
  };

  factory UserModel.fromMap(Map<dynamic, dynamic> map) => UserModel(
    id: map['id'] as String,
    name: map['name'] as String,
    username: map['username'] as String,
    passwordHash: map['passwordHash'] as String,
    role: map['role'] as String,
    isActive: map['isActive'] as bool,
    companyName: (map['companyName'] as String?) ?? '',
  );

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      username: username,
      role: role,
      isActive: isActive,
      companyName: companyName,
    );
  }
}
