import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/medical_records/data/datasources/medical_record_remote_datasource.dart';
import 'package:pharmacare/features/medical_records/domain/entities/medical_record_entity.dart';
import 'package:pharmacare/features/medical_records/domain/repositories/medical_record_repository.dart';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final MedicalRecordRemoteDataSource remoteDataSource;

  MedicalRecordRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<MedicalRecordEntity>> createMedicalRecord({
    required String uploadedFileId,
    required String type,
    String? title,
    String? recordedAt,
  }) async {
    try {
      final record = await remoteDataSource.createMedicalRecord(
        uploadedFileId: uploadedFileId,
        type: type,
        title: title,
        recordedAt: recordedAt,
      );
      return ApiSuccess(record);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<MedicalRecordEntity>>> getMedicalRecords({
    String? type,
    required int page,
    required int pageSize,
  }) async {
    try {
      final records = await remoteDataSource.getMedicalRecords(type: type, page: page, pageSize: pageSize);
      return ApiSuccess(records);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteMedicalRecord(String id) async {
    try {
      await remoteDataSource.deleteMedicalRecord(id);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
