import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/widgets/metric_gauge.dart';
import '../../../../services/sensor_api_service.dart';
import '../../../../models/sensor_data.dart';
import 'metric_detail_page.dart';
import '../../../selection/presentation/pages/selection_page.dart';
import 'dart:developer' as developer;

class DashboardPage extends StatefulWidget {
  final String systemType; // 'RIC' or 'SCC'
  
  const DashboardPage({
    super.key,
    this.systemType = 'RIC',
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SensorApiService _apiService = SensorApiService();
  late Stream<SensorData?> _sensorDataStream;

  @override
  void initState() {
    super.initState();
    developer.log('DashboardPage initialized for ${widget.systemType}');
    _sensorDataStream = widget.systemType == 'SCC' 
        ? _apiService.getLatestSCCDataWithFallbackStream()
        : _apiService.getLatestSensorDataStream();
  }

  void _navigateToSelection() {
    try {
      developer.log('Navigating back to System Selection');
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const SelectionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
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
        ),
      );
    } catch (error) {
      developer.log('Error navigating to selection: $error');
    }
  }

  void _navigateToMetricDetail(SensorMetric metric, double currentValue) {
    try {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MetricDetailPage(
            metric: metric,
            currentValue: currentValue,
            systemType: widget.systemType,
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

  Widget _buildPlantStatusIndicator(SensorData? sensorData) {
    try {
      final isDeactivated = _apiService.isPlantDeactivated(sensorData);
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDeactivated ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDeactivated ? Colors.red : Colors.green,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isDeactivated ? Colors.red : Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isDeactivated ? 'Plant Deactivated' : 'Plant Active',
              style: TextStyle(
                color: isDeactivated ? Colors.red : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      developer.log('Error building plant status indicator: $e');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Status Unknown',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  List<SensorMetric> _getPrioritizedSCCMetrics(List<SensorMetric> allMetrics, SensorData sensorData) {
    try {
      // Get all metrics that have meaningful data (not null and not 0)
      final metricsWithData = allMetrics.where((metric) {
        final value = metric.getValue(sensorData);
        final hasData = _hasMetricData(metric, sensorData);
        // Show metric if it has data AND the value is not 0
        return hasData && value != 0.0;
      }).toList();

      developer.log('Found ${metricsWithData.length} metrics with meaningful data (not null and not 0)');
      developer.log('Metrics with data: ${metricsWithData.map((m) => m.key).join(', ')}');
      
      return metricsWithData;
    } catch (e) {
      developer.log('Error prioritizing SCC metrics: $e');
      return allMetrics;
    }
  }

  bool _hasMetricData(SensorMetric metric, SensorData sensorData) {
    try {
      switch (metric) {
        case SensorMetric.pressure:
          return sensorData.pressure != null;
        case SensorMetric.trh:
          return sensorData.trh != null;
        case SensorMetric.trhOnLoad:
          return sensorData.trhOnLoad != null;
        case SensorMetric.i1:
          return sensorData.i1 != null;
        case SensorMetric.i2:
          return sensorData.i2 != null;
        case SensorMetric.i3:
          return sensorData.i3 != null;
        case SensorMetric.contMode:
          return sensorData.contMode != null;
        case SensorMetric.mh1:
          return sensorData.mh1 != null;
        case SensorMetric.mh2:
          return sensorData.mh2 != null;
        case SensorMetric.mh3:
          return sensorData.mh3 != null;
        case SensorMetric.mh4:
          return sensorData.mh4 != null;
        case SensorMetric.mh5:
          return sensorData.mh5 != null;
        case SensorMetric.volts:
          return sensorData.volts != null;
        case SensorMetric.power:
          return sensorData.power != null;
        case SensorMetric.oxyPurity:
          return sensorData.oxyPurity != null;
        case SensorMetric.bedaPress:
          return sensorData.bedaPress != null;
        case SensorMetric.bedbPress:
          return sensorData.bedbPress != null;
        case SensorMetric.recPress:
          return sensorData.recPress != null;
        default:
          return true;
      }
    } catch (e) {
      developer.log('Error checking metric data for ${metric.key}: $e');
      return false;
    }
  }

  Widget _buildNoDataGauge(SensorMetric metric, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metric.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.signal_cellular_off,
                  color: color.withOpacity(0.3),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No Data',
                  style: TextStyle(
                    color: color.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.unit,
                  style: TextStyle(
                    color: color.withOpacity(0.3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _navigateToSelection(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: 'Back to System Selection',
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(widget.systemType == 'SCC' ? 'Bahawalpur Site\nModbus' : 'RIC\nAnalog')} ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _buildPlantStatusIndicator(sensorData),
                  ],
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
    // Define all available metrics based on system type
    final allMetrics = widget.systemType == 'SCC' ? [
      SensorMetric.pressure,
      SensorMetric.trh,
      SensorMetric.trhOnLoad,
      SensorMetric.i1,
      SensorMetric.mh1,
      SensorMetric.volts,
      SensorMetric.power,
      SensorMetric.oxyPurity,
      SensorMetric.bedaPress,
      SensorMetric.bedbPress,
      SensorMetric.recPress,
    ] : [
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

    // For SCC system, prioritize metrics with data but still show some null metrics
    final metrics = widget.systemType == 'SCC' && sensorData != null
        ? _getPrioritizedSCCMetrics(allMetrics, sensorData)
        : allMetrics;

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
            final hasData = _hasMetricData(metric, sensorData);

            return Hero(
              tag: 'metric-${metric.key}',
              child: Material(
                type: MaterialType.transparency,
                child: GestureDetector(
                  onTap: hasData ? () => _navigateToMetricDetail(metric, value) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasData ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
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
                      child: hasData 
                          ? MetricGauge(
                              title: metric.displayName,
                              value: value,
                              unit: metric.unit,
                              maxValue: maxValue,
                              color: color,
                            )
                          : _buildNoDataGauge(metric, color),
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
      // RIC metrics
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
      
      // SCC metrics
      case SensorMetric.pressure:
        return 200;
      case SensorMetric.trh:
      case SensorMetric.trhOnLoad:
        return 30000;
      case SensorMetric.i1:
        return 1000;
      case SensorMetric.i2:
      case SensorMetric.i3:
        return 1000;
      case SensorMetric.contMode:
        return 5;
      case SensorMetric.mh1:
        return 2000;
      case SensorMetric.mh2:
      case SensorMetric.mh3:
      case SensorMetric.mh4:
      case SensorMetric.mh5:
        return 2000;
      case SensorMetric.volts:
        return 500;
      case SensorMetric.power:
        return 1000;
      
      // Additional merged SCC metrics
      case SensorMetric.oxyPurity:
        return 100;
      case SensorMetric.bedaPress:
      case SensorMetric.bedbPress:
      case SensorMetric.recPress:
        return 100;
    }
  }

  Color _getColorForMetric(SensorMetric metric) {
    switch (metric) {
      // RIC metrics
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
      
      // SCC metrics
      case SensorMetric.pressure:
        return const Color(0xFF8B5CF6); // Purple for pressure
      case SensorMetric.trh:
        return const Color(0xFF10B981); // Green for Total Running Hours
      case SensorMetric.trhOnLoad:
        return const Color(0xFF3B82F6); // Blue for Total Running Hours On Load
      case SensorMetric.i1:
        return const Color(0xFFEF4444); // Red for I1
      case SensorMetric.i2:
        return const Color(0xFFEC4899); // Pink for I2
      case SensorMetric.i3:
        return const Color(0xFFF97316); // Orange for I3
      case SensorMetric.contMode:
        return const Color(0xFF84CC16); // Lime for control mode
      case SensorMetric.mh1:
        return const Color(0xFF06B6D4); // Cyan for Maintenance Hours
      case SensorMetric.mh2:
        return const Color(0xFF64748B); // Slate for MH2
      case SensorMetric.mh3:
        return const Color(0xFF22C55E); // Green for MH3
      case SensorMetric.mh4:
        return const Color(0xFF0EA5E9); // Sky for MH4
      case SensorMetric.mh5:
        return const Color(0xFFF59E0B); // Amber for MH5
      case SensorMetric.volts:
        return const Color(0xFF6366F1); // Indigo for voltage
      case SensorMetric.power:
        return const Color(0xFFEF4444); // Red for power
      
      // Additional merged SCC metrics
      case SensorMetric.oxyPurity:
        return const Color(0xFF10B981); // Green for oxygen purity
      case SensorMetric.bedaPress:
        return const Color(0xFF3B82F6); // Blue for bed A pressure
      case SensorMetric.bedbPress:
        return const Color(0xFF8B5CF6); // Purple for bed B pressure
      case SensorMetric.recPress:
        return const Color(0xFFF59E0B); // Amber for recovery pressure
    }
  }

  @override
  void dispose() {
    try {
      developer.log('Disposing DashboardPage');
      // Don't dispose the service here as it might be used by other widgets
      // The service will be disposed when the app is closed
    } catch (e) {
      developer.log('Error disposing DashboardPage: $e');
    }
    super.dispose();
  }
} 