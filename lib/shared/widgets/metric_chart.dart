import 'package:flutter/material.dart';
import '../../features/dashboard/domain/models/metric_data.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;

enum ChartType { line, area, bars }
enum ChartTheme { cyberpunk, neon, ocean, sunset, forest, purple }

class MetricChart extends StatefulWidget {
  final List<MetricData> data;
  final String title;
  final double minValue;
  final double maxValue;
  final Color lineColor;
  final Color areaColor;
  final String? unit;

  const MetricChart({
    super.key,
    required this.data,
    required this.title,
    required this.minValue,
    required this.maxValue,
    this.lineColor = const Color(0xFF00D4FF),
    this.areaColor = const Color(0x4000D4FF),
    this.unit,
  });

  @override
  State<MetricChart> createState() => _MetricChartState();
}

class _MetricChartState extends State<MetricChart> with TickerProviderStateMixin {
  Offset? _hoverPosition;
  MetricData? _hoveredData;
  bool _isHovering = false;
  
  // Chart options
  ChartType _chartType = ChartType.area;
  ChartTheme _chartTheme = ChartTheme.cyberpunk;
  bool _showGrid = true;
  bool _showDataPoints = true;
  bool _showStats = true;
  bool _showAnimations = true;
  double _lineWidth = 2.0;
  double _pointSize = 3.0;
  
  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  // Statistics
  double get _minStat => widget.data.isEmpty ? 0 : widget.data.map((e) => e.value).reduce(math.min);
  double get _maxStat => widget.data.isEmpty ? 0 : widget.data.map((e) => e.value).reduce(math.max);
  double get _avgStat => widget.data.isEmpty ? 0 : widget.data.map((e) => e.value).reduce((a, b) => a + b) / widget.data.length;
  double get _currentStat => widget.data.isEmpty ? 0 : widget.data.last.value;

  @override
  void initState() {
    super.initState();
    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );
      
      _pulseController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _slideAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      _pulseAnimation = Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ));
      
      _animationController.forward();
      _pulseController.repeat(reverse: true);
    } catch (error) {
      developer.log('Error initializing animations: $error');
    }
  }

  @override
  void dispose() {
    try {
      _animationController.dispose();
      _pulseController.dispose();
    } catch (error) {
      developer.log('Error disposing animations: $error');
    }
    super.dispose();
  }

  Map<String, Color> get _themeColors {
    try {
      switch (_chartTheme) {
        case ChartTheme.cyberpunk:
          return {
            'primary': Color(0xFF00FFFF),
            'secondary': Color(0xFFFF0080),
            'background': Color(0xFF0A0A0A),
            'grid': Color(0xFF1A1A2E),
          };
        case ChartTheme.neon:
          return {
            'primary': Color(0xFF39FF14),
            'secondary': Color(0xFFFF6EC7),
            'background': Color(0xFF000000),
            'grid': Color(0xFF0F3460),
          };
        case ChartTheme.ocean:
          return {
            'primary': Color(0xFF00D4AA),
            'secondary': Color(0xFF0047AB),
            'background': Color(0xFF0B1426),
            'grid': Color(0xFF1E3A5F),
          };
        case ChartTheme.sunset:
          return {
            'primary': Color(0xFFFF6B35),
            'secondary': Color(0xFFF7931E),
            'background': Color(0xFF2C1810),
            'grid': Color(0xFF4A2C17),
          };
        case ChartTheme.forest:
          return {
            'primary': Color(0xFF00FF7F),
            'secondary': Color(0xFF32CD32),
            'background': Color(0xFF0D1B0D),
            'grid': Color(0xFF1A331A),
          };
        case ChartTheme.purple:
          return {
            'primary': Color(0xFF8A2BE2),
            'secondary': Color(0xFFDA70D6),
            'background': Color(0xFF1A0D1A),
            'grid': Color(0xFF331A33),
          };
      }
          } catch (error) {
        developer.log('Error getting theme colors: $error');
        return {
          'primary': Colors.blue,
          'secondary': Colors.grey,
          'background': Color(0xFF0A0A0A),
          'grid': Color(0xFF1A1A2E),
        };
      }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (widget.data.isEmpty) {
        return _buildEmptyChart();
      }

      final currentValue = widget.data.isNotEmpty ? widget.data.last.value : 0.0;
      final displayValue = _isHovering && _hoveredData != null ? _hoveredData!.value : currentValue;
      final themeColors = _themeColors;

      return LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              color: themeColors['background'],
            ),
            child: Stack(
              children: [
                // Control Panel
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildControlPanel(themeColors),
                ),
                
                // Main Chart with interactions
                Positioned.fill(
                  top: 300,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                    child: MouseRegion(
                      onHover: (event) {
                        try {
                          setState(() {
                            _hoverPosition = event.localPosition;
                            _hoveredData = _findNearestDataPoint(event.localPosition);
                            _isHovering = true;
                          });
                        } catch (error) {
                          developer.log('Error handling hover: $error');
                        }
                      },
                      onExit: (event) {
                        try {
                          setState(() {
                            _hoverPosition = null;
                            _hoveredData = null;
                            _isHovering = false;
                          });
                        } catch (error) {
                          developer.log('Error handling hover exit: $error');
                        }
                      },
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          try {
                            setState(() {
                              _hoverPosition = details.localPosition;
                              _hoveredData = _findNearestDataPoint(details.localPosition);
                              _isHovering = true;
                            });
                          } catch (error) {
                            developer.log('Error handling pan update: $error');
                          }
                        },
                        onPanEnd: (details) {
                          try {
                            setState(() {
                              _hoverPosition = null;
                              _hoveredData = null;
                              _isHovering = false;
                            });
                          } catch (error) {
                            developer.log('Error handling pan end: $error');
                          }
                        },
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: AdvancedChartPainter(
                            data: widget.data,
                            minValue: widget.minValue,
                            maxValue: widget.maxValue,
                            themeColors: themeColors,
                            hoverPosition: _hoverPosition,
                            hoveredData: _hoveredData,
                            chartType: _chartType,
                            showGrid: _showGrid,
                            showDataPoints: _showDataPoints,
                            lineWidth: _lineWidth,
                            pointSize: _pointSize,
                            animationProgress: _showAnimations ? _slideAnimation.value : 1.0,
                            pulseAnimation: _showAnimations ? _pulseAnimation.value : 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Title and Current Value Display
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeColors['background']!.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: themeColors['primary']!.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${widget.title} ${displayValue.toStringAsFixed(2)} ${widget.unit ?? ''}',
                      style: TextStyle(
                        color: themeColors['primary'],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                // Hover tooltip
                if (_isHovering && _hoveredData != null && _hoverPosition != null)
                  Positioned(
                    left: math.min(_hoverPosition!.dx + 10, constraints.maxWidth - 150),
                    top: math.max(_hoverPosition!.dy - 80, 50),
                    child: _buildAdvancedTooltip(themeColors),
                  ),
              ],
            ),
          );
        },
      );
    } catch (error) {
      developer.log('Error building MetricChart: $error');
      return _buildErrorChart(error.toString());
    }
  }

  Widget _buildControlPanel(Map<String, Color> themeColors) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: themeColors['background']!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: themeColors['primary']!.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(Icons.show_chart, ChartType.line, 'Line'),
          const SizedBox(width: 4),
          _buildControlButton(Icons.area_chart, ChartType.area, 'Area'),
          const SizedBox(width: 4),
          _buildControlButton(Icons.bar_chart, ChartType.bars, 'Bars'),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, ChartType type, String tooltip) {
    try {
      final themeColors = _themeColors;
      final isSelected = _chartType == type;
      
      return Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () => setState(() => _chartType = type),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? themeColors['primary']!.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? themeColors['primary']! : themeColors['grid']!,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isSelected ? themeColors['primary'] : Colors.grey,
            ),
          ),
        ),
      );
    } catch (error) {
      developer.log('Error building control button: $error');
      return Container();
    }
  }

 

  Widget _buildStatRow(String label, double value, Color color) {
    try {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$label: ${value.toStringAsFixed(2)} ${widget.unit ?? ''}',
            style: const TextStyle(
              color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      developer.log('Error building stat row: $error');
      return Container();
    }
  }

  Widget _buildAdvancedTooltip(Map<String, Color> themeColors) {
    try {
      if (_hoveredData == null) return Container();
      
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeColors['background']!,
              themeColors['background']!.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: themeColors['primary']!, width: 1),
          boxShadow: [
            BoxShadow(
              color: themeColors['primary']!.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timeline,
                  color: themeColors['primary'],
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Data Point',
                  style: TextStyle(
                    color: themeColors['primary'],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '📊 ${_hoveredData!.value.toStringAsFixed(3)} ${widget.unit ?? ''}',
              style: TextStyle(
                color: themeColors['secondary'],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '⏰ ${_hoveredData!.timestamp.hour.toString().padLeft(2, '0')}:${_hoveredData!.timestamp.minute.toString().padLeft(2, '0')}:${_hoveredData!.timestamp.second.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
            Text(
              '📅 ${_hoveredData!.timestamp.day}/${_hoveredData!.timestamp.month}/${_hoveredData!.timestamp.year}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      developer.log('Error building advanced tooltip: $error');
      return Container();
    }
  }

  Color _getThemePreviewColor(ChartTheme theme) {
    try {
      switch (theme) {
        case ChartTheme.cyberpunk: return Color(0xFF00FFFF);
        case ChartTheme.neon: return Color(0xFF39FF14);
        case ChartTheme.ocean: return Color(0xFF00D4AA);
        case ChartTheme.sunset: return Color(0xFFFF6B35);
        case ChartTheme.forest: return Color(0xFF00FF7F);
        case ChartTheme.purple: return Color(0xFF8A2BE2);
      }
    } catch (error) {
      developer.log('Error getting theme preview color: $error');
      return Color(0xFF00FFFF);
    }
  }

  MetricData? _findNearestDataPoint(Offset position) {
    try {
      if (widget.data.isEmpty) return null;
      
      const padding = 50.0;
      final chartWidth = MediaQuery.of(context).size.width - (padding * 2);
      final chartLeft = padding;
      
      final relativeX = (position.dx - chartLeft) / chartWidth;
      if (relativeX < 0 || relativeX > 1) return null;
      
      final startTime = widget.data.first.timestamp.millisecondsSinceEpoch;
      final endTime = widget.data.last.timestamp.millisecondsSinceEpoch;
      final targetTime = startTime + ((endTime - startTime) * relativeX);
      
      MetricData? closest;
      double minDistance = double.infinity;
      
      for (final dataPoint in widget.data) {
        final distance = (dataPoint.timestamp.millisecondsSinceEpoch - targetTime).abs().toDouble();
        if (distance < minDistance) {
          minDistance = distance;
          closest = dataPoint;
        }
      }
      
      return closest;
    } catch (error) {
      developer.log('Error finding nearest data point: $error');
      return null;
    }
  }

  Widget _buildEmptyChart() {
    try {
      final themeColors = _themeColors;
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeColors['background']!,
              themeColors['background']!.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                color: themeColors['primary'],
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'No Data Available',
                style: TextStyle(
                  color: themeColors['primary'],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Historical data will appear here once collected',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      developer.log('Error building empty chart: $error');
      return Container(color: Colors.black);
    }
  }

  Widget _buildErrorChart(String error) {
    try {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Chart Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      developer.log('Error building error chart: $e');
      return Container(color: Colors.black);
    }
  }
}

class AdvancedChartPainter extends CustomPainter {
  final List<MetricData> data;
  final double minValue;
  final double maxValue;
  final Map<String, Color> themeColors;
  final Offset? hoverPosition;
  final MetricData? hoveredData;
  final ChartType chartType;
  final bool showGrid;
  final bool showDataPoints;
  final double lineWidth;
  final double pointSize;
  final double animationProgress;
  final double pulseAnimation;

  AdvancedChartPainter({
    required this.data,
    required this.minValue,
    required this.maxValue,
    required this.themeColors,
    this.hoverPosition,
    this.hoveredData,
    required this.chartType,
    required this.showGrid,
    required this.showDataPoints,
    required this.lineWidth,
    required this.pointSize,
    required this.animationProgress,
    required this.pulseAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (data.isEmpty) return;

      const padding = 20.0; // Reduced padding
      final chartRect = Rect.fromLTRB(
        padding,
        padding,
        size.width - padding,
        size.height - padding,
      );

      // Draw background
      final backgroundPaint = Paint()
        ..color = themeColors['background']!;
      canvas.drawRect(chartRect, backgroundPaint);

      // Draw grid if enabled
      if (showGrid) {
        _drawAdvancedGrid(canvas, chartRect);
      }

      // Calculate the visible range of values
      final visibleMin = minValue - ((maxValue - minValue) * 0.1); // Add 10% padding
      final visibleMax = maxValue + ((maxValue - minValue) * 0.1);

      switch (chartType) {
        case ChartType.line:
          _drawLineChart(canvas, chartRect, visibleMin, visibleMax);
          break;
        case ChartType.area:
          _drawAreaChart(canvas, chartRect, visibleMin, visibleMax);
          break;
        case ChartType.bars:
          _drawBarChart(canvas, chartRect, visibleMin, visibleMax);
          break;
      }

      if (showDataPoints) {
        _drawDataPoints(canvas, chartRect, visibleMin, visibleMax);
      }

      if (hoveredData != null) {
        _drawHoverIndicator(canvas, chartRect, visibleMin, visibleMax);
      }

    } catch (error) {
      developer.log('Error painting chart: $error');
    }
  }

  void _drawAdvancedGrid(Canvas canvas, Rect chartRect) {
    try {
      final gridPaint = Paint()
        ..color = themeColors['grid']!.withOpacity(0.3)
        ..strokeWidth = 0.5;

      final glowPaint = Paint()
        ..color = themeColors['primary']!.withOpacity(0.1)
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2);

      // Horizontal grid lines
      const gridCount = 5;
      for (int i = 0; i <= gridCount; i++) {
        final y = chartRect.bottom - (chartRect.height * i / gridCount);
        
        canvas.drawLine(
          Offset(chartRect.left, y),
          Offset(chartRect.right, y),
          gridPaint,
        );
        
        // Add glow effect to center line
        if (i == gridCount ~/ 2) {
          canvas.drawLine(
            Offset(chartRect.left, y),
            Offset(chartRect.right, y),
            glowPaint,
          );
        }
      }

      // Vertical grid lines
      const timeGridCount = 6;
      for (int i = 0; i <= timeGridCount; i++) {
        final x = chartRect.left + (chartRect.width * i / timeGridCount);
        
        canvas.drawLine(
          Offset(x, chartRect.top),
          Offset(x, chartRect.bottom),
          gridPaint,
        );
      }
    } catch (error) {
      developer.log('Error drawing advanced grid: $error');
    }
  }

  void _drawLineChart(Canvas canvas, Rect chartRect, double visibleMin, double visibleMax) {
    try {
      if (data.isEmpty) return;

      final paint = Paint()
        ..color = themeColors['primary']!
        ..strokeWidth = lineWidth * pulseAnimation
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final glowPaint = Paint()
        ..color = themeColors['primary']!.withOpacity(0.5)
        ..strokeWidth = lineWidth * 2 * pulseAnimation
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final path = _createPath(chartRect, visibleMin, visibleMax);
      
      // Draw glow effect
      canvas.drawPath(path, glowPaint);
      
      // Draw main line
      canvas.drawPath(path, paint);
    } catch (error) {
      developer.log('Error drawing line chart: $error');
    }
  }

  void _drawAreaChart(Canvas canvas, Rect chartRect, double visibleMin, double visibleMax) {
    try {
      if (data.isEmpty) return;

      // Create gradient for area
      final areaGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          themeColors['primary']!.withOpacity(0.6),
          themeColors['secondary']!.withOpacity(0.3),
          themeColors['primary']!.withOpacity(0.1),
        ],
      );

      final areaPaint = Paint()
        ..shader = areaGradient.createShader(chartRect)
        ..style = PaintingStyle.fill;

      final linePaint = Paint()
        ..color = themeColors['primary']!
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final areaPath = _createAreaPath(chartRect, visibleMin, visibleMax);
      final linePath = _createPath(chartRect, visibleMin, visibleMax);

      // Draw area with animation
      final animatedAreaPath = Path();
      final pathMetrics = areaPath.computeMetrics();
      for (final metric in pathMetrics) {
        final extractedPath = metric.extractPath(
          0.0,
          metric.length * animationProgress,
        );
        animatedAreaPath.addPath(extractedPath, Offset.zero);
      }

      canvas.drawPath(animatedAreaPath, areaPaint);
      canvas.drawPath(linePath, linePaint);
    } catch (error) {
      developer.log('Error drawing area chart: $error');
    }
  }

  void _drawBarChart(Canvas canvas, Rect chartRect, double visibleMin, double visibleMax) {
    try {
      if (data.isEmpty) return;

      final barWidth = math.min(
        chartRect.width / data.length * 0.8,
        20.0 // Maximum bar width
      );
      
      final startTime = data.first.timestamp.millisecondsSinceEpoch;
      final endTime = data.last.timestamp.millisecondsSinceEpoch;
      final timeRange = endTime - startTime;

      for (int i = 0; i < data.length; i++) {
        final dataPoint = data[i];
        final x = chartRect.left + 
            (chartRect.width * (dataPoint.timestamp.millisecondsSinceEpoch - startTime) / timeRange);
        
        // Normalize the value between visibleMin and visibleMax
        final normalizedValue = (dataPoint.value - visibleMin) / (visibleMax - visibleMin);
        final barHeight = chartRect.height * normalizedValue * animationProgress;
        final y = chartRect.bottom - barHeight;

        final barGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeColors['primary']!,
            themeColors['secondary']!,
          ],
        );

        final barPaint = Paint()
          ..shader = barGradient.createShader(Rect.fromLTWH(x - barWidth/2, y, barWidth, barHeight));

        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barWidth/2, y, barWidth, barHeight),
          const Radius.circular(2),
        );

        canvas.drawRRect(barRect, barPaint);
      }
    } catch (error) {
      developer.log('Error drawing bar chart: $error');
    }
  }

  void _drawDataPoints(Canvas canvas, Rect chartRect, double visibleMin, double visibleMax) {
    try {
      if (data.isEmpty) return;

      final startTime = data.first.timestamp.millisecondsSinceEpoch;
      final endTime = data.last.timestamp.millisecondsSinceEpoch;
      final timeRange = endTime - startTime;

      for (final dataPoint in data) {
        final x = chartRect.left + 
            (chartRect.width * (dataPoint.timestamp.millisecondsSinceEpoch - startTime) / timeRange);
        final y = chartRect.bottom - 
            (chartRect.height * (dataPoint.value - visibleMin) / (visibleMax - visibleMin));

        // Draw glow effect
        final glowPaint = Paint()
          ..color = themeColors['primary']!.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        
        canvas.drawCircle(Offset(x, y), pointSize * 2, glowPaint);

        // Draw main point
        final pointPaint = Paint()
          ..color = themeColors['primary']!
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), pointSize, pointPaint);

        // Draw inner highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), pointSize * 0.4, highlightPaint);
      }
    } catch (error) {
      developer.log('Error drawing data points: $error');
    }
  }

  void _drawHoverIndicator(Canvas canvas, Rect chartRect, double visibleMin, double visibleMax) {
    try {
      if (hoveredData == null || data.isEmpty) return;

      final startTime = data.first.timestamp.millisecondsSinceEpoch;
      final endTime = data.last.timestamp.millisecondsSinceEpoch;
      final timeRange = endTime - startTime;
      
      final x = chartRect.left + 
          (chartRect.width * (hoveredData!.timestamp.millisecondsSinceEpoch - startTime) / timeRange);
      final y = chartRect.bottom - 
          (chartRect.height * (hoveredData!.value - visibleMin) / (visibleMax - visibleMin));

      // Draw vertical line with glow
      final verticalLinePaint = Paint()
        ..color = themeColors['primary']!.withOpacity(0.6)
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        verticalLinePaint,
      );

      // Draw hover point with animation
      final hoverSize = pointSize * 2 * pulseAnimation;
      
      // Outer glow
      final outerGlowPaint = Paint()
        ..color = themeColors['primary']!.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(Offset(x, y), hoverSize * 2, outerGlowPaint);

      // Main hover circle
      final hoverPaint = Paint()
        ..color = themeColors['primary']!
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), hoverSize, hoverPaint);

      // Inner ring
      final ringPaint = Paint()
        ..color = themeColors['secondary']!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(Offset(x, y), hoverSize * 0.7, ringPaint);

      // Center highlight
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), hoverSize * 0.3, centerPaint);
    } catch (error) {
      developer.log('Error drawing hover indicator: $error');
    }
  }

  Path _createPath(Rect chartRect, double visibleMin, double visibleMax) {
    try {
      final path = Path();
      if (data.isEmpty) return path;

      final startTime = data.first.timestamp.millisecondsSinceEpoch;
      final endTime = data.last.timestamp.millisecondsSinceEpoch;
      final timeRange = endTime - startTime;

      for (int i = 0; i < data.length; i++) {
        final dataPoint = data[i];
        final x = chartRect.left + 
            (chartRect.width * (dataPoint.timestamp.millisecondsSinceEpoch - startTime) / timeRange);
        final y = chartRect.bottom - 
            (chartRect.height * (dataPoint.value - visibleMin) / (visibleMax - visibleMin));

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevDataPoint = data[i - 1];
          final prevX = chartRect.left + 
              (chartRect.width * (prevDataPoint.timestamp.millisecondsSinceEpoch - startTime) / timeRange);
          final prevY = chartRect.bottom - 
              (chartRect.height * (prevDataPoint.value - visibleMin) / (visibleMax - visibleMin));
          
          final controlX = prevX + (x - prevX) / 2;
          path.quadraticBezierTo(controlX, prevY, x, y);
        }
      }

      return path;
    } catch (error) {
      developer.log('Error creating path: $error');
      return Path();
    }
  }

  Path _createAreaPath(Rect chartRect, double visibleMin, double visibleMax) {
    try {
      final path = _createPath(chartRect, visibleMin, visibleMax);
      if (data.isEmpty) return path;

      final startTime = data.first.timestamp.millisecondsSinceEpoch;
      final endTime = data.last.timestamp.millisecondsSinceEpoch;
      final timeRange = endTime - startTime;

      final lastX = chartRect.left + 
          (chartRect.width * (data.last.timestamp.millisecondsSinceEpoch - startTime) / timeRange);
      
      path.lineTo(lastX, chartRect.bottom);
      path.lineTo(chartRect.left, chartRect.bottom);
      path.close();

      return path;
    } catch (error) {
      developer.log('Error creating area path: $error');
      return Path();
    }
  }

  @override
  bool shouldRepaint(AdvancedChartPainter oldDelegate) {
    try {
      return data != oldDelegate.data ||
             minValue != oldDelegate.minValue ||
             maxValue != oldDelegate.maxValue ||
             themeColors != oldDelegate.themeColors ||
             hoverPosition != oldDelegate.hoverPosition ||
             hoveredData != oldDelegate.hoveredData ||
             chartType != oldDelegate.chartType ||
             showGrid != oldDelegate.showGrid ||
             showDataPoints != oldDelegate.showDataPoints ||
             lineWidth != oldDelegate.lineWidth ||
             pointSize != oldDelegate.pointSize ||
             animationProgress != oldDelegate.animationProgress ||
             pulseAnimation != oldDelegate.pulseAnimation;
    } catch (error) {
      developer.log('Error in shouldRepaint: $error');
      return true;
    }
  }
} 