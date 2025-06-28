import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/metric_data.dart';

// Events
abstract class MetricEvent extends Equatable {
  const MetricEvent();

  @override
  List<Object?> get props => [];
}

class FetchMetricData extends MetricEvent {
  final String metricType;
  final Duration timeRange;

  const FetchMetricData({
    required this.metricType,
    this.timeRange = const Duration(hours: 24),
  });

  @override
  List<Object?> get props => [metricType, timeRange];
}

class UpdateMetricData extends MetricEvent {
  final MetricData newData;

  const UpdateMetricData(this.newData);

  @override
  List<Object?> get props => [newData];
}

// States
abstract class MetricState extends Equatable {
  const MetricState();

  @override
  List<Object?> get props => [];
}

class MetricInitial extends MetricState {}

class MetricLoading extends MetricState {}

class MetricLoaded extends MetricState {
  final List<MetricData> data;
  final String metricType;
  final DateTime lastUpdated;

  const MetricLoaded({
    required this.data,
    required this.metricType,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [data, metricType, lastUpdated];
}

class MetricError extends MetricState {
  final String message;

  const MetricError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MetricBloc extends Bloc<MetricEvent, MetricState> {
  final StreamSubscription<MetricData>? _dataSubscription;

  MetricBloc() : _dataSubscription = null, super(MetricInitial()) {
    on<FetchMetricData>(_onFetchMetricData);
    on<UpdateMetricData>(_onUpdateMetricData);
  }

  Future<void> _onFetchMetricData(
    FetchMetricData event,
    Emitter<MetricState> emit,
  ) async {
    try {
      emit(MetricLoading());
      
      // TODO: Implement actual data fetching from Firebase
      // For now, generate dummy data
      final now = DateTime.now();
      final data = List.generate(100, (index) {
        final time = now.subtract(Duration(minutes: 100 - index));
        return MetricData(
          timestamp: time,
          value: 85.0 + (index % 10) * 0.5,
          metricType: event.metricType,
          unit: '%',
        );
      });

      emit(MetricLoaded(
        data: data,
        metricType: event.metricType,
        lastUpdated: now,
      ));
    } catch (e) {
      emit(MetricError(e.toString()));
    }
  }

  void _onUpdateMetricData(
    UpdateMetricData event,
    Emitter<MetricState> emit,
  ) {
    if (state is MetricLoaded) {
      final currentState = state as MetricLoaded;
      final updatedData = List<MetricData>.from(currentState.data)
        ..add(event.newData);
      
      if (updatedData.length > 100) {
        updatedData.removeAt(0);
      }

      emit(MetricLoaded(
        data: updatedData,
        metricType: currentState.metricType,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }
} 