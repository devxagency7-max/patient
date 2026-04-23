import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacare/core/di/providers.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/auth/domain/usecases/login_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/register_usecase.dart';
import 'package:pharmacare/core/usecases/usecase.dart';

/// حالة المصادقة — Auth State
/// بتوصف كل الحالات الممكنة لعملية المصادقة
sealed class AuthState {
  const AuthState();
}

/// الحالة الابتدائية
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// جاري التحميل
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// تم المصادقة بنجاح
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

/// غير مسجّل دخول
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// خطأ في المصادقة
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// ===== Auth Controller =====
/// يتحكم في حالة المصادقة بالكامل
/// الـ UI بيستدعي الـ methods هنا ومش بيعرف حاجة عن الـ UseCases أو الـ Repository
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthInitial();
  }

  /// تسجيل الدخول
  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  /// إنشاء حساب جديد
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    final registerUseCase = ref.read(registerUseCaseProvider);
    final result = await registerUseCase(
      RegisterParams(name: name, email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    state = const AuthLoading();

    final logoutUseCase = ref.read(logoutUseCaseProvider);
    final result = await logoutUseCase(const NoParams());

    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }

  /// إعادة الحالة الابتدائية (لمسح الأخطاء مثلاً)
  void resetState() {
    state = const AuthInitial();
  }
}

/// Provider للـ Auth Controller
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
