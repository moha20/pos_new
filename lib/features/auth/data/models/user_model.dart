import 'package:realm/realm.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.realm.dart';

@RealmModel()
class _User {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late String username;
  late String passwordHash;
  late String role; // 'admin' | 'cashier' | 'viewer'
  late bool isActive;
}

extension UserMapper on User {
  UserEntity toEntity() {
    return UserEntity(
      id: id.toString(),
      name: name,
      username: username,
      role: role,
      isActive: isActive,
    );
  }
}
