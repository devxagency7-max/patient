import 'dart:io';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/file_upload/domain/entities/file_entity.dart';

abstract class FileRepository {
  Future<ApiResult<FileEntity>> uploadFile({
    required File file,
    required String type,
  });
}
