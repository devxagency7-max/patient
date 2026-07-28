import 'package:equatable/equatable.dart';

class PharmacistEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int activePatientsCount;
  final int? maxPatientsLimit;
  final bool isAvailable;
  final String? specialization;
  final double averageRating;

  const PharmacistEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.activePatientsCount,
    this.maxPatientsLimit,
    required this.isAvailable,
    this.specialization,
    this.averageRating = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        activePatientsCount,
        maxPatientsLimit,
        isAvailable,
        specialization,
        averageRating,
      ];
}
