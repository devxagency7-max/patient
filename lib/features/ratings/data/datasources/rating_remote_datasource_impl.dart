import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/ratings/data/datasources/rating_remote_datasource.dart';
import 'package:pharmacare/features/ratings/data/models/rating_model.dart';

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  final ApiClient apiClient;

  RatingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<RatingModel> submitRating({
    required String targetType,
    String? pharmacistId,
    String? pharmacyId,
    required int score,
    String? comment,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'ratings',
        data: {
          'targetType': targetType,
          'pharmacistId': pharmacistId,
          'pharmacyId': pharmacyId,
          'score': score,
          'comment': comment,
        },
      );

      if (response.data['success'] == true) {
        return RatingModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to submit rating',
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
  Future<List<RatingModel>> getPharmacistRatings({
    required String pharmacistId,
    required int page,
    required int pageSize,
  }) async {
    return _getRatings('ratings/pharmacist/$pharmacistId', page: page, pageSize: pageSize);
  }

  @override
  Future<List<RatingModel>> getPharmacyRatings({
    required String pharmacyId,
    required int page,
    required int pageSize,
  }) async {
    return _getRatings('ratings/pharmacy/$pharmacyId', page: page, pageSize: pageSize);
  }

  Future<List<RatingModel>> _getRatings(
    String path, {
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.dio.get(
        path,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => RatingModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch ratings',
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
