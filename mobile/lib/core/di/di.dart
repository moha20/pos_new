import 'package:get_it/get_it.dart';

class Gravity {
  static final GetIt _getIt = GetIt.instance;

  static T put<T extends Object>(T dependency) {
    if (_getIt.isRegistered<T>()) {
      _getIt.unregister<T>();
    }
    _getIt.registerSingleton<T>(dependency);
    return dependency;
  }

  static T find<T extends Object>() {
    return _getIt.get<T>();
  }
}
