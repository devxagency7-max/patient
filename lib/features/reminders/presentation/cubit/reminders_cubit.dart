import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/reminders/domain/repositories/reminders_repository.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_state.dart';
import 'package:pharmacare/features/reminders/domain/entities/reminder_entity.dart';
import 'package:pharmacare/features/reminders/domain/entities/medication_plan_entity.dart';

class RemindersCubit extends Cubit<RemindersState> {
  final RemindersRepository remindersRepository;

  RemindersCubit({required this.remindersRepository}) : super(RemindersInitial());

  Future<void> fetchRemindersAndPlans() async {
    emit(RemindersLoading());
    final remindersResult = await remindersRepository.getReminders();
    final plansResult = await remindersRepository.getMedicationPlans();

    List<ReminderEntity> reminders = [];
    List<MedicationPlanEntity> plans = [];
    String? errorMessage;

    switch (remindersResult) {
      case ApiSuccess(:final data):
        reminders = data;
      case ApiFailure(:final failure):
        errorMessage = failure.message;
    }

    switch (plansResult) {
      case ApiSuccess(:final data):
        plans = data;
      case ApiFailure(:final failure):
        errorMessage ??= failure.message;
    }

    if (isClosed) return;
    if (errorMessage != null) {
      emit(RemindersError(errorMessage));
    } else {
      emit(RemindersLoaded(reminders: reminders, medicationPlans: plans));
    }
  }

  Future<void> takeReminder(String id, {String? medicineId}) async {
    emit(RemindersLoading());
    final result = await remindersRepository.markReminderTaken(id);

    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        if (medicineId != null) {
          await remindersRepository.logMedicationIntake(
            medicineId: medicineId,
            takenAt: DateTime.now().toIso8601String(),
          );
        }
        if (isClosed) return;
        emit(const RemindersOperationSuccess('تم تسجيل الجرعة بنجاح ✓'));
        await fetchRemindersAndPlans();
      case ApiFailure(:final failure):
        emit(RemindersError(failure.message));
    }
  }

  Future<void> skipReminder(String id) async {
    emit(RemindersLoading());
    final result = await remindersRepository.markReminderSkip(id);

    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        emit(const RemindersOperationSuccess('تم تخطي التذكير'));
        await fetchRemindersAndPlans();
      case ApiFailure(:final failure):
        emit(RemindersError(failure.message));
    }
  }

  Future<void> createReminder({
    required String type,
    required String title,
    String? description,
    required String frequencyType,
    int? intervalHours,
    required String startTime,
    String? endTime,
  }) async {
    emit(RemindersLoading());
    final result = await remindersRepository.createReminder(
      type: type,
      title: title,
      description: description,
      frequencyType: frequencyType,
      intervalHours: intervalHours,
      startTime: startTime,
      endTime: endTime,
    );

    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        emit(const RemindersOperationSuccess('تم إضافة التذكير بنجاح'));
        await fetchRemindersAndPlans();
      case ApiFailure(:final failure):
        emit(RemindersError(failure.message));
    }
  }

  Future<void> snoozeReminder(String id, int minutes) async {
    emit(RemindersLoading());
    final result = await remindersRepository.markReminderSnooze(id, minutes);

    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        emit(const RemindersOperationSuccess('تم تأجيل التنبيه'));
        await fetchRemindersAndPlans();
      case ApiFailure(:final failure):
        emit(RemindersError(failure.message));
    }
  }
}
