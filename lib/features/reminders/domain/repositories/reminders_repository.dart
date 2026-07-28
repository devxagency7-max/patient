import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/reminders/domain/entities/medication_log_entity.dart';
import 'package:pharmacare/features/reminders/domain/entities/medication_plan_entity.dart';
import 'package:pharmacare/features/reminders/domain/entities/reminder_entity.dart';

abstract class RemindersRepository {
  Future<ApiResult<List<MedicationPlanEntity>>> getMedicationPlans();
  Future<ApiResult<void>> logMedicationIntake({
    required String medicineId,
    required String takenAt,
  });
  Future<ApiResult<AdherenceSummaryEntity>> getAdherenceSummary({int days});
  Future<ApiResult<List<MedicationLogEntity>>> getMedicationLogs({int days});
  Future<ApiResult<void>> createReminder({
    required String type,
    required String title,
    String? description,
    required String frequencyType,
    int? intervalHours,
    required String startTime,
    String? endTime,
  });
  Future<ApiResult<List<ReminderEntity>>> getReminders({
    String? fromDate,
    String? toDate,
    String? status,
  });
  Future<ApiResult<void>> markReminderTaken(String id);
  Future<ApiResult<void>> markReminderSkip(String id);
  Future<ApiResult<void>> markReminderSnooze(String id, int minutes);
}
