import 'air_quality_data.dart';
import 'current_weather.dart';
import 'daily_forecast.dart';
import 'hourly_forecast.dart';
import 'location_model.dart';

/// Model agregat data cuaca lengkap untuk satu lokasi terpilih.
class WeatherData {
  const WeatherData({
    required this.location,
    required this.current,
    required this.daily,
    required this.hourly,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.utcOffsetSeconds,
    required this.fetchedAt,
    this.airQuality,
  });

  final LocationModel location;
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;
  final String timezone;
  final String timezoneAbbreviation;
  final int utcOffsetSeconds;
  final DateTime fetchedAt;
  final AirQualityData? airQuality;

  factory WeatherData.fromForecastJson(
    Map<String, dynamic> json, {
    required LocationModel location,
    AirQualityData? airQuality,
  }) {
    final currentJson =
        (json['current'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final dailyJson =
        (json['daily'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final hourlyJson =
        (json['hourly'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return WeatherData(
      location: location,
      current: CurrentWeather.fromJson(currentJson),
      daily: DailyForecast.listFromParallelJson(dailyJson),
      hourly: HourlyForecast.listFromParallelJson(hourlyJson),
      timezone: (json['timezone'] as String?) ?? location.timezone,
      timezoneAbbreviation:
          (json['timezone_abbreviation'] as String?) ?? 'Lokal',
      utcOffsetSeconds: (json['utc_offset_seconds'] as num?)?.toInt() ?? 0,
      fetchedAt: DateTime.now(),
      airQuality: airQuality,
    );
  }

  WeatherData copyWith({
    AirQualityData? airQuality,
  }) {
    return WeatherData(
      location: location,
      current: current,
      daily: daily,
      hourly: hourly,
      timezone: timezone,
      timezoneAbbreviation: timezoneAbbreviation,
      utcOffsetSeconds: utcOffsetSeconds,
      fetchedAt: fetchedAt,
      airQuality: airQuality ?? this.airQuality,
    );
  }

  /// Waktu lokal kota saat ini berdasarkan `utc_offset_seconds` dari Open-Meteo.
  DateTime get cityLocalNow {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(Duration(seconds: utcOffsetSeconds));
  }

  DailyForecast? get todayDaily => daily.isNotEmpty ? daily.first : null;

  /// Mengambil 24 jam ke depan mulai dari jam aktif pada waktu lokal kota.
  List<HourlyForecast> get next24Hours {
    if (hourly.isEmpty) return const [];
    final ref = current.time;
    final refHour = DateTime(ref.year, ref.month, ref.day, ref.hour);

    var startIndex = hourly.indexWhere(
      (item) => !item.time.isBefore(refHour),
    );
    if (startIndex < 0) {
      startIndex = 0;
    }

    final endIndex = (startIndex + 24) > hourly.length
        ? hourly.length
        : startIndex + 24;
    return hourly.sublist(startIndex, endIndex);
  }

  /// Mengambil data prakiraan per jam untuk tanggal tertentu.
  List<HourlyForecast> hourlyForDay(DateTime day) {
    return hourly
        .where(
          (item) =>
              item.time.year == day.year &&
              item.time.month == day.month &&
              item.time.day == day.day,
        )
        .toList(growable: false);
  }

  /// Indeks UV terkini berdasarkan jam berjalan.
  double get currentUvIndex {
    final hours = next24Hours;
    if (hours.isNotEmpty) return hours.first.uvIndex;
    return todayDaily?.uvIndexMax ?? 0.0;
  }

  /// Progres posisi matahari (0.0 - 1.0) untuk kurva siklus matahari.
  double get sunCycleProgress {
    final today = todayDaily;
    if (today == null) return 0.5;
    final now = cityLocalNow;
    final currentAsLocal = DateTime(
      today.date.year,
      today.date.month,
      today.date.day,
      now.hour,
      now.minute,
    );
    final total = today.sunset.difference(today.sunrise).inMinutes;
    if (total <= 0) return 0.5;
    final elapsed = currentAsLocal.difference(today.sunrise).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}

/// Ringkasan cuaca ringan untuk kartu Kota Populer dan Kota Favorit.
class CityWeatherSummary {
  const CityWeatherSummary({
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
    required this.windSpeed,
    this.precipitationProbability,
    this.uvIndexMax,
  });

  final double temperature;
  final int weatherCode;
  final bool isDay;
  final double windSpeed;
  final int? precipitationProbability;
  final double? uvIndexMax;

  factory CityWeatherSummary.fromJson(Map<String, dynamic> json) {
    final current =
        (json['current'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final daily =
        (json['daily'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final popList = daily['precipitation_probability_max'] as List<dynamic>?;
    final uvList = daily['uv_index_max'] as List<dynamic>?;

    final rawIsDay = current['is_day'];
    final isDayBool =
        rawIsDay is bool ? rawIsDay : (rawIsDay as num?)?.toInt() == 1;

    return CityWeatherSummary(
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      isDay: isDayBool,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      precipitationProbability:
          (popList != null && popList.isNotEmpty && popList.first != null)
          ? (popList.first as num).round()
          : null,
      uvIndexMax: (uvList != null && uvList.isNotEmpty && uvList.first != null)
          ? (uvList.first as num).toDouble()
          : null,
    );
  }
}
