import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/profile/data/datasources/address_remote_datasource.dart';
import 'package:pharmacare/features/profile/domain/entities/address_entity.dart';
import 'package:pharmacare/features/profile/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<AddressEntity>>> getAddresses() async {
    try {
      final addresses = await remoteDataSource.getAddresses();
      return ApiSuccess(addresses);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<AddressEntity>> addAddress({
    required String street,
    required String city,
    required String governorate,
    String? additionalInfo,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      final address = await remoteDataSource.addAddress(
        street: street,
        city: city,
        governorate: governorate,
        additionalInfo: additionalInfo,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );
      return ApiSuccess(address);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> setDefaultAddress(String addressId) async {
    try {
      await remoteDataSource.setDefaultAddress(addressId);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteAddress(String addressId) async {
    try {
      await remoteDataSource.deleteAddress(addressId);
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
