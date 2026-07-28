import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/pharmacy_state.dart';

class PharmacyCubit extends Cubit<PharmacyState> {
  final PharmacyRepository pharmacyRepository;

  PharmacyCubit({required this.pharmacyRepository}) : super(PharmacyInitial());

  Future<void> fetchPharmacies({String? governorate}) async {
    emit(PharmacyLoading());

    final result = await pharmacyRepository.getPharmacies(
      governorate: governorate,
      page: 1,
      pageSize: 20,
    );

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(PharmaciesLoaded(data));
      case ApiFailure(:final failure):
        emit(PharmacyError(failure.message));
    }
  }
}
