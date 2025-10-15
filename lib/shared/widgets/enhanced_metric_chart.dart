import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../features/dashboard/domain/models/metric_data.dart';
import 'dart:math' as math;

class EnhancedMetricChart extends StatefulWidget {
  final List<MetricData> data;
  final String title;
  final String? unit;
  final double minValue;
  final double maxValue;
  final Color? primaryColor;

  const EnhancedMetricChart({
    Key? key,
    required this.data,
    required this.title,
    this.unit,
    required this.minValue,
    required this.maxValue,
    this.primaryColor,
  }) : super(key: key);

  @override
  State<EnhancedMetricChart> createState() => _EnhancedMetricChartState();
}

class _EnhancedMetricChartState extends State<EnhancedMetricChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _showDataPoints = true;
  bool _showGridLines = true;
  bool _showArea = true;
  int _selectedPointIndex = -1;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color get _primaryColor => widget.primaryColor ?? const Color(0xFF00D2FF);

  List<MetricData> get _filteredData {
    // Filter out zero values
    return widget.data.where((data) => data.value != 0.0).toList();
  }

  double _calculateActualMaxValue() {
    final data = _filteredData;
    if (data.isEmpty) return 100;
    
    if (widget.maxValue == double.infinity) {
      double maxInData = data.fold(0.0, (max, item) => math.max(max, item.value));
      return maxInData * 1.1; // 10% padding
    }
    return widget.maxValue;
  }

  double _calculateActualMinValue() {
    final data = _filteredData;
    if (data.isEmpty) return 0;
    
    double minInData = data.fold(double.infinity, (min, item) => math.min(min, item.value));
    return math.min(widget.minValue, minInData * 0.9); // 10% padding below
  }

  @override
  Widget build(BuildContext context) {
    final data = _filteredData;
    if (data.isEmpty) {
      return _buildEmptyChart();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF1A1A1A),
            const Color(0xFF0A0A0A),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildChart(),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final stats = _calculateStats();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: _primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Current', stats['current']!, _primaryColor),
              _buildStatCard('Average', stats['average']!, Colors.blue),
              _buildStatCard('Peak', stats['peak']!, Colors.green),
              _buildStatCard('Low', stats['low']!, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.unit != null)
            Text(
              widget.unit!,
              style: TextStyle(
                color: color.withOpacity(0.6),
                fontSize: 8,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final data = _filteredData;
    final double effectiveMinValue = _calculateActualMinValue();
    final double effectiveMaxValue = _calculateActualMaxValue();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: _showGridLines,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              horizontalInterval: (effectiveMaxValue - effectiveMinValue) / 5,
              verticalInterval: data.length > 10 ? data.length / 8 : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: _primaryColor.withOpacity(0.1),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: _primaryColor.withOpacity(0.1),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            titlesData: _buildTitlesData(effectiveMinValue, effectiveMaxValue),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: _primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: effectiveMinValue,
            maxY: effectiveMaxValue,
            lineBarsData: [
              LineChartBarData(
                spots: _buildAnimatedSpots(effectiveMinValue),
                isCurved: true,
                curveSmoothness: 0.4,
                color: _primaryColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: _showDataPoints,
                  getDotPainter: (spot, percent, barData, index) {
                    final isSelected = index == _selectedPointIndex;
                    return FlDotCirclePainter(
                      radius: isSelected ? 6 : 4,
                      color: isSelected ? Colors.white : _primaryColor,
                      strokeWidth: isSelected ? 3 : 2,
                      strokeColor: _primaryColor,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: _showArea,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _primaryColor.withOpacity(0.3),
                      _primaryColor.withOpacity(0.1),
                      _primaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                if (touchResponse != null && touchResponse.lineBarSpots != null) {
                  setState(() {
                    _selectedPointIndex = touchResponse.lineBarSpots!.first.spotIndex;
                  });
                }
              },
              touchTooltipData: LineTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(12),
                tooltipMargin: 8,
                getTooltipColor: (touchedSpot) => _primaryColor.withOpacity(0.9),
                getTooltipItems: (touchedSpots) {
                  final data = _filteredData;
                  return touchedSpots.map((spot) {
                    if (spot.x >= 0 && spot.x < data.length) {
                      final item = data[spot.x.toInt()];
                      return LineTooltipItem(
                        '${item.value.toStringAsFixed(2)} ${widget.unit ?? ''}\n${_formatDateTime(item.timestamp)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                      color: _primaryColor.withOpacity(0.8),
                      strokeWidth: 2,
                      dashArray: [3, 3],
                    ),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 8,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: _primaryColor,
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _buildAnimatedSpots(double minValue) {
    final data = _filteredData;
    return List.generate(data.length, (index) {
      final actualValue = data[index].value;
      final animatedValue = minValue + (actualValue - minValue) * _animation.value;
      return FlSpot(index.toDouble(), animatedValue);
    });
  }

  FlTitlesData _buildTitlesData(double minValue, double maxValue) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 35,
          interval: _calculateTimeInterval(),
          getTitlesWidget: (value, meta) {
            final data = _filteredData;
            if (value < 0 || value >= data.length) return const SizedBox();
            final date = data[value.toInt()].timestamp;
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: _primaryColor.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: (maxValue - minValue) / 5,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: _primaryColor.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _primaryColor.withOpacity(0.05),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: _primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggleButton(
            'Points',
            Icons.scatter_plot,
            _showDataPoints,
            () => setState(() => _showDataPoints = !_showDataPoints),
          ),
          _buildToggleButton(
            'Grid',
            Icons.grid_on,
            _showGridLines,
            () => setState(() => _showGridLines = !_showGridLines),
          ),
          _buildToggleButton(
            'Area',
            Icons.area_chart,
            _showArea,
            () => setState(() => _showArea = !_showArea),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _primaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _primaryColor : _primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? _primaryColor : _primaryColor.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? _primaryColor : _primaryColor.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    Icons.analytics_outlined,
                    color: _primaryColor,
                    size: 64,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                color: _primaryColor.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for sensor data...',
              style: TextStyle(
                color: _primaryColor.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateStats() {
    final data = _filteredData;
    if (data.isEmpty) {
      return {
        'current': 0.0,
        'average': 0.0,
        'peak': 0.0,
        'low': 0.0,
      };
    }

    final values = data.map((e) => e.value).toList();
    return {
      'current': values.last,
      'average': values.reduce((a, b) => a + b) / values.length,
      'peak': values.reduce(math.max),
      'low': values.reduce(math.min),
    };
  }

  double _calculateTimeInterval() {
    final data = _filteredData;
    if (data.length <= 6) return 1;
    return (data.length / 6).ceil().toDouble();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}';
  }
}
