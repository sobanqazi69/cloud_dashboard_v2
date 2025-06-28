import 'dart:developer' as developer;
import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<Map<String, dynamic>> getMetricsStream() {
    try {
      developer.log('Initializing database stream');
      return _dbRef.onValue.map((event) {
        try {
          developer.log('Received data: ${event.snapshot.value}');
          final dynamic snapshotValue = event.snapshot.value;
          if (snapshotValue == null) {
            developer.log('No data received from Firebase');
            return <String, dynamic>{};
          }
          
          final Map<String, dynamic> data = Map<String, dynamic>.from(snapshotValue as Map);
          return {
            'oxygen_flow': (data['oxygen_flow'] ?? 0.0) as num,
            'oxygen_pressure': (data['oxygen_pressure'] ?? 0.0) as num,
            'oxygen_purity': (data['oxygen_purity'] ?? 0.0) as num,
            'running_hours': (data['running_hours'] ?? 0.0) as num,
            'temp_1': (data['temp_1'] ?? 0.0) as num,
          };
        } catch (e, stackTrace) {
          developer.log(
            'Error processing Firebase data',
            error: e,
            stackTrace: stackTrace,
          );
          throw Exception('Failed to process data: $e');
        }
      }).handleError((error) {
        developer.log(
          'Stream error',
          error: error,
          stackTrace: StackTrace.current,
        );
        throw Exception('Database stream error: $error');
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing database stream',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to initialize database stream: $e');
    }
  }
} 