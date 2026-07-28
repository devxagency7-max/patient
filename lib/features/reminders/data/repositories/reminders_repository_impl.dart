import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/reminders/data/datasources/reminders_remote_datasource.dart';
import 'package:pharmacare/features/reminders/domain/entities/medication_log_entity.dart';
import 'package:pharmacare/features/reminders/domain/entities/medication_plan_entity.dart';
import 'package:pharmacare/features/reminders/domain/entities/reminder_entity.dart';
import 'package:pharmacare/features/reminders/domain/repositories/reminders_repository.dart';

class RemindersRepositoryImpl implements RemindersRepository {
  final RemindersRemoteDataSource remoteDataSource;

  RemindersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<MedicationPlanEntity>>> getMedicationPlans() async {
    try {
      final plans = await remoteDataSource.getMedicationPlans();
      return ApiSuccess(plans);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> logMedicationIntake({
    required String medicineId,
    required String takenAt,
  }) async {
    try {
      await remoteDataSource.logMedicationIntake(
        medicineId: medicineId,
        takenAt: takenAt,
      );
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<AdherenceSummaryEntity>> getAdherenceSummary({int days = 30}) async {
    try {
      final summary = await remoteDataSource.getAdherenceSummary(days: days);
      return ApiSuccess(summary);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<MedicationLogEntity>>> getMedicationLogs({int days = 7}) async {
    try {
      final logs = await remoteDataSource.getMedicationLogs(days: days);
      return ApiSuccess(logs);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ReminderEntity>>> getReminders({
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    try {
      final reminders = await remoteDataSource.getReminders(
        fromDate: fromDate,
        toDate: toDate,
        status: status,
      );
      return ApiSuccess(reminders);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> createReminder({
    required String type,
    required String title,
    String? description,
    required String frequencyType,
    int? intervalHours,
    required String startTime,
    String? endTime,
  }) async {
    try {
      await remoteDataSource.createReminder(
        type: type,
        title: title,
        description: description,
        frequencyType: frequencyType,
        intervalHours: intervalHours,
        startTime: startTime,
        endTime: endTime,
      );
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> markReminderTaken(String id) async {
    try {
      await remoteDataSource.markReminderTaken(id);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> markReminderSkip(String id) async {
    try {
      await remoteDataSource.markReminderSkip(id);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> markReminderSnooze(String id, int minutes) async {
    try {
      await remoteDataSource.markReminderSnooze(id, minutes);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
