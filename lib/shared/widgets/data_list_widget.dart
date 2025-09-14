import 'package:flutter/material.dart';
import '../../models/sensor_data.dart';

class DataListWidget extends StatefulWidget {
  final List<SensorData> data;
  final SensorMetric metric;
  final Color primaryColor;

  const DataListWidget({
    Key? key,
    required this.data,
    required this.metric,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<DataListWidget> createState() => _DataListWidgetState();
}

class _DataListWidgetState extends State<DataListWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;
  
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _shimmerAnimation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _shimmerController.repeat();

    // Auto-scroll to bottom when new data arrives
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_autoScroll && _scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DataListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.length > oldWidget.data.length && _autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.primaryColor.withOpacity(0.05),
            Colors.transparent,
            widget.primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildDataList(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final stats = _calculateQuickStats();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.primaryColor.withOpacity(0.1),
            widget.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(
            color: widget.primaryColor.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Data Feed',
                style: TextStyle(
                  color: widget.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: widget.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickStat('Latest', stats['latest']!),
              _buildQuickStat('Trend', stats['trend']!),
              _buildQuickStat('Records', widget.data.length.toDouble()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, double value) {
    String displayValue;
    Color valueColor = widget.primaryColor;

    if (label == 'Trend') {
      if (value > 0) {
        displayValue = '+${value.toStringAsFixed(1)}%';
        valueColor = Colors.green;
      } else if (value < 0) {
        displayValue = '${value.toStringAsFixed(1)}%';
        valueColor = Colors.red;
      } else {
        displayValue = '0.0%';
        valueColor = Colors.grey;
      }
    } else if (label == 'Records') {
      displayValue = value.toInt().toString();
    } else {
      displayValue = value.toStringAsFixed(1);
    }

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: widget.primaryColor.withOpacity(0.7),
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          displayValue,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDataList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification) {
            final isAtBottom = _scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 50;
            setState(() {
              _autoScroll = isAtBottom;
            });
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemCount: widget.data.length,
          itemBuilder: (context, index) {
            final data = widget.data[index];
            final value = widget.metric.getValue(data);
            final isLatest = index == widget.data.length - 1;
            
            return _buildDataItem(data, value, index, isLatest);
          },
        ),
      ),
    );
  }

  Widget _buildDataItem(SensorData data, double value, int index, bool isLatest) {
    final timestamp = data.parsedTimestamp;
    final isEven = index % 2 == 0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: isLatest
            ? widget.primaryColor.withOpacity(0.1)
            : isEven
                ? Colors.black.withOpacity(0.2)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isLatest
            ? Border.all(color: widget.primaryColor.withOpacity(0.3))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            // Time
            Container(
              width: 45,
              child: Text(
                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isLatest
                      ? widget.primaryColor
                      : widget.primaryColor.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            
            // Value
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(
                      color: isLatest ? Colors.white : Colors.grey[300],
                      fontSize: 12,
                      fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (widget.metric.unit.isNotEmpty)
                    Text(
                      widget.metric.unit,
                      style: TextStyle(
                        color: widget.primaryColor.withOpacity(0.5),
                        fontSize: 8,
                      ),
                    ),
                ],
              ),
            ),
            
            // Indicator
            if (isLatest)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
            else
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.primaryColor.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
            color: widget.primaryColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
              if (_autoScroll) {
                _scrollToBottom();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _autoScroll
                    ? widget.primaryColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.primaryColor.withOpacity(_autoScroll ? 0.5 : 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _autoScroll ? Icons.sync : Icons.sync_disabled,
                    color: widget.primaryColor.withOpacity(_autoScroll ? 1 : 0.5),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Auto',
                    style: TextStyle(
                      color: widget.primaryColor.withOpacity(_autoScroll ? 1 : 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          GestureDetector(
            onTap: _scrollToBottom,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: widget.primaryColor,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Latest',
                    style: TextStyle(
                      color: widget.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.primaryColor.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(_shimmerAnimation.value * 20, 0),
                  child: Icon(
                    Icons.sensors,
                    color: widget.primaryColor.withOpacity(0.5),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Waiting for data...',
                  style: TextStyle(
                    color: widget.primaryColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, double> _calculateQuickStats() {
    if (widget.data.isEmpty) {
      return {'latest': 0.0, 'trend': 0.0};
    }

    final latest = widget.metric.getValue(widget.data.last);
    
    double trend = 0.0;
    if (widget.data.length > 1) {
      final previous = widget.metric.getValue(widget.data[widget.data.length - 2]);
      if (previous != 0) {
        trend = ((latest - previous) / previous) * 100;
      }
    }

    return {
      'latest': latest,
      'trend': trend,
    };
  }
}
