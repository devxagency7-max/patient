import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/pharmacy_remote_datasource.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/nearby_pharmacy_entity.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/pharmacy_branch_entity.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:pharmacare/features/pharmacy/domain/repositories/pharmacy_repository.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  final PharmacyRemoteDataSource remoteDataSource;

  PharmacyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<String>>> getGovernorates() async {
    try {
      final governorates = await remoteDataSource.getGovernorates();
      return ApiSuccess(governorates);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<PharmacyEntity>>> getPharmacies({
    String? governorate,
    required int page,
    required int pageSize,
  }) async {
    try {
      final pharmacies = await remoteDataSource.getPharmacies(
        governorate: governorate,
        page: page,
        pageSize: pageSize,
      );
      return ApiSuccess(pharmacies);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<PharmacyEntity>> getPharmacyDetail(String id) async {
    try {
      final pharmacy = await remoteDataSource.getPharmacyDetail(id);
      return ApiSuccess(pharmacy);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<PharmacyBranchEntity>>> getPharmacyBranches(String pharmacyId) async {
    try {
      final branches = await remoteDataSource.getPharmacyBranches(pharmacyId);
      return ApiSuccess(branches);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<NearbyPharmacyEntity>>> getNearbyPharmacies({
    required double lat,
    required double lng,
    double radius = 10.0,
  }) async {
    try {
      final pharmacies = await remoteDataSource.getNearbyPharmacies(
        lat: lat,
        lng: lng,
        radius: radius,
      );
      return ApiSuccess(pharmacies);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
