/// Model prakiraan cuaca per jam dari array paralel `hourly` Open-Meteo.
class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.precipitationProbability,
    required this.precipitation,
    required this.weatherCode,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.isDay,
  });

  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final int precipitationProbability;
  final double precipitation;
  final int weatherCode;
  final int relativeHumidity;
  final double windSpeed;
  final double uvIndex;
  final bool isDay;

  /// Menggabungkan array paralel `hourly` dari respons Open-Meteo berdasarkan indeks.
  static List<HourlyForecast> listFromParallelJson(Map<String, dynamic> json) {
    final times = (json['time'] as List<dynamic>?) ?? const [];
    final temps = (json['temperature_2m'] as List<dynamic>?) ?? const [];
    final apparentTemps =
        (json['apparent_temperature'] as List<dynamic>?) ?? const [];
    final precipProbs =
        (json['precipitation_probability'] as List<dynamic>?) ?? const [];
    final precips = (json['precipitation'] as List<dynamic>?) ?? const [];
    final codes = (json['weather_code'] as List<dynamic>?) ?? const [];
    final humidities =
        (json['relative_humidity_2m'] as List<dynamic>?) ?? const [];
    final winds = (json['wind_speed_10m'] as List<dynamic>?) ?? const [];
    final uvs = (json['uv_index'] as List<dynamic>?) ?? const [];
    final isDays = (json['is_day'] as List<dynamic>?) ?? const [];

    final count = times.length;
    final items = <HourlyForecast>[];

    for (var i = 0; i < count; i++) {
      final parsedTime =
          DateTime.tryParse(times[i]?.toString() ?? '') ?? DateTime.now();
      final temp = _doubleAt(temps, i) ?? 0.0;
      final rawDay = _intAt(isDays, i);
      final dayFlag = rawDay != null
          ? rawDay == 1
          : (parsedTime.hour >= 6 && parsedTime.hour < 18);

      items.add(
        HourlyForecast(
          time: parsedTime,
          temperature: temp,
          apparentTemperature: _doubleAt(apparentTemps, i) ?? temp,
          precipitationProbability: _intAt(precipProbs, i) ?? 0,
          precipitation: _doubleAt(precips, i) ?? 0.0,
          weatherCode: _intAt(codes, i) ?? 0,
          relativeHumidity: _intAt(humidities, i) ?? 0,
          windSpeed: _doubleAt(winds, i) ?? 0.0,
          uvIndex: _doubleAt(uvs, i) ?? 0.0,
          isDay: dayFlag,
        ),
      );
    }

    return items;
  }

  static double? _doubleAt(List<dynamic> list, int index) {
    if (index >= list.length || list[index] == null) return null;
    return (list[index] as num).toDouble();
  }

  static int? _intAt(List<dynamic> list, int index) {
    if (index >= list.length || list[index] == null) return null;
    return (list[index] as num).round();
  }
}
