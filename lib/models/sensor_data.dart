import 'package:json_annotation/json_annotation.dart';

part 'sensor_data.g.dart';

@JsonSerializable()
class SensorData {
  @JsonKey(name: 'airi_temp')
  final double airiTemp;
  
  @JsonKey(name: 'airo_temp')
  final double airoTemp;
  
  @JsonKey(name: 'booster_status')
  final int boosterStatus;
  
  @JsonKey(name: 'boosto_temp')
  final double boostoTemp;
  
  @JsonKey(name: 'comp_on_status')
  final int compOnStatus;
  
  @JsonKey(name: 'drypdp_temp')
  final double drypdpTemp;
  
  final double oxygen;
  
  @JsonKey(name: 'air_outletp')
  final double airOutletp;
  
  @JsonKey(name: 'booster_hour')
  final double boosterHour;
  
  @JsonKey(name: 'comp_load')
  final double compLoad;
  
  @JsonKey(name: 'comp_running_hour')
  final double compRunningHour;
  
  @JsonKey(name: 'oxy_flow')
  final double oxyFlow;
  
  @JsonKey(name: 'oxy_pressure')
  final double oxyPressure;
  
  final String timestamp;
  final int id;

  const SensorData({
    required this.airiTemp,
    required this.airoTemp,
    required this.boosterStatus,
    required this.boostoTemp,
    required this.compOnStatus,
    required this.drypdpTemp,
    required this.oxygen,
    required this.airOutletp,
    required this.boosterHour,
    required this.compLoad,
    required this.compRunningHour,
    required this.oxyFlow,
    required this.oxyPressure,
    required this.timestamp,
    required this.id,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) => _$SensorDataFromJson(json);
  Map<String, dynamic> toJson() => _$SensorDataToJson(this);

  DateTime get parsedTimestamp {
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return DateTime.now();
    }
  }
}

@JsonSerializable()
class SensorDataResponse {
  final bool success;
  final String message;
  final List<SensorData> data;
  final int count;
  final SensorDataPagination pagination;
  final String? warning;

  const SensorDataResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.count,
    required this.pagination,
    this.warning,
  });

  factory SensorDataResponse.fromJson(Map<String, dynamic> json) => _$SensorDataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SensorDataResponseToJson(this);
}

@JsonSerializable()
class SensorDataPagination {
  @JsonKey(name: 'total_records')
  final int totalRecords;
  
  @JsonKey(name: 'total_pages')
  final int totalPages;
  
  @JsonKey(name: 'current_page')
  final int currentPage;
  
  @JsonKey(name: 'records_per_page')
  final int recordsPerPage;
  
  @JsonKey(name: 'has_next')
  final bool hasNext;
  
  @JsonKey(name: 'has_previous')
  final bool hasPrevious;
  
  @JsonKey(name: 'next_page')
  final int? nextPage;
  
  @JsonKey(name: 'previous_page')
  final int? previousPage;
  
  @JsonKey(name: 'page_start_record')
  final int pageStartRecord;
  
  @JsonKey(name: 'page_end_record')
  final int pageEndRecord;

  const SensorDataPagination({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.recordsPerPage,
    required this.hasNext,
    required this.hasPrevious,
    this.nextPage,
    this.previousPage,
    required this.pageStartRecord,
    required this.pageEndRecord,
  });

  factory SensorDataPagination.fromJson(Map<String, dynamic> json) => _$SensorDataPaginationFromJson(json);
  Map<String, dynamic> toJson() => _$SensorDataPaginationToJson(this);
}

// Enum to define all available sensor metrics
enum SensorMetric {
  airiTemp('airi_temp', 'Air Inlet Temperature', '°C'),
  airoTemp('airo_temp', 'Air Outlet Temperature', '°C'),
  boosterStatus('booster_status', 'Booster Status', ''),
  boostoTemp('boosto_temp', 'Booster Temperature', '°C'),
  compOnStatus('comp_on_status', 'Compressor Status', ''),
  drypdpTemp('drypdp_temp', 'Dryer Temperature', '°C'),
  oxygen('oxygen', 'Oxygen Purity', '%'),
  airOutletp('air_outletp', 'Air Outlet Pressure', 'Bar'),
  boosterHour('booster_hour', 'Booster Hours', 'hrs'),
  compLoad('comp_load', 'Compressor Load', '%'),
  compRunningHour('comp_running_hour', 'Compressor Running Hours', 'hrs'),
  oxyFlow('oxy_flow', 'Oxygen Flow', 'm³/hr'),
  oxyPressure('oxy_pressure', 'Oxygen Pressure', 'Bar');

  const SensorMetric(this.key, this.displayName, this.unit);

  final String key;
  final String displayName;
  final String unit;

  double getValue(SensorData data) {
    try {
      switch (this) {
        case SensorMetric.airiTemp:
          return data.airiTemp;
        case SensorMetric.airoTemp:
          return data.airoTemp;
        case SensorMetric.boosterStatus:
          return data.boosterStatus.toDouble();
        case SensorMetric.boostoTemp:
          return data.boostoTemp;
        case SensorMetric.compOnStatus:
          return data.compOnStatus.toDouble();
        case SensorMetric.drypdpTemp:
          return data.drypdpTemp;
        case SensorMetric.oxygen:
          return data.oxygen;
        case SensorMetric.airOutletp:
          return data.airOutletp;
        case SensorMetric.boosterHour:
          return data.boosterHour;
        case SensorMetric.compLoad:
          return data.compLoad;
        case SensorMetric.compRunningHour:
          return data.compRunningHour;
        case SensorMetric.oxyFlow:
          return data.oxyFlow;
        case SensorMetric.oxyPressure:
          return data.oxyPressure;
      }
    } catch (e) {
      return 0.0;
    }
  }
}
