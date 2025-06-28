import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class OxygenChart extends StatefulWidget {
  const OxygenChart({super.key});

  @override
  State<OxygenChart> createState() => _OxygenChartState();
}

class _OxygenChartState extends State<OxygenChart> {
  late List<Map<String, dynamic>> dummyData;

  @override
  void initState() {
    super.initState();
    // Generate dummy data
    dummyData = List.generate(100, (index) {
      final time = DateTime.now().subtract(Duration(minutes: 100 - index));
      final baseValue = 85.0;
      final wave = math.sin(index * 0.1) * 5.0;
      final random = math.Random().nextDouble() * 2.0 - 1.0;
      final value = (baseValue + wave + random).clamp(70.0, 95.0);
      
      return {
        'time': time,
        'value': value,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Chart(
        
        data: dummyData,
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
              min: 40,
              max: 100,
            ),
          ),
        },
        marks: [
          AreaMark(
            position: Varset('time') * Varset('value'),
            shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
            color: ColorEncode(value: Colors.blue.withOpacity(0.2)),
          ),
          LineMark(
            position: Varset('time') * Varset('value'),
            shape: ShapeEncode(value: BasicLineShape(smooth: true)),
            color: ColorEncode(value: Colors.blue.shade400),
            size: SizeEncode(value: 2),
          ),
        ],
        axes: [
          Defaults.horizontalAxis,
          Defaults.verticalAxis,
        ],
        coord: RectCoord(),
      ),
    );
  }
} 