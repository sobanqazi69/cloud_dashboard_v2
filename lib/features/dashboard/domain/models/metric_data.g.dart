// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetricData _$MetricDataFromJson(Map<String, dynamic> json) => MetricData(
  timestamp: _timestampFromJson(json['timestamp']),
  value: (json['value'] as num).toDouble(),
  metricType: json['metricType'] as String,
  unit: json['unit'] as String?,
  additionalData: json['additionalData'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MetricDataToJson(MetricData instance) =>
    <String, dynamic>{
      'timestamp': _timestampToJson(instance.timestamp),
      'value': instance.value,
      'metricType': instance.metricType,
      'unit': instance.unit,
      'additionalData': instance.additionalData,
    };
