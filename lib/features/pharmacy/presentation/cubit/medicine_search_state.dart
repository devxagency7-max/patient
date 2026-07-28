import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';

abstract class MedicineSearchState extends Equatable {
  const MedicineSearchState();

  @override
  List<Object?> get props => [];
}

class MedicineSearchInitial extends MedicineSearchState {}

class MedicineSearchLoading extends MedicineSearchState {
  final List<MedicineEntity> oldMedicines;
  final bool isFirstFetch;

  const MedicineSearchLoading(this.oldMedicines, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldMedicines, isFirstFetch];
}

class MedicineSearchLoaded extends MedicineSearchState {
  final List<MedicineEntity> medicines;
  final bool hasReachedMax;

  const MedicineSearchLoaded(this.medicines, {required this.hasReachedMax});

  @override
  List<Object?> get props => [medicines, hasReachedMax];
}

class MedicineSearchError extends MedicineSearchState {
  final String message;

  const MedicineSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
