import 'dart:io';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/file_upload/data/datasources/file_remote_datasource.dart';
import 'package:pharmacare/features/file_upload/domain/entities/file_entity.dart';
import 'package:pharmacare/features/file_upload/domain/repositories/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final FileRemoteDataSource remoteDataSource;

  FileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<FileEntity>> uploadFile({
    required File file,
    required String type,
  }) async {
    try {
      final fileModel = await remoteDataSource.uploadFile(
        file: file,
        type: type,
      );
      return ApiSuccess(fileModel);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return ApiFailure(ServerFailure(message: e.toString()));
    }
  }
}
