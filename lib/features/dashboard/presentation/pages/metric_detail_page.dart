import 'package:flutter/material.dart';
import '../../../../shared/widgets/metric_chart.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/models/metric_data.dart';
import 'dart:developer' as developer;

class MetricDetailPage extends StatefulWidget {
  final String metricType;
  final double currentValue;

  const MetricDetailPage({
    super.key,
    required this.metricType,
    required this.currentValue,
  });

  @override
  State<MetricDetailPage> createState() => _MetricDetailPageState();
}

class _MetricDetailPageState extends State<MetricDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedTimeRange = '24h';
  int _selectedHours = 24;

  @override
  void initState() {
    super.initState();
    developer.log('MetricDetailPage initialized for ${widget.metricType}');
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
            _firestoreService.getDisplayNameForMetricType(widget.metricType),
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
        body: Column(
          children: [
            // Time Range Selector
            // Container(
            //   margin: const EdgeInsets.all(16),
            //   padding: const EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFF1A1A1A),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       _buildTimeRangeButton('1h'),
            //       _buildTimeRangeButton('6h'),
            //       _buildTimeRangeButton('12h'),
            //       _buildTimeRangeButton('24h'),
            //       _buildTimeRangeButton('7d'),
            //     ],
            //   ),
            // ),
            
            // Current Value Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Value',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                                                 '${widget.currentValue.toStringAsFixed(1)} ${_firestoreService.getUnitForMetricType(widget.metricType)}',
                        style: TextStyle(
                          color: _firestoreService.getColorForMetricType(widget.metricType),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.trending_up,
                    color: _firestoreService.getColorForMetricType(widget.metricType),
                    size: 32,
                  ),
                ],
              ),
            ),
            
            // Chart
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: StreamBuilder<List<MetricData>>(
                  stream: _firestoreService.getMetricHistoryStream(
                    widget.metricType,
                    hours: _selectedHours,
                  ),
                  builder: (context, snapshot) {
                    try {
                      if (snapshot.hasError) {
                        developer.log('StreamBuilder error', error: snapshot.error);
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                const Text(
                                  'Error loading historical data',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {});  // Retry by rebuilding the widget
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Loading historical data...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }

                      final data = snapshot.data!;
                      developer.log('Received ${data.length} data points for ${widget.metricType}');

                      return MetricChart(
                        data: data,
                        title: _firestoreService.getDisplayNameForMetricType(widget.metricType),
                        minValue: 0,
                        maxValue: double.infinity,  // Let the chart calculate its own max value
                      );
                    } catch (error) {
                      developer.log('Error building chart: $error');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            const Text(
                              'Error displaying chart',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      developer.log('Error building MetricDetailPage: $error');
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error loading page',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTimeRangeButton(String timeRange) {
    try {
      final bool isSelected = _selectedTimeRange == timeRange;
      return GestureDetector(
        onTap: () => _onTimeRangeChanged(timeRange),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? _firestoreService.getColorForMetricType(widget.metricType)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? _firestoreService.getColorForMetricType(widget.metricType)
                  : Colors.grey,
            ),
          ),
          child: Text(
            timeRange,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    } catch (error) {
      developer.log('Error building time range button: $error');
      return Container();
    }
  }
} 