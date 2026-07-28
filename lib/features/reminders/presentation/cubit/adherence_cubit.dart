import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/reminders/domain/repositories/reminders_repository.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/adherence_state.dart';

class AdherenceCubit extends Cubit<AdherenceState> {
  final RemindersRepository remindersRepository;

  AdherenceCubit({required this.remindersRepository}) : super(AdherenceInitial());

  Future<void> fetchAdherence({int days = 30}) async {
    emit(AdherenceLoading());

    final summaryResult = await remindersRepository.getAdherenceSummary(days: days);
    final logsResult = await remindersRepository.getMedicationLogs(days: days >= 7 ? 7 : days);

    if (isClosed) return;

    if (summaryResult case ApiFailure(:final failure)) {
      emit(AdherenceError(failure.message));
      return;
    }
    if (logsResult case ApiFailure(:final failure)) {
      emit(AdherenceError(failure.message));
      return;
    }

    final summary = (summaryResult as ApiSuccess).data;
    final logs = (logsResult as ApiSuccess).data;
    emit(AdherenceLoaded(summary: summary, logs: logs));
  }
}
