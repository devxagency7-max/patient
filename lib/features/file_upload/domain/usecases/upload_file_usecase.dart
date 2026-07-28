import 'dart:io';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/core/usecases/usecase.dart';
import 'package:pharmacare/features/file_upload/domain/entities/file_entity.dart';
import 'package:pharmacare/features/file_upload/domain/repositories/file_repository.dart';

class UploadFileUseCase implements UseCase<FileEntity, UploadFileParams> {
  final FileRepository repository;

  UploadFileUseCase(this.repository);

  @override
  Future<ApiResult<FileEntity>> call(UploadFileParams params) async {
    return await repository.uploadFile(
      file: params.file,
      type: params.type,
    );
  }
}

class UploadFileParams {
  final File file;
  final String type;

  UploadFileParams({
    required this.file,
    required this.type,
  });
}
