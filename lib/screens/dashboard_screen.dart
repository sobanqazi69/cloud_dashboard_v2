import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/oxygen_gauge.dart';
import '../widgets/oxygen_chart.dart';
import '../models/oxygen_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _timer;
  late List<OxygenDataPoint> _historicalData;
  late OxygenData _currentData;

  @override
  void initState() {
    super.initState();
    try {
      // Initialize with dummy data
      _historicalData = OxygenDataProvider.generateDummyData();
      _currentData = OxygenData(
        flow: _historicalData.last.flow,
        timestamp: _historicalData.last.timestamp,
      );

      // Update data every 30 seconds for more real-time feel
      _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _updateData();
      });
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateData() {
    try {
      setState(() {
        // Generate new flow value
        final newFlow = OxygenDataProvider.generateNextValue(_currentData.flow);
        final now = DateTime.now();

        // Update current data
        _currentData = OxygenData(
          flow: newFlow,
          timestamp: now,
        );

        // Add new data point and remove oldest one
        _historicalData.add(OxygenDataPoint(
          flow: newFlow,
          timestamp: now,
        ));
        _historicalData.removeAt(0);
      });
    } catch (e) {
      debugPrint('Error updating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cloud Dashboard',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Date picker functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isSmallScreen) {
                // Mobile layout - vertical arrangement
                return Column(
                  children: [
                    OxygenGauge(data: _currentData),
                    const SizedBox(height: 16),
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Center(
                        child: Text(
                          'No data',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: OxygenChart(
                         
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Desktop/tablet layout - horizontal arrangement
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          OxygenGauge(data: _currentData),
                          const SizedBox(height: 16),
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: const Center(
                              child: Text(
                                'No data',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: OxygenChart(
                       
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
} 