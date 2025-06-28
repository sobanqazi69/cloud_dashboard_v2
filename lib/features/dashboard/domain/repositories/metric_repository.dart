import '../models/metric_data.dart';

abstract class MetricRepository {
  Stream<MetricData> getMetricStream(String metricType);
  Future<List<MetricData>> getHistoricalData(String metricType, Duration timeRange);
  Future<void> addMetricData(MetricData data);
} 