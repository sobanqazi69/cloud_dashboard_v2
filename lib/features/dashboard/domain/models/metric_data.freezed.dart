// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metric_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MetricData _$MetricDataFromJson(Map<String, dynamic> json) {
  return _MetricData.fromJson(json);
}

/// @nodoc
mixin _$MetricData {
  DateTime get timestamp => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  String get metricType => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  Map<String, dynamic>? get additionalData =>
      throw _privateConstructorUsedError;

  /// Serializes this MetricData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MetricData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MetricDataCopyWith<MetricData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetricDataCopyWith<$Res> {
  factory $MetricDataCopyWith(
          MetricData value, $Res Function(MetricData) then) =
      _$MetricDataCopyWithImpl<$Res, MetricData>;
  @useResult
  $Res call(
      {DateTime timestamp,
      double value,
      String metricType,
      String? unit,
      Map<String, dynamic>? additionalData});
}

/// @nodoc
class _$MetricDataCopyWithImpl<$Res, $Val extends MetricData>
    implements $MetricDataCopyWith<$Res> {
  _$MetricDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MetricData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? value = null,
    Object? metricType = null,
    Object? unit = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      metricType: null == metricType
          ? _value.metricType
          : metricType // ignore: cast_nullable_to_non_nullable
              as String,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalData: freezed == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MetricDataImplCopyWith<$Res>
    implements $MetricDataCopyWith<$Res> {
  factory _$$MetricDataImplCopyWith(
          _$MetricDataImpl value, $Res Function(_$MetricDataImpl) then) =
      __$$MetricDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      double value,
      String metricType,
      String? unit,
      Map<String, dynamic>? additionalData});
}

/// @nodoc
class __$$MetricDataImplCopyWithImpl<$Res>
    extends _$MetricDataCopyWithImpl<$Res, _$MetricDataImpl>
    implements _$$MetricDataImplCopyWith<$Res> {
  __$$MetricDataImplCopyWithImpl(
      _$MetricDataImpl _value, $Res Function(_$MetricDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MetricData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? value = null,
    Object? metricType = null,
    Object? unit = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(_$MetricDataImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      metricType: null == metricType
          ? _value.metricType
          : metricType // ignore: cast_nullable_to_non_nullable
              as String,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalData: freezed == additionalData
          ? _value._additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MetricDataImpl implements _MetricData {
  const _$MetricDataImpl(
      {required this.timestamp,
      required this.value,
      required this.metricType,
      this.unit,
      final Map<String, dynamic>? additionalData})
      : _additionalData = additionalData;

  factory _$MetricDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetricDataImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final double value;
  @override
  final String metricType;
  @override
  final String? unit;
  final Map<String, dynamic>? _additionalData;
  @override
  Map<String, dynamic>? get additionalData {
    final value = _additionalData;
    if (value == null) return null;
    if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MetricData(timestamp: $timestamp, value: $value, metricType: $metricType, unit: $unit, additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetricDataImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.metricType, metricType) ||
                other.metricType == metricType) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            const DeepCollectionEquality()
                .equals(other._additionalData, _additionalData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, value, metricType,
      unit, const DeepCollectionEquality().hash(_additionalData));

  /// Create a copy of MetricData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MetricDataImplCopyWith<_$MetricDataImpl> get copyWith =>
      __$$MetricDataImplCopyWithImpl<_$MetricDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetricDataImplToJson(
      this,
    );
  }
}

abstract class _MetricData implements MetricData {
  const factory _MetricData(
      {required final DateTime timestamp,
      required final double value,
      required final String metricType,
      final String? unit,
      final Map<String, dynamic>? additionalData}) = _$MetricDataImpl;

  factory _MetricData.fromJson(Map<String, dynamic> json) =
      _$MetricDataImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  double get value;
  @override
  String get metricType;
  @override
  String? get unit;
  @override
  Map<String, dynamic>? get additionalData;

  /// Create a copy of MetricData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetricDataImplCopyWith<_$MetricDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
