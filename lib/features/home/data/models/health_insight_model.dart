import 'package:pharmacare/features/home/domain/entities/health_insight_entity.dart';

class HealthInsightModel extends HealthInsightEntity {
  const HealthInsightModel({
    required super.summary,
    required super.riskLevel,
    required List<String> super.suggestions,
  });

  factory HealthInsightModel.fromJson(Map<String, dynamic> json) {
    var suggList = json['suggestions'] as List? ?? [];
    List<String> suggestionsStr = suggList.map((e) => e.toString()).toList();

    return HealthInsightModel(
      summary: json['summary'] as String? ?? '',
      riskLevel: json['riskLevel'] as String? ?? 'Low',
      suggestions: suggestionsStr,
    );
  }
}
