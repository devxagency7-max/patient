import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/prescription/domain/repositories/prescription_repository.dart';
import 'package:pharmacare/features/prescription/presentation/cubit/my_prescriptions_state.dart';

class MyPrescriptionsCubit extends Cubit<MyPrescriptionsState> {
  final PrescriptionRepository prescriptionRepository;

  MyPrescriptionsCubit({required this.prescriptionRepository}) : super(MyPrescriptionsInitial());

  Future<void> fetchMyPrescriptions() async {
    emit(MyPrescriptionsLoading());

    final result = await prescriptionRepository.getMyPrescriptions(page: 1, pageSize: 20);

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(MyPrescriptionsLoaded(data));
      case ApiFailure(:final failure):
        emit(MyPrescriptionsError(failure.message));
    }
  }
}
