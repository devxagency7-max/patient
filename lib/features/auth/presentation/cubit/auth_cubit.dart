import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/core/usecases/usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/login_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/register_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetProfileUseCase getProfileUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getProfileUseCase = getProfileUseCase,
        _googleSignInUseCase = googleSignInUseCase,
        super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    switch (result) {
      case ApiSuccess(data: final user):
        emit(AuthAuthenticated(user));
      case ApiFailure(failure: final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(const AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(name: name, email: email, password: password, phone: phone),
    );

    switch (result) {
      case ApiSuccess(data: final user):
        emit(AuthAuthenticated(user));
      case ApiFailure(failure: final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());

    final result = await _googleSignInUseCase(const NoParams());

    switch (result) {
      case ApiSuccess(data: final user):
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthInitial());
        }
      case ApiFailure(failure: final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());

    final result = await _logoutUseCase(const NoParams());

    switch (result) {
      case ApiSuccess():
        emit(const AuthUnauthenticated());
      case ApiFailure(failure: final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> fetchProfile() async {
    emit(const AuthLoading());

    final result = await _getProfileUseCase(const NoParams());

    switch (result) {
      case ApiSuccess(data: final user):
        emit(AuthAuthenticated(user));
      case ApiFailure(failure: final failure):
        emit(AuthError(failure.message));
    }
  }

  void resetState() {
    emit(const AuthInitial());
  }
}
