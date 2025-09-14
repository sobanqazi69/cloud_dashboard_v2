import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/widgets/metric_gauge.dart';
import '../../../../services/sensor_api_service.dart';
import '../../../../models/sensor_data.dart';
import 'metric_detail_page.dart';
import 'dart:developer' as developer;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SensorApiService _apiService = SensorApiService();
  late Stream<SensorData?> _sensorDataStream;

  @override
  void initState() {
    super.initState();
    developer.log('DashboardPage initialized');
    _sensorDataStream = _apiService.getLatestSensorDataStream();
  }

  void _navigateToMetricDetail(SensorMetric metric, double currentValue) {
    try {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MetricDetailPage(
            metric: metric,
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
      body: StreamBuilder<SensorData?>(
        stream: _sensorDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            developer.log('Error in StreamBuilder: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }

          final sensorData = snapshot.data;
          
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
                  child: _buildMetricsGrid(sensorData, !snapshot.hasData),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsGrid(SensorData? sensorData, bool isLoading) {
    // Define all metrics to display
    final metrics = [
      SensorMetric.oxygen,
      SensorMetric.oxyFlow,
      SensorMetric.oxyPressure,
      SensorMetric.compLoad,
      SensorMetric.compRunningHour,
      SensorMetric.airiTemp,
      SensorMetric.airoTemp,
      SensorMetric.airOutletp,
      SensorMetric.drypdpTemp,
      SensorMetric.boostoTemp,
      SensorMetric.boosterHour,
      SensorMetric.compOnStatus,
      SensorMetric.boosterStatus,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine grid layout based on screen size
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.0;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
          childAspectRatio = 1.1;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4;
          childAspectRatio = 1.2;
        } else {
          crossAxisCount = 5;
          childAspectRatio = 1.3;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            
            if (isLoading || sensorData == null) {
              return _buildShimmerGauge();
            }

            final value = metric.getValue(sensorData);
            final maxValue = _getMaxValueForMetric(metric);
            final color = _getColorForMetric(metric);

            return Hero(
              tag: 'metric-${metric.key}',
              child: Material(
                type: MaterialType.transparency,
                child: GestureDetector(
                  onTap: () => _navigateToMetricDetail(metric, value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: MetricGauge(
                        title: metric.displayName,
                        value: value,
                        unit: metric.unit,
                        maxValue: maxValue,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _getMaxValueForMetric(SensorMetric metric) {
    switch (metric) {
      case SensorMetric.oxygen:
        return 100;
      case SensorMetric.oxyFlow:
        return 50;
      case SensorMetric.oxyPressure:
        return 10;
      case SensorMetric.compLoad:
        return 100;
      case SensorMetric.compRunningHour:
        return 1000;
      case SensorMetric.airiTemp:
      case SensorMetric.airoTemp:
      case SensorMetric.boostoTemp:
      case SensorMetric.drypdpTemp:
        return 100;
      case SensorMetric.airOutletp:
        return 15;
      case SensorMetric.boosterHour:
        return 1000;
      case SensorMetric.compOnStatus:
      case SensorMetric.boosterStatus:
        return 1;
    }
  }

  Color _getColorForMetric(SensorMetric metric) {
    switch (metric) {
      case SensorMetric.oxygen:
        return const Color(0xFF10B981); // Green for oxygen purity
      case SensorMetric.oxyFlow:
        return const Color(0xFF3B82F6); // Blue for flow
      case SensorMetric.oxyPressure:
        return const Color(0xFF6366F1); // Indigo for pressure
      case SensorMetric.compLoad:
        return const Color(0xFFF59E0B); // Amber for load
      case SensorMetric.compRunningHour:
        return const Color(0xFF8B5CF6); // Purple for hours
      case SensorMetric.airiTemp:
        return const Color(0xFFEF4444); // Red for inlet temp
      case SensorMetric.airoTemp:
        return const Color(0xFFEC4899); // Pink for outlet temp
      case SensorMetric.airOutletp:
        return const Color(0xFF06B6D4); // Cyan for air pressure
      case SensorMetric.drypdpTemp:
        return const Color(0xFF84CC16); // Lime for dryer temp
      case SensorMetric.boostoTemp:
        return const Color(0xFFF97316); // Orange for booster temp
      case SensorMetric.boosterHour:
        return const Color(0xFF64748B); // Slate for booster hours
      case SensorMetric.compOnStatus:
        return const Color(0xFF22C55E); // Green for compressor status
      case SensorMetric.boosterStatus:
        return const Color(0xFF0EA5E9); // Sky for booster status
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
} 