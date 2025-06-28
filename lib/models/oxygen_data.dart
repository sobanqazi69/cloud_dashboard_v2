class OxygenData {
  final double flow;
  final DateTime timestamp;

  OxygenData({
    required this.flow,
    required this.timestamp,
  });

  // Will be used when we implement real-time data fetching
  factory OxygenData.fromJson(Map<String, dynamic> json) {
    return OxygenData(
      flow: json['flow']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class OxygenDataPoint {
  final double flow;
  final DateTime timestamp;

  OxygenDataPoint({
    required this.flow,
    required this.timestamp,
  });
}

class OxygenDataProvider {
  static List<OxygenDataPoint> generateDummyData() {
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch;
    
    return List.generate(60, (index) {
      // Generate a semi-random flow value between 15 and 30
      final baseFlow = 21.60;
      final noise = (random + index) % 100 / 100.0; // Deterministic noise
      final flow = baseFlow + (noise - 0.5) * 10;
      
      return OxygenDataPoint(
        flow: double.parse(flow.toStringAsFixed(2)),
        timestamp: now.subtract(Duration(minutes: 59 - index)),
      );
    });
  }

  static double generateNextValue(double currentFlow) {
    final random = DateTime.now().millisecondsSinceEpoch % 100 / 100.0;
    final change = (random - 0.5) * 2; // Generate change between -1 and 1
    final newFlow = currentFlow + change;
    
    // Keep the value between 15 and 30
    if (newFlow < 15) return 15.0;
    if (newFlow > 30) return 30.0;
    return double.parse(newFlow.toStringAsFixed(2));
  }
} 