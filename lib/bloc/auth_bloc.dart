import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_profile.dart';
import '../services/session_service.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthProfileChanged extends AuthEvent {
  const AuthProfileChanged(this.profile);

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

enum AuthStatus { unknown, authenticated, unauthenticated, loading, failure }

class AuthState extends Equatable {
  const AuthState({required this.status, this.profile, this.errorMessage});

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  final AuthStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._sessionService) : super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthProfileChanged>(_onProfileChanged);
  }

  final SessionService _sessionService;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final isLoggedIn = await _sessionService.isLoggedIn();
    if (isLoggedIn) {
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          profile: await _sessionService.loadProfile(),
        ),
      );
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final profile = await _sessionService.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthState(status: AuthStatus.authenticated, profile: profile));
    } on AuthException catch (error) {
      emit(
        AuthState(
          status: AuthStatus.failure,
          errorMessage: error.message,
          profile: state.profile,
        ),
      );
    } catch (_) {
      emit(
        AuthState(
          status: AuthStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
          profile: state.profile,
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _sessionService.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onProfileChanged(
    AuthProfileChanged event,
    Emitter<AuthState> emit,
  ) async {
    await _sessionService.saveSession(event.profile);
    emit(AuthState(status: AuthStatus.authenticated, profile: event.profile));
  }
}
