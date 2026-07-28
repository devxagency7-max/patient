import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/core/usecases/usecase.dart';
import 'package:pharmacare/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<ApiResult<void>> call(NoParams params) {
    return repository.logout();
  }
}
