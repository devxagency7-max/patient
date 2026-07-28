import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/core/usecases/usecase.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/auth/domain/repositories/auth_repository.dart';

class GoogleSignInUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  @override
  Future<ApiResult<UserEntity?>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}
