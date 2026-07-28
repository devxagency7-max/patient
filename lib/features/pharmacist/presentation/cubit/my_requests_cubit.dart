import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/core/services/care_request_cache_service.dart';
import 'package:pharmacare/features/pharmacist/domain/repositories/pharmacist_repository.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/my_requests_state.dart';

class MyRequestsCubit extends Cubit<MyRequestsState> {
  final PharmacistRepository pharmacistRepository;
  final CareRequestCacheService careRequestCacheService;

  MyRequestsCubit({
    required this.pharmacistRepository,
    required this.careRequestCacheService,
  }) : super(MyRequestsInitial());

  /// آخر حالة معروفة (من الكاش) لوجود طلب رعاية نشط/معلّق — تُستخدم لمنع
  /// وميض البانر في الواجهة أثناء إعادة التحميل قبل وصول رد السيرفر.
  bool get cachedHasActiveOrPending =>
      careRequestCacheService.getHasActiveOrPending();

  Future<void> fetchMyRequests() async {
    emit(MyRequestsLoading());

    final result = await pharmacistRepository.getMyRequests();

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        final hasActiveOrPending = data.any(
          (r) => r.status == 'Active' || r.status == 'Pending',
        );
        await careRequestCacheService.setHasActiveOrPending(hasActiveOrPending);
        emit(MyRequestsLoaded(data));
      case ApiFailure(:final failure):
        emit(MyRequestsError(failure.message));
    }
  }

  Future<void> cancelRequest(String requestId) async {
    final result = await pharmacistRepository.cancelRequest(requestId);
    if (isClosed) return;
    if (result is ApiSuccess) {
      fetchMyRequests();
    }
  }

  Future<void> terminateRelationship(String requestId) async {
    final result = await pharmacistRepository.terminateRelationship(requestId);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        fetchMyRequests();
      case ApiFailure(:final failure):
        emit(MyRequestsError(failure.message));
        fetchMyRequests();
    }
  }
}
