import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/profile/domain/entities/address_entity.dart';

abstract class AddressRepository {
  Future<ApiResult<List<AddressEntity>>> getAddresses();
  Future<ApiResult<AddressEntity>> addAddress({
    required String street,
    required String city,
    required String governorate,
    String? additionalInfo,
    double? latitude,
    double? longitude,
    bool isDefault,
  });
  Future<ApiResult<void>> setDefaultAddress(String addressId);
  Future<ApiResult<void>> deleteAddress(String addressId);
}
