import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/widgets/metric_chart.dart';
import '../../../../services/sensor_api_service.dart';
import '../../../../models/sensor_data.dart';
import '../../domain/models/metric_data.dart';
import 'dart:developer' as developer;

class MetricDetailPage extends StatefulWidget {
  final SensorMetric metric;
  final double currentValue;

  const MetricDetailPage({
    super.key,
    required this.metric,
    required this.currentValue,
  });

  @override
  State<MetricDetailPage> createState() => _MetricDetailPageState();
}

class _MetricDetailPageState extends State<MetricDetailPage> {
  final SensorApiService _apiService = SensorApiService();
  String _selectedTimeRange = '24h';
  int _selectedHours = 24;
  late Stream<List<SensorData>> _historicalDataStream;

  @override
  void initState() {
    super.initState();
    developer.log('MetricDetailPage initialized for ${widget.metric.displayName}');
    _historicalDataStream = _apiService.getHistoricalDataStream(hours: _selectedHours);
  }

  void _onTimeRangeChanged(String timeRange) {
    try {
      setState(() {
        _selectedTimeRange = timeRange;
        switch (timeRange) {
          case '1h':
            _selectedHours = 1;
            break;
          case '6h':
            _selectedHours = 6;
            break;
          case '12h':
            _selectedHours = 12;
            break;
          case '24h':
            _selectedHours = 24;
            break;
          case '7d':
            _selectedHours = 168; // 7 * 24
            break;
          default:
            _selectedHours = 24;
        }
        // Update the stream with new hours
        _historicalDataStream = _apiService.getHistoricalDataStream(hours: _selectedHours);
      });
    } catch (error) {
      developer.log('Error changing time range: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            widget.metric.displayName,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              try {
                Navigator.of(context).pop();
              } catch (error) {
                developer.log('Error navigating back: $error');
              }
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            
            if (isMobile) {
              return Container(
                color: const Color(0xFF0A0A0A),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top Box - Metric Name
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Hero(
                          tag: 'metric-${widget.metric.key}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.metric.displayName,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.currentValue.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Color(0xFF4169E1),
                                          fontSize: 72,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              color: Color(0xFF4169E1),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        widget.metric.unit,
                                        style: TextStyle(
                                          color: Colors.grey.withOpacity(0.7),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Main Chart
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: StreamBuilder<List<SensorData>>(
                            stream: _historicalDataStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return _buildErrorWidget(snapshot.error.toString());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return _buildLoadingWidget();
                              }

                              final metricDataPoints = _apiService.getMetricDataPoints(
                                snapshot.data!,
                                widget.metric,
                              );

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: MetricChart(
                                  data: metricDataPoints.map((point) => MetricData(
                                    timestamp: point.timestamp,
                                    value: point.value,
                                    metricType: widget.metric.key,
                                    unit: widget.metric.unit,
                                  )).toList(),
                                  title: widget.metric.displayName,
                                  minValue: 0,
                                  maxValue: double.infinity,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Desktop layout
            return Container(
              color: const Color(0xFF0A0A0A),
              child: Row(
                children: [
                  // Left Column - Stacked Boxes
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Top Box - Metric Name
                          Hero(
                            tag: 'metric-${widget.metric.key}',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      widget.metric.displayName,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.currentValue.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Color(0xFF4169E1),
                                            fontSize: 72,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 2,
                                            shadows: [
                                              Shadow(
                                                color: Color(0xFF4169E1),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          widget.metric.unit,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.7),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mini Chart Box
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: StreamBuilder<List<SensorData>>(
                                stream: _apiService.getHistoricalDataStream(hours: 1),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Loading mini chart...',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    );
                                  }

                                  final data = snapshot.data!;
                                  final currentValue = widget.metric.getValue(data.last);
                                  final previousValue = data.length > 1 
                                      ? widget.metric.getValue(data[data.length - 2]) 
                                      : currentValue;
                                  final change = currentValue - previousValue;
                                  final changePercent = previousValue != 0 ? (change / previousValue) * 100 : 0;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Last Hour',
                                                style: TextStyle(
                                                  color: Colors.grey.withOpacity(0.7),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    change >= 0 ? Icons.trending_up : Icons.trending_down,
                                                    color: change >= 0 ? Colors.green : Colors.red,
                                                    size: 12,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${changePercent.abs().toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                      color: change >= 0 ? Colors.green : Colors.red,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4169E1).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Live',
                                              style: TextStyle(
                                                color: Color(0xFF4169E1),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Mini Chart Area',
                                            style: TextStyle(
                                              color: Colors.grey.withOpacity(0.5),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Right Column - Main Chart
                  Flexible(
                    flex: 7,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: StreamBuilder<List<SensorData>>(
                        stream: _historicalDataStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _buildErrorWidget(snapshot.error.toString());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildLoadingWidget();
                          }

                          final metricDataPoints = _apiService.getMetricDataPoints(
                            snapshot.data!,
                            widget.metric,
                          );

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: MetricChart(
                              data: metricDataPoints.map((point) => MetricData(
                                timestamp: point.timestamp,
                                value: point.value,
                                metricType: widget.metric.key,
                                unit: widget.metric.unit,
                              )).toList(),
                              title: widget.metric.displayName,
                              minValue: 0,
                              maxValue: double.infinity,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } catch (error) {
      developer.log('Error building MetricDetailPage: $error');
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error loading metric details',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading historical data',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: const Color(0xFF1A1A1A),
            highlightColor: const Color(0xFF2A2A2A),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading chart data...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
