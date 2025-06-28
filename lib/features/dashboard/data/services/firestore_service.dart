import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/metric_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MetricData>> getMetricHistory(String metricType, {int hours = 24}) async {
    try {
      developer.log('Fetching $metricType history for last $hours hours');
      
      final DateTime now = DateTime.now();
      final DateTime startTime = now.subtract(Duration(hours: hours));
      
      final startTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        startTime.millisecondsSinceEpoch
      );
      
      final QuerySnapshot querySnapshot = await _firestore
          .collection(metricType)
          .where('timestamp', isGreaterThan: startTimestamp)
          .orderBy('timestamp', descending: false)
          .get();

      final List<MetricData> metricDataList = [];
      
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          
          DateTime timestamp;
          if (data['timestamp'] is Timestamp) {
            final ts = data['timestamp'] as Timestamp;
            timestamp = DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch);
          } else if (data['timestamp'] is String) {
            timestamp = DateTime.parse(data['timestamp'] as String);
          } else {
            timestamp = DateTime.now();
          }
          
          double value = 0.0;
          if (data['value'] is num) {
            value = (data['value'] as num).toDouble();
          }
          
          final metricData = MetricData(
            timestamp: timestamp,
            value: value,
            metricType: metricType,
            unit: getUnitForMetricType(metricType),
            additionalData: data,
          );
          
          metricDataList.add(metricData);
        } catch (e) {
          developer.log('Error parsing document ${doc.id}: $e');
        }
      }
      
      developer.log('Retrieved ${metricDataList.length} records for $metricType');
      return metricDataList;
      
    } catch (error) {
      developer.log('Error fetching $metricType history: $error');
      throw Exception('Failed to fetch metric history: $error');
    }
  }

  Stream<List<MetricData>> getMetricHistoryStream(String metricType, {int hours = 24}) {
    try {
      developer.log('Setting up stream for $metricType history');
      
      final DateTime now = DateTime.now();
      final DateTime startTime = now.subtract(Duration(hours: hours));
      
      final startTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        startTime.millisecondsSinceEpoch
      );
      
      return _firestore
          .collection(metricType)
          .where('timestamp', isGreaterThan: startTimestamp)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((querySnapshot) {
        final List<MetricData> metricDataList = [];
        
        for (final doc in querySnapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            
            DateTime timestamp;
            if (data['timestamp'] is Timestamp) {
              final ts = data['timestamp'] as Timestamp;
              timestamp = DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch);
            } else if (data['timestamp'] is String) {
              timestamp = DateTime.parse(data['timestamp'] as String);
            } else {
              timestamp = DateTime.now();
            }
            
            double value = 0.0;
            if (data['value'] is num) {
              value = (data['value'] as num).toDouble();
            }
            
            final metricData = MetricData(
              timestamp: timestamp,
              value: value,
              metricType: metricType,
              unit: getUnitForMetricType(metricType),
              additionalData: data,
            );
            
            metricDataList.add(metricData);
          } catch (e) {
            developer.log('Error parsing document ${doc.id}: $e');
          }
        }
        
        return metricDataList;
      });
      
    } catch (error) {
      developer.log('Error setting up stream for $metricType: $error');
      throw Exception('Failed to setup metric history stream: $error');
    }
  }

  String getUnitForMetricType(String metricType) {
    try {
      switch (metricType) {
        case 'oxygen_flow':
          return 'm³/hr';
        case 'oxygen_pressure':
          return 'Bar';
        case 'oxygen_purity':
          return '%';
        case 'running_hours':
          return 'hrs';
        case 'temp_1':
          return '°C';
        default:
          return '';
      }
    } catch (error) {
      developer.log('Error getting unit for $metricType: $error');
      return '';
    }
  }

  String getDisplayNameForMetricType(String metricType) {
    try {
      switch (metricType) {
        case 'oxygen_flow':
          return 'Oxygen Flow';
        case 'oxygen_pressure':
          return 'Oxygen Pressure';
        case 'oxygen_purity':
          return 'Oxygen Purity';
        case 'running_hours':
          return 'Running Hours';
        case 'temp_1':
          return 'Temperature';
        default:
          return metricType.replaceAll('_', ' ').toUpperCase();
      }
    } catch (error) {
      developer.log('Error getting display name for $metricType: $error');
      return metricType;
    }
  }

  double getMaxValueForMetricType(String metricType) {
    try {
      switch (metricType) {
        case 'oxygen_flow':
          return 50;
        case 'oxygen_pressure':
          return 10;
        case 'oxygen_purity':
          return 100;
        case 'running_hours':
          return 100;
        case 'temp_1':
          return 100;
        default:
          return 100;
      }
    } catch (error) {
      developer.log('Error getting max value for $metricType: $error');
      return 100;
    }
  }

  Color getColorForMetricType(String metricType) {
    try {
      switch (metricType) {
        case 'oxygen_flow':
          return const Color(0xFF3B82F6);
        case 'oxygen_pressure':
          return const Color(0xFF60A5FA);
        case 'oxygen_purity':
          return const Color(0xFF2563EB);
        case 'running_hours':
          return const Color(0xFF1D4ED8);
        case 'temp_1':
          return const Color(0xFF3B82F6);
        default:
          return const Color(0xFF3B82F6);
      }
    } catch (error) {
      developer.log('Error getting color for $metricType: $error');
      return const Color(0xFF3B82F6);
    }
  }
} 