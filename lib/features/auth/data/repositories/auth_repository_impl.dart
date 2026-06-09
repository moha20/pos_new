import 'package:realm/realm.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/db/realm_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Realm realm;
  UserEntity? _currentUser;

  AuthRepositoryImpl(this.realm);

  ObjectId _parseId(String idStr) {
    try {
      return ObjectId.fromHexString(idStr);
    } catch (_) {
      return ObjectId();
    }
  }

  @override
  Future<UserEntity?> login(String username, String password) async {
    final passwordHash = hashPassword(password);
    final users = realm.query<User>('username == \$0 AND passwordHash == \$1', [username, passwordHash]);
    if (users.isNotEmpty) {
      final user = users.first;
      if (user.isActive) {
        _currentUser = user.toEntity();
        return _currentUser;
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
    return realm.all<User>().map((u) => u.toEntity()).toList();
  }

  @override
  Future<void> addUser(UserEntity user, String password) async {
    realm.write(() {
      realm.add(User(
        ObjectId(),
        user.name,
        user.username,
        hashPassword(password),
        user.role,
        user.isActive,
      ));
    });
  }

  @override
  Future<void> updateUser(UserEntity user, {String? password}) async {
    final dbUser = realm.find<User>(_parseId(user.id));
    if (dbUser != null) {
      realm.write(() {
        dbUser.name = user.name;
        dbUser.username = user.username;
        dbUser.role = user.role;
        dbUser.isActive = user.isActive;
        if (password != null && password.isNotEmpty) {
          dbUser.passwordHash = hashPassword(password);
        }
      });
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    final dbUser = realm.find<User>(_parseId(id));
    if (dbUser != null) {
      realm.write(() {
        realm.delete(dbUser);
      });
    }
  }
}
