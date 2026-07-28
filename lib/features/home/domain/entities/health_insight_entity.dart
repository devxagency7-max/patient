import 'package:equatable/equatable.dart';

class HealthInsightEntity extends Equatable {
  final String summary;
  final String riskLevel; // Low, Moderate, High
  final List<String> suggestions;

  const HealthInsightEntity({
    required this.summary,
    required this.riskLevel,
    required this.suggestions,
  });

  @override
  List<Object?> get props => [summary, riskLevel, suggestions];
}
