import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'metric_data.g.dart';

DateTime _timestampFromJson(dynamic json) {
  try {
    if (json is Timestamp) {
      return DateTime.fromMillisecondsSinceEpoch(json.millisecondsSinceEpoch);
    } else if (json is Map) {
      if (json.containsKey('_seconds')) {
        final seconds = json['_seconds'] as int;
        final nanoseconds = json['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000),
        );
      } else if (json.containsKey('seconds')) {
        final seconds = json['seconds'] as int;
        final nanoseconds = json['nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000),
        );
      }
    } else if (json is String) {
      return DateTime.parse(json);
    }
  } catch (e) {
    print('Error parsing timestamp: $e');
  }
  return DateTime.now();
}

String _timestampToJson(DateTime time) => time.toIso8601String();

@JsonSerializable()
class MetricData {
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;
  final double value;
  final String metricType;
  final String? unit;
  final Map<String, dynamic>? additionalData;

  const MetricData({
    required this.timestamp,
    required this.value,
    required this.metricType,
    this.unit,
    this.additionalData,
  });

  factory MetricData.fromJson(Map<String, dynamic> json) => _$MetricDataFromJson(json);
  Map<String, dynamic> toJson() => _$MetricDataToJson(this);

  MetricData copyWith({
    DateTime? timestamp,
    double? value,
    String? metricType,
    String? unit,
    Map<String, dynamic>? additionalData,
  }) {
    return MetricData(
      timestamp: timestamp ?? this.timestamp,
      value: value ?? this.value,
      metricType: metricType ?? this.metricType,
      unit: unit ?? this.unit,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MetricData &&
        other.timestamp == timestamp &&
        other.value == value &&
        other.metricType == metricType &&
        other.unit == unit &&
        _mapEquals(other.additionalData, additionalData);
  }

  @override
  int get hashCode {
    return Object.hash(
      timestamp,
      value,
      metricType,
      unit,
      additionalData == null ? null : Map<String, dynamic>.from(additionalData!),
    );
  }

  @override
  String toString() {
    return 'MetricData(timestamp: $timestamp, value: $value, metricType: $metricType, unit: $unit, additionalData: $additionalData)';
  }
}

bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  return a.entries.every((e) => b.containsKey(e.key) && b[e.key] == e.value);
} 