import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacist/domain/repositories/pharmacist_repository.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/pharmacist_state.dart';

class PharmacistCubit extends Cubit<PharmacistState> {
  final PharmacistRepository pharmacistRepository;

  PharmacistCubit({required this.pharmacistRepository}) : super(PharmacistInitial());

  Future<void> fetchPharmacists() async {
    emit(PharmacistLoading());
    final result = await pharmacistRepository.getPharmacists();

    switch (result) {
      case ApiSuccess(:final data):
        emit(PharmacistsLoaded(data));
      case ApiFailure(:final failure):
        emit(PharmacistError(failure.message));
    }
  }

  Future<void> requestPharmacist({required String pharmacistId}) async {
    emit(PharmacistLoading());
    final result = await pharmacistRepository.requestPharmacist(
      pharmacistId: pharmacistId,
    );

    switch (result) {
      case ApiSuccess():
        emit(PharmacistRequestSuccess());
      case ApiFailure(:final failure):
        emit(PharmacistError(failure.message));
    }
  }
}
