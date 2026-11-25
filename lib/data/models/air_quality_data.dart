/// Model data kualitas udara dari Open-Meteo Air Quality API.
class AirQualityData {
  const AirQualityData({
    required this.europeanAqi,
    required this.usAqi,
    required this.pm25,
    required this.pm10,
  });

  final int europeanAqi;
  final int usAqi;
  final double pm25;
  final double pm10;

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    final current = (json['current'] as Map<String, dynamic>?) ?? json;
    return AirQualityData(
      europeanAqi: (current['european_aqi'] as num?)?.round() ?? 0,
      usAqi: (current['us_aqi'] as num?)?.round() ?? 0,
      pm25: (current['pm2_5'] as num?)?.toDouble() ?? 0.0,
      pm10: (current['pm10'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
