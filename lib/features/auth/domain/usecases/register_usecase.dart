import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/core/usecases/usecase.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String phone;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<ApiResult<UserEntity>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      phone: params.phone,
    );
  }
}
