import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class SensorApiService {
  static const String _baseUrl = 'https://cloud-dashboard-p24lcizz6-sobans-projects-af793893.vercel.app/api';
  static const String _sensorDataEndpoint = '/sensor-data';
  
  final http.Client _client;

  SensorApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches sensor data from the Railway API
  Future<SensorDataResponse> getSensorData({
    int page = 1,
    int limit = 1000,
  }) async {
    try {
      developer.log('Fetching sensor data from API - Page: $page, Limit: $limit');
      
      final uri = Uri.parse('$_baseUrl$_sensorDataEndpoint')
          .replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - API took too long to respond');
        },
      );

      developer.log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final sensorResponse = SensorDataResponse.fromJson(jsonData);
        
        developer.log('Successfully fetched ${sensorResponse.data.length} sensor records');
        return sensorResponse;
      } else {
        developer.log('API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch sensor data: HTTP ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching sensor data: $e');
      rethrow;
    }
  }

  /// Gets the latest sensor data (first record from the API)
  Future<SensorData?> getLatestSensorData() async {
    try {
      final response = await getSensorData(page: 1, limit: 1);
      return response.data.isNotEmpty ? response.data.first : null;
    } catch (e) {
      developer.log('Error fetching latest sensor data: $e');
      rethrow;
    }
  }

  /// Gets historical sensor data for a specific time range
  Future<List<SensorData>> getHistoricalData({
    int hours = 24,
    int maxRecords = 1000,
  }) async {
    try {
      developer.log('Fetching historical data for last $hours hours');
      
      // Since the API returns data in reverse chronological order,
      // we'll fetch more records and filter by time
      final response = await getSensorData(page: 1, limit: maxRecords);
      
      final now = DateTime.now();
      final cutoffTime = now.subtract(Duration(hours: hours));
      
      // Filter data within the specified time range
      final filteredData = response.data.where((data) {
        final dataTime = data.parsedTimestamp;
        return dataTime.isAfter(cutoffTime);
      }).toList();
      
      // Sort by timestamp (oldest first for charting)
      filteredData.sort((a, b) => a.parsedTimestamp.compareTo(b.parsedTimestamp));
      
      developer.log('Filtered ${filteredData.length} records within $hours hours');
      return filteredData;
    } catch (e) {
      developer.log('Error fetching historical data: $e');
      rethrow;
    }
  }

  /// Stream that periodically fetches the latest sensor data
  Stream<SensorData?> getLatestSensorDataStream({
    Duration interval = const Duration(seconds: 30),
  }) async* {
    while (true) {
      try {
        final latestData = await getLatestSensorData();
        yield latestData;
      } catch (e) {
        developer.log('Error in sensor data stream: $e');
        yield null;
      }
      
      await Future.delayed(interval);
    }
  }

  /// Stream that periodically fetches historical data for charts
  Stream<List<SensorData>> getHistoricalDataStream({
    int hours = 24,
    Duration interval = const Duration(minutes: 1),
  }) async* {
    while (true) {
      try {
        final historicalData = await getHistoricalData(hours: hours);
        yield historicalData;
      } catch (e) {
        developer.log('Error in historical data stream: $e');
        yield [];
      }
      
      await Future.delayed(interval);
    }
  }

  /// Gets sensor data for a specific metric type
  List<MetricDataPoint> getMetricDataPoints(
    List<SensorData> sensorDataList, 
    SensorMetric metric,
  ) {
    try {
      return sensorDataList.map((data) {
        return MetricDataPoint(
          timestamp: data.parsedTimestamp,
          value: metric.getValue(data),
        );
      }).toList();
    } catch (e) {
      developer.log('Error converting sensor data to metric points: $e');
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Data point for charting
class MetricDataPoint {
  final DateTime timestamp;
  final double value;

  const MetricDataPoint({
    required this.timestamp,
    required this.value,
  });
}
