import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/reminders/data/datasources/reminders_remote_datasource.dart';
import 'package:pharmacare/features/reminders/data/models/medication_log_model.dart';
import 'package:pharmacare/features/reminders/data/models/medication_plan_model.dart';
import 'package:pharmacare/features/reminders/data/models/reminder_model.dart';

class RemindersRemoteDataSourceImpl implements RemindersRemoteDataSource {
  final ApiClient apiClient;

  RemindersRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MedicationPlanModel>> getMedicationPlans() async {
    try {
      final response = await apiClient.dio.get('medications');

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => MedicationPlanModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get medications',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logMedicationIntake({
    required String medicineId,
    required String takenAt,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'medications/log',
        data: {
          'medicineId': medicineId,
          'takenAt': takenAt,
        },
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to log intake',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AdherenceSummaryModel> getAdherenceSummary({int days = 30}) async {
    try {
      final response = await apiClient.dio.get(
        'medications/adherence',
        queryParameters: {'days': days},
      );

      if (response.data['success'] == true) {
        return AdherenceSummaryModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch adherence summary',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MedicationLogModel>> getMedicationLogs({int days = 7}) async {
    try {
      final response = await apiClient.dio.get(
        'medications/logs',
        queryParameters: {'days': days},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => MedicationLogModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch medication logs',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ReminderModel>> getReminders({
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fromDate != null) queryParams['fromDate'] = fromDate;
      if (toDate != null) queryParams['toDate'] = toDate;
      if (status != null) queryParams['status'] = status;

      final response = await apiClient.dio.get(
        'reminders',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => ReminderModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get reminders',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> createReminder({
    required String type,
    required String title,
    String? description,
    required String frequencyType,
    int? intervalHours,
    required String startTime,
    String? endTime,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'reminders',
        data: {
          'type': type,
          'title': title,
          if (description != null && description.isNotEmpty) 'description': description,
          'frequencyType': frequencyType,
          if (intervalHours != null) 'intervalHours': intervalHours,
          'startTime': startTime,
          if (endTime != null) 'endTime': endTime,
        },
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create reminder',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markReminderTaken(String id) async {
    try {
      final response = await apiClient.dio.post('reminders/$id/taken');

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to mark taken',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markReminderSkip(String id) async {
    try {
      final response = await apiClient.dio.post('reminders/$id/skip');

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to mark skip',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markReminderSnooze(String id, int minutes) async {
    try {
      final response = await apiClient.dio.post(
        'reminders/$id/snooze',
        data: {'minutes': minutes},
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to snooze reminder',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
