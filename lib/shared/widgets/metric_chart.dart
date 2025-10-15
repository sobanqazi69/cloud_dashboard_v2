import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../features/dashboard/domain/models/metric_data.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;

enum ChartTheme { cyberpunk, neon, ocean, sunset, forest, purple }
enum TimeRange { hour, day, week, month, custom }

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

class _MetricChartState extends State<MetricChart> with TickerProviderStateMixin {
  ChartTheme _selectedTheme = ChartTheme.ocean;
  TimeRange _selectedTimeRange = TimeRange.day;
  DateTimeRange? _customDateRange;
  bool _showDataPoints = false;
  bool _showGridLines = true;
  bool _showTooltips = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _timeRangeSliderValue = 24;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<MetricData> get _filteredData {
    // First filter out zero values
    final nonZeroData = widget.data.where((data) => data.value != 0.0).toList();
    
    if (_customDateRange != null) {
      return nonZeroData.where((data) =>
          data.timestamp.isAfter(_customDateRange!.start) &&
          data.timestamp.isBefore(_customDateRange!.end)).toList();
    }

    // Filter based on slider value
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(hours: _timeRangeSliderValue.toInt()));
    return nonZeroData.where((data) => data.timestamp.isAfter(cutoff)).toList();
  }

  double _calculateActualMaxValue() {
    final data = _filteredData;
    if (data.isEmpty) return 100;
    
    if (widget.maxValue == double.infinity) {
      double maxInData = data.fold(0.0, (max, item) => math.max(max, item.value));
      return maxInData * 1.2;
    }
    return widget.maxValue;
  }



  Color _getThemeColor() {
    switch (_selectedTheme) {
      case ChartTheme.cyberpunk:
        return const Color(0xFF00FFFF);
      case ChartTheme.neon:
        return const Color(0xFFFF0080);
      case ChartTheme.ocean:
        return const Color(0xFF0080FF);
      case ChartTheme.sunset:
        return const Color(0xFFFF8000);
      case ChartTheme.forest:
        return const Color(0xFF00FF80);
      case ChartTheme.purple:
        return const Color(0xFF8000FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildControlPanel(),
          ),
          Expanded(child: _buildChart()),
          _buildTimeRangeSlider(),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .2,
        child: Row(
          children: [
            Expanded(child: _buildDateRangeSelector()),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getThemeColor().withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, color: _getThemeColor(), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _showDateRangePicker(),
              child: Text(
                _customDateRange != null
                    ? '${_formatDate(_customDateRange!.start)} - ${_formatDate(_customDateRange!.end)}'
                    : 'Select Date Range',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          if (_customDateRange != null)
            GestureDetector(
              onTap: () => setState(() => _customDateRange = null),
              child: Icon(Icons.clear, color: Colors.grey, size: 18),
            ),
        ],
      ),
    );
  }

 
  Widget _buildStatItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.withOpacity(0.8),
            fontSize: 12,
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
      ],
    );
  }

  Widget _buildChart() {
    final data = _filteredData;
    if (data.isEmpty) {
      return _buildEmptyChart();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: _buildLineChart(data),
        );
      },
    );
  }

  Widget _buildLineChart(List<MetricData> data) {
    final double effectiveMinValue = widget.minValue;
    final double effectiveMaxValue = _calculateActualMaxValue();
    final double valueInterval = _calculateValueInterval(effectiveMaxValue - effectiveMinValue);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: _showGridLines,
          drawVerticalLine: true,
          horizontalInterval: valueInterval,
          verticalInterval: math.max(1, data.length / 6),
          getDrawingHorizontalLine: (value) => FlLine(
            color: _getThemeColor().withOpacity(0.1),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: _getThemeColor().withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: _buildTitlesData(data, valueInterval),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: effectiveMinValue,
        maxY: effectiveMaxValue,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (index) {
              final animatedValue = effectiveMinValue + 
                  (data[index].value - effectiveMinValue) * _animation.value;
              return FlSpot(index.toDouble(), animatedValue);
            }),
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: _getChartGradient(),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: _showDataPoints,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: _getThemeColor(),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: false,
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: _showTooltips,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipBorder: BorderSide(color: _getThemeColor()),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                if (spot.x >= 0 && spot.x < data.length) {
                  final item = data[spot.x.toInt()];
                  return LineTooltipItem(
                    '${item.value.toStringAsFixed(1)} ${widget.unit ?? ''}\n${_formatDateTime(item.timestamp)}',
                    TextStyle(color: _getThemeColor(), fontWeight: FontWeight.bold),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<MetricData> data, double valueInterval) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: _calculateTimeInterval(data.length),
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= data.length) return const Text('');
            final date = data[value.toInt()].timestamp;
            return Text(
              '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: _getThemeColor().withOpacity(0.6), fontSize: 12),
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
              style: TextStyle(color: _getThemeColor().withOpacity(0.6), fontSize: 12),
            );
          },
        ),
      ),
    );
  }

  LinearGradient _getChartGradient() {
    final color = _getThemeColor();
    return LinearGradient(
      colors: [color, color.withOpacity(0.5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

 

  void _showDateRangePicker() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CustomDateRangePicker(
          themeColor: _getThemeColor(),
          initialDateRange: _customDateRange,
          onDateRangeSelected: (DateTimeRange? range) {
            setState(() {
              _customDateRange = range;
            });
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}';
  }

  double _calculateTimeInterval(int dataLength) {
    if (dataLength <= 10) return 1;
    return (dataLength / 10).ceil().toDouble();
  }

  double _calculateValueInterval(double range) {
    if (range > 100) {
      if (range <= 200) return 20;
      if (range <= 500) return 50;
      if (range <= 1000) return 100;
      if (range <= 2000) return 200;
      if (range <= 5000) return 500;
      return (range / 10).ceil().toDouble();
    }
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    if (range <= 50) return 10;
    return 20;
  }

  Widget _buildEmptyChart() {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, color: _getThemeColor(), size: 64),
            const SizedBox(height: 16),
            Text(
              'No data available for selected range',
              style: TextStyle(color: _getThemeColor().withOpacity(0.7), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time Range: ${_timeRangeSliderValue.toInt()}h',
                style: TextStyle(
                  color: _getThemeColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.zoom_out, color: _getThemeColor().withOpacity(0.7), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Zoom',
                    style: TextStyle(
                      color: _getThemeColor().withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _getThemeColor(),
              inactiveTrackColor: _getThemeColor().withOpacity(0.2),
              thumbColor: _getThemeColor(),
              overlayColor: _getThemeColor().withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _timeRangeSliderValue,
              min: 1,
              max: 24,
              label: '${_timeRangeSliderValue.toInt()}h',
              onChanged: (value) {
                setState(() {
                  _timeRangeSliderValue = value;
                  _customDateRange = null; // Clear custom date range when using slider
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDateRangePicker extends StatefulWidget {
  final Color themeColor;
  final DateTimeRange? initialDateRange;
  final Function(DateTimeRange?) onDateRangeSelected;

  const _CustomDateRangePicker({
    required this.themeColor,
    required this.initialDateRange,
    required this.onDateRangeSelected,
  });

  @override
  State<_CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<_CustomDateRangePicker> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSelectingStart = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialDateRange != null) {
      _startDate = widget.initialDateRange!.start;
      _endDate = widget.initialDateRange!.end;
      _focusedMonth = _startDate!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.themeColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMonthNavigation(),
            const SizedBox(height: 16),
            _buildCalendar(),
            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Select Date Range',
          style: TextStyle(
            color: widget.themeColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDateButton(true)),
            const SizedBox(width: 12),
            Text('TO', style: TextStyle(color: Colors.grey.withOpacity(0.7))),
            const SizedBox(width: 12),
            Expanded(child: _buildDateButton(false)),
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton(bool isStart) {
    final date = isStart ? _startDate : _endDate;
    final isSelected = isStart ? _isSelectingStart : !_isSelectingStart;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelectingStart = isStart;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? widget.themeColor.withOpacity(0.2)
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? widget.themeColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              isStart ? 'FROM' : 'TO',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? '${date.day}/${date.month}/${date.year}' : 'Select',
              style: TextStyle(
                color: date != null ? Colors.white : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
          icon: Icon(Icons.chevron_left, color: widget.themeColor),
        ),
        Text(
          '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
          icon: Icon(Icons.chevron_right, color: widget.themeColor),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Week days header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Text(
                      day,
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Calendar grid
          ..._buildCalendarWeeks(),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarWeeks() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    
    final weeks = <Widget>[];
    var currentDate = firstDayOfMonth.subtract(Duration(days: firstDayWeekday));
    
    while (currentDate.isBefore(lastDayOfMonth) || 
           currentDate.month == lastDayOfMonth.month) {
      final week = <Widget>[];
      
      for (int i = 0; i < 7; i++) {
        week.add(_buildDayButton(currentDate));
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week,
          ),
        ),
      );
      
      if (currentDate.month != _focusedMonth.month && 
          currentDate.isAfter(lastDayOfMonth)) {
        break;
      }
    }
    
    return weeks;
  }

  Widget _buildDayButton(DateTime date) {
    final isCurrentMonth = date.month == _focusedMonth.month;
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = (_startDate != null && _isSameDay(date, _startDate!)) ||
                       (_endDate != null && _isSameDay(date, _endDate!));
    final isInRange = _isDateInRange(date);
    
    return GestureDetector(
      onTap: isCurrentMonth ? () => _selectDate(date) : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? widget.themeColor
              : isInRange
                  ? widget.themeColor.withOpacity(0.2)
                  : isToday
                      ? widget.themeColor.withOpacity(0.1)
                      : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isToday && !isSelected
              ? Border.all(color: widget.themeColor, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: isSelected
                  ? Colors.black
                  : isCurrentMonth
                      ? Colors.white
                      : Colors.grey.withOpacity(0.4),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _startDate = null;
              _endDate = null;
            });
          },
          child: Text(
            'Clear',
            style: TextStyle(color: Colors.grey.withOpacity(0.8)),
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.withOpacity(0.8)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _startDate != null && _endDate != null
                  ? () {
                      widget.onDateRangeSelected(
                        DateTimeRange(start: _startDate!, end: _endDate!),
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (_isSelectingStart) {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
        _isSelectingStart = false;
      } else {
        if (_startDate != null && date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
        _isSelectingStart = true;
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!) && date.isBefore(_endDate!);
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
} 