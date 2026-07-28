import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacy/domain/repositories/medicine_repository.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/medicine_search_state.dart';

class MedicineSearchCubit extends Cubit<MedicineSearchState> {
  final MedicineRepository medicineRepository;

  int page = 1;
  static const int pageSize = 10;
  String currentQuery = '';
  List<MedicineEntity> loadedMedicines = [];

  MedicineSearchCubit({required this.medicineRepository}) : super(MedicineSearchInitial());

  Future<void> searchMedicines(String query, {bool isNewSearch = true}) async {
    if (isNewSearch) {
      page = 1;
      currentQuery = query;
      loadedMedicines = [];
      emit(MedicineSearchLoading(const [], isFirstFetch: true));
    } else {
      if (state is MedicineSearchLoaded && (state as MedicineSearchLoaded).hasReachedMax) {
        return;
      }
      emit(MedicineSearchLoading(loadedMedicines));
    }

    final result = await medicineRepository.searchMedicines(
      query: currentQuery.isNotEmpty ? currentQuery : null,
      page: page,
      pageSize: pageSize,
    );

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        final newMedicines = data;
        final hasReachedMax = newMedicines.length < pageSize;
        loadedMedicines.addAll(newMedicines);
        page++;
        emit(MedicineSearchLoaded(List.from(loadedMedicines), hasReachedMax: hasReachedMax));
      case ApiFailure(:final failure):
        emit(MedicineSearchError(failure.message));
    }
  }

  void loadNextPage() {
    searchMedicines(currentQuery, isNewSearch: false);
  }
}
