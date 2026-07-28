import 'package:pharmacare/features/file_upload/domain/entities/file_entity.dart';

sealed class FileUploadState {
  const FileUploadState();
}

class FileUploadInitial extends FileUploadState {
  const FileUploadInitial();
}

class FileUploadLoading extends FileUploadState {
  const FileUploadLoading();
}

class FileUploadSuccess extends FileUploadState {
  final FileEntity file;
  const FileUploadSuccess(this.file);
}

class FileUploadError extends FileUploadState {
  final String message;
  const FileUploadError(this.message);
}
