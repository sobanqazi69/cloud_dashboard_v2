import 'package:flutter/material.dart';
import '../../../../shared/widgets/metric_gauge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with three sections
            
            // Two columns layout
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
                            child: const MetricGauge(
                              title: 'Oxygen Flow',
                              value: 25.20,
                              unit: 'm³/hr',
                              maxValue: 50,
                              color: Color(0xFF3B82F6),
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
                            child: const MetricGauge(
                              title: 'Oxygen Pressure',
                              value: 3.87,
                              unit: 'Bar',
                              maxValue: 10,
                              color: Color(0xFF60A5FA),
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
                            child: const MetricGauge(
                              title: 'Oxygen Purity',
                              value: 89.61,
                              unit: '%',
                              color: Color(0xFF2563EB),
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
                            child: const MetricGauge(
                              title: 'Running Hours',
                              value: 62.00,
                              unit: 'hrs',
                              maxValue: 100,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: const MetricGauge(
                              title: 'Temperature',
                              value: 45.8,
                              unit: '°C',
                              maxValue: 100,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom info bar
            
          ],
        ),
      ),
    );
  }
} 