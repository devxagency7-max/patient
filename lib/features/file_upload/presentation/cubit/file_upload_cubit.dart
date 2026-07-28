import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/file_upload/domain/usecases/upload_file_usecase.dart';
import 'package:pharmacare/features/file_upload/presentation/cubit/file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  final UploadFileUseCase uploadFileUseCase;

  FileUploadCubit({required this.uploadFileUseCase})
      : super(const FileUploadInitial());

  Future<void> uploadFile({
    required File file,
    required String type,
  }) async {
    emit(const FileUploadLoading());

    final result = await uploadFileUseCase(UploadFileParams(
      file: file,
      type: type,
    ));

    switch (result) {
      case ApiSuccess(:final data):
        emit(FileUploadSuccess(data));
      case ApiFailure(:final failure):
        emit(FileUploadError(failure.message));
    }
  }

  void reset() {
    emit(const FileUploadInitial());
  }
}
