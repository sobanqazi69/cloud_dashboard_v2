import 'package:flutter/material.dart';
import 'dart:math' as math;

class MetricGauge extends StatefulWidget {
  final String title;
  final double value;
  final String unit;
  final double maxValue;
  final Color color;

  const MetricGauge({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.maxValue = 100,
    this.color = const Color(0xFF3B82F6),
  });

  @override
  State<MetricGauge> createState() => _MetricGaugeState();
}

class _MetricGaugeState extends State<MetricGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gaugeAnimation;
  late Animation<double> _valueAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _initializeAnimations();
    _controller.forward();
  }

  void _initializeAnimations() {
    // Gauge arc animation with spring effect
    _gaugeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );

    // Value counter animation
    _valueAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    );

    // Fade in animation
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    // Scale animation
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOutBack),
    );

    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));
  }

  @override
  void didUpdateWidget(MetricGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * math.pi,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CustomPaint(
                              painter: GaugePainter(
                                value: widget.value * _gaugeAnimation.value,
                                maxValue: widget.maxValue,
                                color: widget.color,
                                rotationFactor: _rotationAnimation.value,
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: -_rotationAnimation.value * math.pi,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _valueAnimation,
                                  builder: (context, child) {
                                    return Text(
                                      (widget.value * _valueAnimation.value).toStringAsFixed(2),
                                      style: TextStyle(
                                        color: widget.color,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  widget.unit,
                                  style: TextStyle(
                                    color: widget.color,
                                    fontSize: 12,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;
  final double rotationFactor;

  GaugePainter({
    required this.value,
    required this.maxValue,
    required this.color,
    required this.rotationFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final baseStartAngle = 150 * math.pi / 180;
    final startAngle = baseStartAngle + (rotationFactor * math.pi);
    const sweepAngle = 240 * math.pi / 180;
    
    // Draw background arc
    final bgPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Draw value arc with solid color
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final valueAngle = (value / maxValue * sweepAngle).clamp(0.0, sweepAngle);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      startAngle,
      valueAngle,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.value != value ||
           oldDelegate.maxValue != maxValue ||
           oldDelegate.color != color ||
           oldDelegate.rotationFactor != rotationFactor;
  }
} 