import 'package:dartz/dartz.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';

/// عقد الـ Repository — Auth Repository Contract (Abstract)
/// يحدد العمليات المتاحة بدون التفاصيل التقنية
/// الـ Domain Layer بتعرف بس الـ Interface ده
/// الـ Data Layer بتنفذه (Implementation)
abstract class AuthRepository {
  /// تسجيل الدخول بالإيميل والباسورد
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// إنشاء حساب جديد
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  });

  /// تسجيل الخروج
  Future<Either<Failure, void>> logout();

  /// التحقق من جلسة المستخدم الحالية
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// تسجيل الدخول بحساب Google
  Future<Either<Failure, UserEntity>> loginWithGoogle();
}
