// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MetricDataImpl _$$MetricDataImplFromJson(Map<String, dynamic> json) =>
    _$MetricDataImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      metricType: json['metricType'] as String,
      unit: json['unit'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MetricDataImplToJson(_$MetricDataImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'value': instance.value,
      'metricType': instance.metricType,
      'unit': instance.unit,
      'additionalData': instance.additionalData,
    };
