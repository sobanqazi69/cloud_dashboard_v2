import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../features/dashboard/domain/models/metric_data.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;

enum ChartType { line, area, bars }
enum ChartTheme { cyberpunk, neon, ocean, sunset, forest, purple }

class MetricChart extends StatefulWidget {
  final List<MetricData> data;
  final String title;
  final String? unit;
  final double minValue;
  final double maxValue;

  const MetricChart({
    Key? key,
    required this.data,
    required this.title,
    this.unit,
    required this.minValue,
    required this.maxValue,
  }) : super(key: key);

  @override
  State<MetricChart> createState() => _MetricChartState();
}

class _MetricChartState extends State<MetricChart> {
  double _calculateActualMaxValue() {
    if (widget.maxValue == double.infinity) {
      // Find the maximum value in the data
      double maxInData = widget.data.fold(0.0, (max, item) => math.max(max, item.value));
      // Add 20% padding to the top
      return maxInData * 1.2;
    }
    return widget.maxValue;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyChart();
    }

    // Calculate proper min/max values with padding
    final double effectiveMinValue = widget.minValue;
    final double effectiveMaxValue = _calculateActualMaxValue();
    final double valueInterval = _calculateValueInterval(effectiveMaxValue - effectiveMinValue);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: valueInterval,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _calculateTimeInterval(),
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= widget.data.length) return const Text('');
                  final date = widget.data[value.toInt()].timestamp;
                  return Text(
                    '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: valueInterval,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: widget.data.length.toDouble() - 1,
          minY: effectiveMinValue,
          maxY: effectiveMaxValue,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(widget.data.length, (index) {
                return FlSpot(index.toDouble(), widget.data[index].value);
              }),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2196F3),
                  Color(0xFF0D47A1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2196F3).withOpacity(0.3),
                    const Color(0xFF0D47A1).withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              tooltipBorder: BorderSide(color: Colors.blueGrey.shade700),
              tooltipMargin: 8,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  if (flSpot.x >= 0 && flSpot.x < widget.data.length) {
                    final data = widget.data[flSpot.x.toInt()];
                    return LineTooltipItem(
                      '${data.value.toStringAsFixed(1)} ${widget.unit ?? ''}\n${_formatDateTime(data.timestamp)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: Colors.white,
                    strokeWidth: 2,
                    dashArray: [3, 3],
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.blue,
                      );
                    },
                  ),
                );
              }).toList();
            },
            touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {},
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}';
  }

  double _calculateTimeInterval() {
    final dataLength = widget.data.length;
    if (dataLength <= 10) return 1;
    return (dataLength / 10).ceil().toDouble();
  }

  double _calculateValueInterval(double range) {
    // For Running Hours, use larger intervals
    if (range > 100) {
      if (range <= 200) return 20;
      if (range <= 500) return 50;
      if (range <= 1000) return 100;
      if (range <= 2000) return 200;
      if (range <= 5000) return 500;
      return (range / 10).ceil().toDouble();  // Dynamic intervals for very large ranges
    }
    // For smaller ranges
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    if (range <= 50) return 10;
    return 20;
  }

  Widget _buildEmptyChart() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 