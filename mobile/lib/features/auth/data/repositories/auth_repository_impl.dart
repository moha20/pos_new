import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/db/hive_config.dart';
import '../../../../core/di/di.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Box _box;
  UserEntity? _currentUser;

  AuthRepositoryImpl(this._box);

  @override
  Future<UserEntity?> login(String username, String password, {String? companyName}) async {
    final passwordHash = hashPassword(password);

    // Check local Hive DB for matching user
    for (final entry in _box.toMap().entries) {
      final user = UserModel.fromMap(entry.value as Map<dynamic, dynamic>);
      if (user.username == username && user.passwordHash == passwordHash) {
        if (user.isActive) {
          final entity = user.toEntity();
          _currentUser = entity;
          try {
            final prefs = Gravity.find<SharedPreferences>();
            await prefs.setString('logged_in_user_id', entity.id);
            if (entity.companyName.trim().isNotEmpty) {
              await prefs.setString('company_name', entity.companyName.trim());
            }
          } catch (_) {}
          return _currentUser;
        }
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    try {
      final prefs = Gravity.find<SharedPreferences>();
      await prefs.remove('logged_in_user_id');
    } catch (_) {}
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final prefs = Gravity.find<SharedPreferences>();
      final savedId = prefs.getString('logged_in_user_id');
      if (savedId != null) {
        final raw = _box.get(savedId);
        if (raw != null) {
          _currentUser = UserModel.fromMap(raw as Map<dynamic, dynamic>).toEntity();
          return _currentUser;
        }
      }
    } catch (_) {}

    // Fallback in local offline mode: restore active admin
    for (final val in _box.values) {
      final user = UserModel.fromMap(val as Map<dynamic, dynamic>);
      if (user.role == 'admin' && user.isActive) {
        _currentUser = user.toEntity();
        return _currentUser;
      }
    }
    return null;
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
    final company = user.companyName.isNotEmpty
        ? user.companyName
        : (_currentUser?.companyName ?? 'Elmohands software');

    final model = UserModel(
      id: id,
      name: user.name,
      username: user.username,
      passwordHash: hashPassword(password),
      role: user.role,
      isActive: true,
      companyName: company,
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
        companyName: user.companyName.trim().isNotEmpty
            ? user.companyName.trim()
            : old.companyName,
      );
      await _box.put(user.id, model.toMap());
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    await _box.delete(id);
  }

  @override
  void updateCurrentCompany(String companyName) {
    if (_currentUser != null) {
      _currentUser = UserEntity(
        id: _currentUser!.id,
        name: _currentUser!.name,
        username: _currentUser!.username,
        role: _currentUser!.role,
        isActive: _currentUser!.isActive,
        companyName: companyName,
      );
    }
  }
}
