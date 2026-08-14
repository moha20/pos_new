import 'package:hive/hive.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/db/hive_config.dart';
import '../../../../core/di/di.dart';
import '../../../../services/cloud_sync_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Box _box;
  UserEntity? _currentUser;

  AuthRepositoryImpl(this._box);

  @override
  Future<UserEntity?> login(String username, String password, {String? companyName}) async {
    final passwordHash = hashPassword(password);
    final userCompany = (companyName != null && companyName.trim().isNotEmpty)
        ? companyName.trim()
        : 'Al-Mohandis POS';

    // 1. Verify Online Company Active Status and Company Admin Credentials
    try {
      final cloudSync = Gravity.find<CloudSyncService>();
      final authRes = await cloudSync.authenticateOnline(userCompany, username, password);
      if (authRes != null && authRes['role'] == 'admin') {
        final adminUser = UserEntity(
          id: 'admin_${userCompany.toLowerCase().replaceAll(' ', '_')}',
          name: '$userCompany Admin',
          username: username,
          role: 'admin',
          isActive: true,
          companyName: userCompany,
        );

        // Seed in local Hive storage for offline capability
        final model = UserModel(
          id: adminUser.id,
          name: adminUser.name,
          username: adminUser.username,
          passwordHash: passwordHash,
          role: adminUser.role,
          isActive: true,
          companyName: userCompany,
        );
        await _box.put(adminUser.id, model.toMap());

        _currentUser = adminUser;
        return _currentUser;
      }
    } catch (e) {
      if (e.toString().contains('COMPANY_INACTIVE') || e.toString().contains('COMPANY_NOT_FOUND')) {
        rethrow;
      }
    }

    // 2. Check local Hive DB for company users created by Company Admin inside the app
    for (final entry in _box.toMap().entries) {
      final user = UserModel.fromMap(entry.value as Map<dynamic, dynamic>);
      if (user.username == username && user.passwordHash == passwordHash) {
        if (user.isActive) {
          final entity = UserEntity(
            id: user.id,
            name: user.name,
            username: user.username,
            role: user.role,
            isActive: user.isActive,
            companyName: userCompany,
          );
          _currentUser = entity;
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
    final all = _box.values
        .map((v) => UserModel.fromMap(v as Map<dynamic, dynamic>).toEntity())
        .toList();
    if (_currentUser != null && _currentUser!.companyName.isNotEmpty) {
      return all.where((u) => u.companyName == _currentUser!.companyName || u.companyName.isEmpty).toList();
    }
    return all;
  }

  @override
  Future<void> addUser(UserEntity user, String password) async {
    final id = generateId();
    final company = user.companyName.isNotEmpty
        ? user.companyName
        : (_currentUser?.companyName ?? 'Al-Mohandis POS');

    final model = UserModel(
      id: id,
      name: user.name,
      username: user.username,
      passwordHash: hashPassword(password),
      role: user.role,
      isActive: user.isActive,
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
