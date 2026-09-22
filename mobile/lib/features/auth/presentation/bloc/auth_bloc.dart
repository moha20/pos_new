import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/di/di.dart';
import '../../../../services/activity_log_service.dart';

// Events
abstract class AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String companyName;
  final String username;
  final String password;
  AuthLoginRequested(this.username, this.password, {this.companyName = ''});
}

class AuthLogoutRequested extends AuthEvent {}

class AuthLoadUsers extends AuthEvent {}

class AuthAddUserRequested extends AuthEvent {
  final UserEntity user;
  final String password;
  AuthAddUserRequested(this.user, this.password);
}

class AuthUpdateUserRequested extends AuthEvent {
  final UserEntity user;
  final String? password;
  AuthUpdateUserRequested(this.user, {this.password});
}

class AuthDeleteUserRequested extends AuthEvent {
  final String id;
  AuthDeleteUserRequested(this.id);
}

class AuthUpdateCompanyName extends AuthEvent {
  final String companyName;
  AuthUpdateCompanyName(this.companyName);
}

class AuthUpdateCompany extends AuthEvent {
  final String companyName;
  AuthUpdateCompany(this.companyName);
}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthUsersLoaded extends AuthState {
  final List<UserEntity> users;
  AuthUsersLoaded(this.users);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  UserEntity? _currentUser;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthCheckStatus>((event, emit) async {
      emit(AuthLoading());
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure('Not logged in'));
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.login(
          event.username,
          event.password,
          companyName: event.companyName,
        );
        if (user != null) {
          _currentUser = user;
          emit(AuthSuccess(user));
          try {
            Gravity.find<ActivityLogService>().log(
              action: 'login',
              category: 'auth',
              description: 'User ${user.name} logged in',
              userId: user.username,
            );
          } catch (_) {}
        } else {
          emit(AuthFailure('invalid_credentials'));
        }
      } catch (e) {
        emit(AuthFailure('invalid_credentials'));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      final user = _currentUser;
      await authRepository.logout();
      _currentUser = null;
      emit(AuthFailure('Logged out'));
      if (user != null) {
        try {
          Gravity.find<ActivityLogService>().log(
            action: 'logout',
            category: 'auth',
            description: 'User ${user.name} logged out',
            userId: user.username,
          );
        } catch (_) {}
      }
    });

    on<AuthUpdateCompanyName>((event, emit) async {
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(companyName: event.companyName.trim());
        try {
          await authRepository.updateUser(_currentUser!);
        } catch (_) {}
        emit(AuthSuccess(_currentUser!));
      }
    });

    on<AuthLoadUsers>((event, emit) async {
      emit(AuthLoading());
      try {
        final users = await authRepository.getAllUsers();
        emit(AuthUsersLoaded(users));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthAddUserRequested>((event, emit) async {
      try {
        await authRepository.addUser(event.user, event.password);
        final users = await authRepository.getAllUsers();
        emit(AuthUsersLoaded(users));
        try {
          final creator = _currentUser?.name ?? 'System';
          final creatorUsername = _currentUser?.username ?? 'system';
          Gravity.find<ActivityLogService>().log(
            action: 'add_user',
            category: 'settings',
            description: 'User ${event.user.name} (${event.user.role}) added by $creator',
            userId: creatorUsername,
            referenceId: event.user.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthUpdateUserRequested>((event, emit) async {
      try {
        await authRepository.updateUser(event.user, password: event.password);
        final users = await authRepository.getAllUsers();
        emit(AuthUsersLoaded(users));
        try {
          final updater = _currentUser?.name ?? 'System';
          final updaterUsername = _currentUser?.username ?? 'system';
          Gravity.find<ActivityLogService>().log(
            action: 'update_user',
            category: 'settings',
            description: 'User ${event.user.name} updated by $updater',
            userId: updaterUsername,
            referenceId: event.user.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthDeleteUserRequested>((event, emit) async {
      try {
        await authRepository.deleteUser(event.id);
        final users = await authRepository.getAllUsers();
        emit(AuthUsersLoaded(users));
        try {
          final deleter = _currentUser?.name ?? 'System';
          final deleterUsername = _currentUser?.username ?? 'system';
          Gravity.find<ActivityLogService>().log(
            action: 'delete_user',
            category: 'settings',
            description: 'User ID ${event.id} deleted by $deleter',
            userId: deleterUsername,
            referenceId: event.id,
          );
        } catch (_) {}
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthUpdateCompany>((event, emit) async {
      authRepository.updateCurrentCompany(event.companyName);
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        emit(AuthSuccess(user));
      }
    });
  }

  UserEntity? get currentUser => _currentUser;
}
