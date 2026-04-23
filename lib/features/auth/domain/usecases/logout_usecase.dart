import 'package:dartz/dartz.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/usecases/usecase.dart';
import 'package:pharmacare/features/auth/domain/repositories/auth_repository.dart';

/// حالة استخدام تسجيل الخروج - Logout UseCase
class LogoutUseCase extends UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
