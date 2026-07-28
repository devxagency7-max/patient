import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/medicine_remote_datasource.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';
import 'package:pharmacare/features/pharmacy/domain/repositories/medicine_repository.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource remoteDataSource;

  MedicineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<MedicineEntity>>> searchMedicines({
    String? query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final medicines = await remoteDataSource.searchMedicines(
        query: query,
        page: page,
        pageSize: pageSize,
      );
      return ApiSuccess(medicines);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<MedicineEntity>> getMedicineDetail(String id) async {
    try {
      final medicine = await remoteDataSource.getMedicineDetail(id);
      return ApiSuccess(medicine);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
