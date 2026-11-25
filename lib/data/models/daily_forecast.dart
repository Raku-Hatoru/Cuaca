/// Model prakiraan cuaca harian dari array paralel `daily` Open-Meteo.
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    required this.precipitationSum,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
    required this.windSpeedMax,
  });

  final DateTime date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;
  final double precipitationSum;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndexMax;
  final double windSpeedMax;

  Duration get daylightDuration {
    final diff = sunset.difference(sunrise);
    return diff.isNegative ? const Duration(hours: 12) : diff;
  }

  Duration get nightDuration {
    final diff = const Duration(hours: 24) - daylightDuration;
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Menggabungkan array paralel `daily` dari respons Open-Meteo berdasarkan indeks.
  static List<DailyForecast> listFromParallelJson(Map<String, dynamic> json) {
    final times = (json['time'] as List<dynamic>?) ?? const [];
    final codes = (json['weather_code'] as List<dynamic>?) ?? const [];
    final maxTemps =
        (json['temperature_2m_max'] as List<dynamic>?) ?? const [];
    final minTemps =
        (json['temperature_2m_min'] as List<dynamic>?) ?? const [];
    final precipProbs =
        (json['precipitation_probability_max'] as List<dynamic>?) ?? const [];
    final precipSums =
        (json['precipitation_sum'] as List<dynamic>?) ?? const [];
    final sunrises = (json['sunrise'] as List<dynamic>?) ?? const [];
    final sunsets = (json['sunset'] as List<dynamic>?) ?? const [];
    final uvMaxes = (json['uv_index_max'] as List<dynamic>?) ?? const [];
    final windMaxes = (json['wind_speed_10m_max'] as List<dynamic>?) ?? const [];

    final count = times.length;
    final items = <DailyForecast>[];

    for (var i = 0; i < count; i++) {
      final date =
          DateTime.tryParse(times[i]?.toString() ?? '') ?? DateTime.now();
      final fallbackSunrise = DateTime(date.year, date.month, date.day, 6, 0);
      final fallbackSunset = DateTime(date.year, date.month, date.day, 18, 0);

      items.add(
        DailyForecast(
          date: date,
          weatherCode: _intAt(codes, i) ?? 0,
          temperatureMax: _doubleAt(maxTemps, i) ?? 0.0,
          temperatureMin: _doubleAt(minTemps, i) ?? 0.0,
          precipitationProbabilityMax: _intAt(precipProbs, i) ?? 0,
          precipitationSum: _doubleAt(precipSums, i) ?? 0.0,
          sunrise:
              DateTime.tryParse(_stringAt(sunrises, i) ?? '') ?? fallbackSunrise,
          sunset:
              DateTime.tryParse(_stringAt(sunsets, i) ?? '') ?? fallbackSunset,
          uvIndexMax: _doubleAt(uvMaxes, i) ?? 0.0,
          windSpeedMax: _doubleAt(windMaxes, i) ?? 0.0,
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

  static String? _stringAt(List<dynamic> list, int index) {
    if (index >= list.length || list[index] == null) return null;
    return list[index].toString();
  }
}
