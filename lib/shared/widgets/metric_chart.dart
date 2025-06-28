import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import '../../features/dashboard/domain/models/metric_data.dart';

class MetricChart extends StatelessWidget {
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
    this.lineColor = Colors.blue,
    this.areaColor = const Color(0x330000FF),
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = data.map((item) => {
      'time': item.timestamp,
      'value': item.value,
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Chart(
              data: chartData,
              variables: {
                'time': Variable(
                  accessor: (Map datum) => datum['time'] as DateTime,
                  scale: TimeScale(
                    formatter: (time) => '${time.hour.toString().padLeft(2, '0')}:00',
                  ),
                ),
                'value': Variable(
                  accessor: (Map datum) => datum['value'] as double,
                  scale: LinearScale(
                    min: minValue,
                    max: maxValue,
                  ),
                ),
              },
              marks: [
                AreaMark(
                  position: Varset('time') * Varset('value'),
                  shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
                  color: ColorEncode(value: areaColor),
                ),
                LineMark(
                  position: Varset('time') * Varset('value'),
                  shape: ShapeEncode(value: BasicLineShape(smooth: true)),
                  color: ColorEncode(value: lineColor),
                  size: SizeEncode(value: 2),
                ),
              ],
              axes: [
                Defaults.horizontalAxis,
                Defaults.verticalAxis,
              ],
              coord: RectCoord(),
            ),
          ),
          if (unit != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Unit: $unit',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 