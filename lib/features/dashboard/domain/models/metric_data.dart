import 'package:freezed_annotation/freezed_annotation.dart';

part 'metric_data.freezed.dart';
part 'metric_data.g.dart';

@freezed
class MetricData with _$MetricData {
  const factory MetricData({
    required DateTime timestamp,
    required double value,
    required String metricType,
    String? unit,
    Map<String, dynamic>? additionalData,
  }) = _MetricData;

  factory MetricData.fromJson(Map<String, dynamic> json) => _$MetricDataFromJson(json);
} 