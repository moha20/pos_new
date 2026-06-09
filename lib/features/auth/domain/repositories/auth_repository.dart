import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String username, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<List<UserEntity>> getAllUsers();
  Future<void> addUser(UserEntity user, String password);
  Future<void> updateUser(UserEntity user, {String? password});
  Future<void> deleteUser(String id);
}
