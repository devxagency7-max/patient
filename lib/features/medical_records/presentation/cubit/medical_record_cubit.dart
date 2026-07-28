import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/file_upload/domain/repositories/file_repository.dart';
import 'package:pharmacare/features/medical_records/domain/repositories/medical_record_repository.dart';
import 'package:pharmacare/features/medical_records/presentation/cubit/medical_record_state.dart';

class MedicalRecordCubit extends Cubit<MedicalRecordState> {
  final MedicalRecordRepository medicalRecordRepository;
  final FileRepository fileRepository;

  MedicalRecordCubit({
    required this.medicalRecordRepository,
    required this.fileRepository,
  }) : super(MedicalRecordInitial());

  Future<void> fetchMedicalRecords({String? type}) async {
    emit(MedicalRecordLoading());

    final result = await medicalRecordRepository.getMedicalRecords(type: type, page: 1, pageSize: 20);

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(MedicalRecordLoaded(data));
      case ApiFailure(:final failure):
        emit(MedicalRecordError(failure.message));
    }
  }

  Future<void> uploadAndCreateRecord({
    required File file,
    required String type,
    String? title,
    String? recordedAt,
  }) async {
    emit(MedicalRecordSubmitting());

    final fileTypeForUpload = (type == 'LabResult' || type == 'XRay' || type == 'MedicalReport')
        ? type
        : 'MedicalReport';
    final uploadResult = await fileRepository.uploadFile(file: file, type: fileTypeForUpload);
    if (isClosed) return;

    switch (uploadResult) {
      case ApiFailure(:final failure):
        emit(MedicalRecordError(failure.message));
        return;
      case ApiSuccess(:final data):
        final createResult = await medicalRecordRepository.createMedicalRecord(
          uploadedFileId: data.id,
          type: type,
          title: title,
          recordedAt: recordedAt,
        );

        if (isClosed) return;
        switch (createResult) {
          case ApiSuccess():
            emit(MedicalRecordSubmitSuccess());
          case ApiFailure(:final failure):
            emit(MedicalRecordError(failure.message));
        }
    }
  }

  Future<void> deleteRecord(String id) async {
    final result = await medicalRecordRepository.deleteMedicalRecord(id);
    if (isClosed) return;
    if (result is ApiSuccess) {
      fetchMedicalRecords();
    }
  }
}
