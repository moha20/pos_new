import 'package:hive/hive.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/db/hive_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Box _box;
  UserEntity? _currentUser;

  AuthRepositoryImpl(this._box);

  @override
  Future<UserEntity?> login(String username, String password) async {
    final passwordHash = hashPassword(password);
    for (final entry in _box.toMap().entries) {
      final user = UserModel.fromMap(entry.value as Map<dynamic, dynamic>);
      if (user.username == username && user.passwordHash == passwordHash) {
        if (user.isActive) {
          _currentUser = user.toEntity();
          return _currentUser;
        }
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    return _box.values
        .map((v) => UserModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<void> addUser(UserEntity user, String password) async {
    final id = generateId();
    final model = UserModel(
      id: id,
      name: user.name,
      username: user.username,
      passwordHash: hashPassword(password),
      role: user.role,
      isActive: user.isActive,
    );
    await _box.put(id, model.toMap());
  }

  @override
  Future<void> updateUser(UserEntity user, {String? password}) async {
    final existing = _box.get(user.id);
    if (existing != null) {
      final old = UserModel.fromMap(existing as Map<dynamic, dynamic>);
      final model = UserModel(
        id: user.id,
        name: user.name,
        username: user.username,
        passwordHash: (password != null && password.isNotEmpty)
            ? hashPassword(password)
            : old.passwordHash,
        role: user.role,
        isActive: user.isActive,
      );
      await _box.put(user.id, model.toMap());
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    await _box.delete(id);
  }
}
