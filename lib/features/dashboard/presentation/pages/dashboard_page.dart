import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/widgets/metric_gauge.dart';
import '../../data/services/realtime_database_service.dart';
import 'metric_detail_page.dart';
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

  void _navigateToMetricDetail(String metricType, double currentValue) {
    try {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MetricDetailPage(
            metricType: metricType,
            currentValue: currentValue,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.3, 1.0),
            ));

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (error) {
      developer.log('Error navigating to metric detail: $error');
    }
  }

  Widget _buildShimmerGauge() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1A1A),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _databaseService.getMetricsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            developer.log('Error in StreamBuilder: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }

          final data = snapshot.data ?? {};
          
          return Container(
            color: const Color(0xFF0A0A0A),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
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
                              child: !snapshot.hasData
                                  ? _buildShimmerGauge()
                                  : Hero(
                                      tag: 'metric-oxygen_flow',
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: GestureDetector(
                                          onTap: () => _navigateToMetricDetail(
                                            'oxygen_flow',
                                            data['oxygen_flow']?.toDouble() ?? 0.0
                                          ),
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
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: !snapshot.hasData
                                  ? _buildShimmerGauge()
                                  : Hero(
                                      tag: 'metric-oxygen_pressure',
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: GestureDetector(
                                          onTap: () => _navigateToMetricDetail(
                                            'oxygen_pressure',
                                            data['oxygen_pressure']?.toDouble() ?? 0.0
                                          ),
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
                              child: !snapshot.hasData
                                  ? _buildShimmerGauge()
                                  : Hero(
                                      tag: 'metric-oxygen_purity',
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: GestureDetector(
                                          onTap: () => _navigateToMetricDetail(
                                            'oxygen_purity',
                                            data['oxygen_purity']?.toDouble() ?? 0.0
                                          ),
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
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: !snapshot.hasData
                                  ? _buildShimmerGauge()
                                  : Hero(
                                      tag: 'metric-running_hours',
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: GestureDetector(
                                          onTap: () => _navigateToMetricDetail(
                                            'running_hours',
                                            data['running_hours']?.toDouble() ?? 0.0
                                          ),
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
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: !snapshot.hasData
                                  ? _buildShimmerGauge()
                                  : Hero(
                                      tag: 'metric-temp_1',
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: GestureDetector(
                                          onTap: () => _navigateToMetricDetail(
                                            'temp_1',
                                            data['temp_1']?.toDouble() ?? 0.0
                                          ),
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
                                              color: const Color(0xFF1D4ED8),
                                            ),
                                          ),
                                        ),
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