import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/prescription/data/datasources/prescription_remote_datasource.dart';
import 'package:pharmacare/features/prescription/domain/entities/prescription_entity.dart';
import 'package:pharmacare/features/prescription/domain/repositories/prescription_repository.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionRemoteDataSource remoteDataSource;

  PrescriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<PrescriptionEntity>> createPrescription({
    String? doctorName,
    String? clinicName,
    String? issueDate,
    String? expiryDate,
    List<String> imageUrls = const [],
  }) async {
    try {
      final prescription = await remoteDataSource.createPrescription(
        doctorName: doctorName,
        clinicName: clinicName,
        issueDate: issueDate,
        expiryDate: expiryDate,
        imageUrls: imageUrls,
      );
      return ApiSuccess(prescription);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<PrescriptionEntity>>> getMyPrescriptions({
    required int page,
    required int pageSize,
  }) async {
    try {
      final prescriptions = await remoteDataSource.getMyPrescriptions(page: page, pageSize: pageSize);
      return ApiSuccess(prescriptions);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<PrescriptionEntity>> getPrescriptionById(String id) async {
    try {
      final prescription = await remoteDataSource.getPrescriptionById(id);
      return ApiSuccess(prescription);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
