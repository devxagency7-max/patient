import 'package:dartz/dartz.dart';
import 'package:pharmacare/core/error/failures.dart';

/// الكلاس الأساسي لكل UseCase في التطبيق
/// كل UseCase بترجع Either<Failure, Type>
/// Failure = خطأ، Type = النتيجة الناجحة
///
/// مثال الاستخدام:
/// ```dart
/// class LoginUseCase extends UseCase<UserEntity, LoginParams> {
///   final AuthRepository repository;
///   LoginUseCase(this.repository);
///
///   @override
///   Future<Either<Failure, UserEntity>> call(LoginParams params) {
///     return repository.login(params.email, params.password);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// للـ UseCases اللي ما بتحتاجش Parameters
class NoParams {
  const NoParams();
}
