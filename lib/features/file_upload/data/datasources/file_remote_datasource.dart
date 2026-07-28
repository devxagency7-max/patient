import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pharmacare/core/config/app_config.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/file_upload/data/models/file_model.dart';

abstract class FileRemoteDataSource {
  Future<FileModel> uploadFile({
    required File file,
    required String type,
  });
}

class FileRemoteDataSourceImpl implements FileRemoteDataSource {
  final ApiClient apiClient;

  FileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<FileModel> uploadFile({
    required File file,
    required String type,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        // Backend form field is `fileType` (not `type`) — otherwise the server
        // defaults the category to `Other` and miscategorizes prescriptions.
        'fileType': type,
      });

      // Absolute URL (files live under /api/files, NOT /api/v1) — from config.
      final response = await apiClient.dio.post(
        AppConfig.fileUploadUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FileModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to upload file',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
