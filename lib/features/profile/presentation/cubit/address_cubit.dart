import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/profile/domain/repositories/address_repository.dart';
import 'package:pharmacare/features/profile/presentation/cubit/address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository addressRepository;

  AddressCubit({required this.addressRepository}) : super(AddressInitial());

  Future<void> fetchAddresses() async {
    emit(AddressLoading());
    final result = await addressRepository.getAddresses();
    switch (result) {
      case ApiSuccess(:final data):
        emit(AddressesLoaded(data));
      case ApiFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }

  Future<void> addAddress({
    required String street,
    required String city,
    required String governorate,
    String? additionalInfo,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    emit(AddressLoading());
    final result = await addressRepository.addAddress(
      street: street,
      city: city,
      governorate: governorate,
      additionalInfo: additionalInfo,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
    switch (result) {
      case ApiSuccess():
        emit(const AddressOperationSuccess('تم إضافة العنوان بنجاح'));
        await fetchAddresses();
      case ApiFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }

  Future<void> setDefault(String addressId) async {
    emit(AddressLoading());
    final result = await addressRepository.setDefaultAddress(addressId);
    switch (result) {
      case ApiSuccess():
        emit(const AddressOperationSuccess('تم تعديل العنوان الافتراضي'));
        await fetchAddresses();
      case ApiFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }

  Future<void> deleteAddress(String addressId) async {
    emit(AddressLoading());
    final result = await addressRepository.deleteAddress(addressId);
    switch (result) {
      case ApiSuccess():
        emit(const AddressOperationSuccess('تم حذف العنوان بنجاح'));
        await fetchAddresses();
      case ApiFailure(:final failure):
        emit(AddressError(failure.message));
    }
  }
}
