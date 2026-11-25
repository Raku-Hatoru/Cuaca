/// Model kondisi cuaca terkini dari bagian `current` Open-Meteo Forecast API.
class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
    required this.surfacePressure,
    required this.dewPoint,
    required this.isDay,
  });

  final DateTime time;
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final double windDirection;
  final double surfacePressure;
  final double dewPoint;
  final bool isDay;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final rawIsDay = json['is_day'];
    final isDayBool = rawIsDay is bool ? rawIsDay : (rawIsDay as num?)?.toInt() == 1;

    return CurrentWeather(
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.round() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ??
          (json['temperature_2m'] as num?)?.toDouble() ??
          0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['wind_direction_10m'] as num?)?.toDouble() ?? 0.0,
      surfacePressure:
          (json['surface_pressure'] as num?)?.toDouble() ?? 1013.0,
      dewPoint: (json['dew_point_2m'] as num?)?.toDouble() ?? 0.0,
      isDay: isDayBool,
    );
  }
}
