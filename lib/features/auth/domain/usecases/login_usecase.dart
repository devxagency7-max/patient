import 'package:dartz/dartz.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/usecases/usecase.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/auth/domain/repositories/auth_repository.dart';

/// حالة استخدام تسجيل الدخول - Login UseCase
/// Business Logic بحت — مش بيعرف حاجة عن Flutter أو Firebase
class LoginUseCase extends UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}

/// Parameters لـ Login
class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}
