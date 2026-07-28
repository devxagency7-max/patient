import 'package:equatable/equatable.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/core/usecases/usecase.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/profile/domain/repositories/profile_repository.dart';

class CompleteProfileUseCase implements UseCase<UserEntity, CompleteProfileParams> {
  final ProfileRepository _repository;

  CompleteProfileUseCase(this._repository);

  @override
  Future<ApiResult<UserEntity>> call(CompleteProfileParams params) async {
    return await _repository.completeProfile(
      name: params.name,
      phone: params.phone,
      gender: params.gender,
      dateOfBirth: params.dateOfBirth,
      avatarUrl: params.avatarUrl,
    );
  }
}

class CompleteProfileParams extends Equatable {
  final String name;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? avatarUrl;

  const CompleteProfileParams({
    required this.name,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, phone, gender, dateOfBirth, avatarUrl];
}
