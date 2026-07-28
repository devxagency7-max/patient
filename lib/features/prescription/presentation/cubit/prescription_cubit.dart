import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/prescription/domain/usecases/create_prescription_usecase.dart';
import 'package:pharmacare/features/prescription/presentation/cubit/prescription_state.dart';

class PrescriptionCubit extends Cubit<PrescriptionState> {
  final CreatePrescriptionUseCase createPrescriptionUseCase;

  PrescriptionCubit({required this.createPrescriptionUseCase}) : super(PrescriptionInitial());

  Future<void> createPrescription({
    String? doctorName,
    String? clinicName,
    String? issueDate,
    String? expiryDate,
    List<String> uploadedFileIds = const [],
  }) async {
    emit(PrescriptionLoading());

    final result = await createPrescriptionUseCase(
      doctorName: doctorName,
      clinicName: clinicName,
      issueDate: issueDate,
      expiryDate: expiryDate,
      imageUrls: uploadedFileIds,
    );

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(PrescriptionSuccess(data));
      case ApiFailure(:final failure):
        emit(PrescriptionError(failure.message));
    }
  }
}
