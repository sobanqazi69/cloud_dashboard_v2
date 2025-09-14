import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
                          tag: 'metric-${widget.metricType}',
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
                                    _firestoreService.getDisplayNameForMetricType(widget.metricType),
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
                                        _firestoreService.getUnitForMetricType(widget.metricType),
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

                      // Mini Graph Box
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16),
                      //   child: Container(
                      //     height: 200,
                      //     width: double.infinity,
                      //     padding: const EdgeInsets.all(24),
                      //     decoration: BoxDecoration(
                      //       color: const Color(0xFF1A1A1A),
                      //       borderRadius: BorderRadius.circular(16),
                      //       border: Border.all(
                      //         color: Colors.grey.withOpacity(0.1),
                      //       ),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.black.withOpacity(0.2),
                      //           blurRadius: 10,
                      //           offset: const Offset(0, 4),
                      //         ),
                      //       ],
                      //     ),
                      //     child: _buildMiniGraph(),
                      //   ),
                      // ),

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
                          child: StreamBuilder<List<MetricData>>(
                            stream: _firestoreService.getMetricHistoryStream(
                              widget.metricType,
                              hours: _selectedHours,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return _buildErrorWidget(snapshot.error.toString());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return _buildLoadingWidget();
                              }

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: MetricChart(
                                  data: snapshot.data!,
                                  title: _firestoreService.getDisplayNameForMetricType(widget.metricType),
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

            // Return existing desktop layout
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
                            tag: 'metric-${widget.metricType}',
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
                                      _firestoreService.getDisplayNameForMetricType(widget.metricType),
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
                                          _firestoreService.getUnitForMetricType(widget.metricType),
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
                          // Bottom Box - Current Value and Live Status
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Mini Graph with Live Status
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                const Color(0xFF4169E1).withOpacity(0.05),
                                                Colors.transparent,
                                                const Color(0xFF4169E1).withOpacity(0.02),
                                              ],
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Mini stats header
                                              StreamBuilder<List<MetricData>>(
                                                stream: _firestoreService.getMetricHistoryStream(
                                                  widget.metricType,
                                                  hours: 1,
                                                ),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                                    return const SizedBox();
                                                  }
                                                  
                                                  final data = snapshot.data!;
                                                  final currentValue = data.last.value;
                                                  final previousValue = data.length > 1 ? data[data.length - 2].value : currentValue;
                                                  final change = currentValue - previousValue;
                                                  final changePercent = previousValue != 0 ? (change / previousValue) * 100 : 0;
                                                  
                                                  return Row(
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
                                                        child: Text(
                                                          'Live',
                                                          style: const TextStyle(
                                                            color: Color(0xFF4169E1),
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 12),
                                              // Chart area
                                              Expanded(
                                                child: StreamBuilder<List<MetricData>>(
                                                  stream: _firestoreService.getMetricHistoryStream(
                                                    widget.metricType,
                                                    hours: 1,
                                                  ),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData) return const SizedBox();
                                                    return CustomPaint(
                                                      size: Size.infinite,
                                                      painter: ProfessionalMiniChartPainter(
                                                        dataPoints: snapshot.data!,
                                                        color: const Color(0xFF4169E1),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Live Status Bar
                                        Positioned(
                                          left: 16,
                                          right: 16,
                                          bottom: 8,
                                          child: Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1A1A1A).withOpacity(0.95),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: const Color(0xFF4169E1).withOpacity(0.2),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // Animated Live Dot
                                                TweenAnimationBuilder(
                                                  tween: Tween<double>(begin: 0.3, end: 1.0),
                                                  duration: const Duration(milliseconds: 1200),
                                                  builder: (context, double value, child) {
                                                    return Container(
                                                      width: 6,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: const Color(0xFF4169E1).withOpacity(value),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(0xFF4169E1).withOpacity(value * 0.6),
                                                            blurRadius: 8,
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  onEnd: () {
                                                    if (mounted) setState(() {});
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'REAL-TIME',
                                                  style: TextStyle(
                                                    color: Color(0xFF4169E1),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                      child: StreamBuilder<List<MetricData>>(
                        stream: _firestoreService.getMetricHistoryStream(
                          widget.metricType,
                          hours: _selectedHours,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _buildErrorWidget(snapshot.error.toString());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildLoadingWidget();
                          }

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: MetricChart(
                              data: snapshot.data!,
                              title: _firestoreService.getDisplayNameForMetricType(widget.metricType),
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

  Widget _buildLeftColumn() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Hero(
            tag: 'metric-${widget.metricType}',
            child: Material(
              type: MaterialType.transparency,
              child: _buildMetricBox(),
            ),
          ),
          const SizedBox(height: 16),
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
              child: _buildMiniGraph(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainChart() {
    return Container(
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
      child: StreamBuilder<List<MetricData>>(
        stream: _firestoreService.getMetricHistoryStream(
          widget.metricType,
          hours: _selectedHours,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildLoadingWidget();
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MetricChart(
              data: snapshot.data!,
              title: _firestoreService.getDisplayNameForMetricType(widget.metricType),
              minValue: 0,
              maxValue: double.infinity,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricBox() {
    return Container(
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
            _firestoreService.getDisplayNameForMetricType(widget.metricType),
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
                _firestoreService.getUnitForMetricType(widget.metricType),
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
    );
  }

  Widget _buildMiniGraph() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4169E1).withOpacity(0.05),
                      Colors.transparent,
                      const Color(0xFF4169E1).withOpacity(0.02),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMiniStatsHeader(),
                    const SizedBox(height: 12),
                    Expanded(child: _buildMiniChartArea()),
                  ],
                ),
              ),
              _buildLiveStatusBar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatsHeader() {
    return StreamBuilder<List<MetricData>>(
      stream: _firestoreService.getMetricHistoryStream(
        widget.metricType,
        hours: 1,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }
        
        final data = snapshot.data!;
        final currentValue = data.last.value;
        final previousValue = data.length > 1 ? data[data.length - 2].value : currentValue;
        final change = currentValue - previousValue;
        final changePercent = previousValue != 0 ? (change / previousValue) * 100 : 0;
        
        return Row(
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
        );
      },
    );
  }

  Widget _buildMiniChartArea() {
    return StreamBuilder<List<MetricData>>(
      stream: _firestoreService.getMetricHistoryStream(
        widget.metricType,
        hours: 1,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return CustomPaint(
          size: Size.infinite,
          painter: ProfessionalMiniChartPainter(
            dataPoints: snapshot.data!,
            color: const Color(0xFF4169E1),
          ),
        );
      },
    );
  }

  Widget _buildLiveStatusBar() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 8,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4169E1).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedLiveDot(),
            const SizedBox(width: 8),
            const Text(
              'REAL-TIME',
              style: TextStyle(
                color: Color(0xFF4169E1),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLiveDot() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      builder: (context, double value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4169E1).withOpacity(value),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4169E1).withOpacity(value * 0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for title
          Shimmer.fromColors(
            baseColor: const Color(0xFF1A1A1A),
            highlightColor: const Color(0xFF2A2A2A),
            child: Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                // Left column shimmer
                Flexible(
                  flex: 3,
                  child: Column(
                    children: [
                      // Top box shimmer
                      Container(
                        width: double.infinity,
                        height: 200,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Shimmer.fromColors(
                          baseColor: const Color(0xFF1A1A1A),
                          highlightColor: const Color(0xFF2A2A2A),
                          child: Column(
                            children: [
                              Container(
                                width: 150,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: 120,
                                height: 72,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 80,
                                height: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bottom box shimmer
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Shimmer.fromColors(
                            baseColor: const Color(0xFF1A1A1A),
                            highlightColor: const Color(0xFF2A2A2A),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right column shimmer - Main chart
                Flexible(
                  flex: 7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Shimmer.fromColors(
                      baseColor: const Color(0xFF1A1A1A),
                      highlightColor: const Color(0xFF2A2A2A),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 120,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                const Spacer(),
                                Container(
                                  width: 80,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfessionalMiniChartPainter extends CustomPainter {
  final List<MetricData> dataPoints;
  final Color color;

  ProfessionalMiniChartPainter({
    required this.dataPoints,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Create paints
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.1),
          color.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Calculate min and max values with padding
    double minValue = dataPoints.first.value;
    double maxValue = dataPoints.first.value;
    for (var point in dataPoints) {
      if (point.value < minValue) minValue = point.value;
      if (point.value > maxValue) maxValue = point.value;
    }
    
    final valueRange = maxValue - minValue;
    final padding = valueRange * 0.1; // 10% padding
    minValue -= padding;
    maxValue += padding;
    final adjustedRange = maxValue - minValue;

    // Generate smooth curve points
    final points = <Offset>[];
    final controlPoints = <Offset>[];
    
    for (var i = 0; i < dataPoints.length; i++) {
      final x = size.width * i / (dataPoints.length - 1);
      final normalizedY = adjustedRange == 0 ? 0.5 : (dataPoints[i].value - minValue) / adjustedRange;
      final y = size.height - (normalizedY * size.height * 0.8) - size.height * 0.1;
      points.add(Offset(x, y));
    }

    // Create smooth path using cubic bezier curves
    final path = Path();
    final fillPath = Path();
    
    if (points.isNotEmpty) {
      // Start the paths
      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(0, size.height);
      fillPath.lineTo(points.first.dx, points.first.dy);

      // Create smooth curves between points
      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        
        final controlPoint1 = Offset(
          current.dx + (next.dx - current.dx) * 0.3,
          current.dy,
        );
        final controlPoint2 = Offset(
          next.dx - (next.dx - current.dx) * 0.3,
          next.dy,
        );

        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          next.dx, next.dy,
        );
        
        fillPath.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          next.dx, next.dy,
        );
      }

      // Close fill path
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();

      // Draw gradient fill
      canvas.drawPath(fillPath, gradientPaint);

      // Draw the smooth line
      canvas.drawPath(path, linePaint);

      // Draw data points with glow effect
      for (int i = 0; i < points.length; i++) {
        final point = points[i];
        
        // Draw glow effect for every few points
        if (i % 3 == 0) {
          canvas.drawCircle(point, 6, glowPaint);
          canvas.drawCircle(point, 3, dotPaint);
        }
      }

      // Highlight the latest point
      final latestPoint = points.last;
      canvas.drawCircle(latestPoint, 8, glowPaint);
      canvas.drawCircle(latestPoint, 4, dotPaint);
      canvas.drawCircle(latestPoint, 2, Paint()..color = Colors.white);

      // Draw grid lines (subtle)
      final gridPaint = Paint()
        ..color = Colors.grey.withOpacity(0.1)
        ..strokeWidth = 0.5;

      for (int i = 1; i < 4; i++) {
        final y = size.height * i / 4;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          gridPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 