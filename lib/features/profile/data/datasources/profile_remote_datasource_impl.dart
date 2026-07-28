import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/auth/data/models/user_model.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/profile/data/datasources/profile_remote_datasource.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserEntity> completeProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? avatarUrl,
  }) async {
    final response = await _apiClient.dio.post(
      '/users/profile/complete',
      data: {
        'name': name,
        'phone': phone,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'avatarUrl': avatarUrl,
      },
    );

    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } else {
      throw Exception(response.data['errors']?.toString() ?? 'Failed to complete profile');
    }
  }
}
