import 'package:pharmacare/features/profile/data/models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress({
    required String street,
    required String city,
    required String governorate,
    String? additionalInfo,
    double? latitude,
    double? longitude,
    bool isDefault,
  });
  Future<void> setDefaultAddress(String addressId);
  Future<void> deleteAddress(String addressId);
}
