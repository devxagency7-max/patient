import 'package:pharmacare/features/reminders/data/models/medication_log_model.dart';
import 'package:pharmacare/features/reminders/data/models/medication_plan_model.dart';
import 'package:pharmacare/features/reminders/data/models/reminder_model.dart';

abstract class RemindersRemoteDataSource {
  Future<List<MedicationPlanModel>> getMedicationPlans();
  Future<void> logMedicationIntake({
    required String medicineId,
    required String takenAt,
  });
  Future<AdherenceSummaryModel> getAdherenceSummary({int days});
  Future<List<MedicationLogModel>> getMedicationLogs({int days});
  /// POST /reminders — matches backend `CreateReminderRequest`.
  Future<void> createReminder({
    required String type,
    required String title,
    String? description,
    required String frequencyType,
    int? intervalHours,
    required String startTime,
    String? endTime,
  });
  Future<List<ReminderModel>> getReminders({
    String? fromDate,
    String? toDate,
    String? status,
  });
  Future<void> markReminderTaken(String id);
  Future<void> markReminderSkip(String id);
  Future<void> markReminderSnooze(String id, int minutes);
}
