import 'package:flutter/material.dart';
import '../../../../shared/widgets/metric_gauge.dart';
import '../../data/services/realtime_database_service.dart';
import 'dart:developer' as developer;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  @override
  void initState() {
    super.initState();
    developer.log('DashboardPage initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _databaseService.getMetricsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            developer.log('StreamBuilder error', error: snapshot.error);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading data',
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

          if (!snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Connecting to database...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          developer.log('Received data: $data');
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left column - 2 items
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 8, bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: MetricGauge(
                                  title: 'Oxygen Flow',
                                  value: data['oxygen_flow']?.toDouble() ?? 0.0,
                                  unit: 'm³/hr',
                                  maxValue: 50,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: MetricGauge(
                                  title: 'Oxygen Pressure',
                                  value: data['oxygen_pressure']?.toDouble() ?? 0.0,
                                  unit: 'Bar',
                                  maxValue: 10,
                                  color: const Color(0xFF60A5FA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right column - 3 items
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: MetricGauge(
                                  title: 'Oxygen Purity',
                                  value: data['oxygen_purity']?.toDouble() ?? 0.0,
                                  unit: '%',
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: MetricGauge(
                                  title: 'Running Hours',
                                  value: data['running_hours']?.toDouble() ?? 0.0,
                                  unit: 'hrs',
                                  maxValue: 100,
                                  color: const Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: MetricGauge(
                                  title: 'Temperature',
                                  value: data['temp_1']?.toDouble() ?? 0.0,
                                  unit: '°C',
                                  maxValue: 100,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 