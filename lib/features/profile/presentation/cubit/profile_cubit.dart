import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/profile/domain/usecases/complete_profile_usecase.dart';
import 'package:pharmacare/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final CompleteProfileUseCase _completeProfileUseCase;

  ProfileCubit({
    required CompleteProfileUseCase completeProfileUseCase,
  })  : _completeProfileUseCase = completeProfileUseCase,
        super(const ProfileInitial());

  Future<void> completeProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? avatarUrl,
  }) async {
    emit(const ProfileLoading());

    final result = await _completeProfileUseCase(
      CompleteProfileParams(
        name: name,
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
        avatarUrl: avatarUrl,
      ),
    );

    switch (result) {
      case ApiSuccess(data: final user):
        emit(ProfileSuccess(user));
      case ApiFailure(failure: final failure):
        emit(ProfileError(failure.message));
    }
  }
}
