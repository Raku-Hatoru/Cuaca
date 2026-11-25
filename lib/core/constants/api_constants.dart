import '../../data/models/location_model.dart';

/// Konstanta endpoint API Open-Meteo, kunci penyimpanan lokal, dan lokasi default.
class ApiConstants {
  ApiConstants._();

  static const String forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String airQualityBaseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  static const Duration requestTimeout = Duration(seconds: 10);

  // Kunci penyimpanan lokal (SharedPreferences)
  static const String favoritesKey = 'favorites';
  static const String searchHistoryKey = 'search_history';
  static const String lastLocationKey = 'last_location';
  static const String useFahrenheitKey = 'use_fahrenheit';

  static const int maxSearchHistory = 10;

  /// Lokasi default saat pengguna pertama kali membuka aplikasi.
  static const LocationModel defaultLocation = LocationModel(
    id: 1642911,
    name: 'Jakarta',
    latitude: -6.2146,
    longitude: 106.8451,
    country: 'Indonesia',
    countryCode: 'ID',
    admin1: 'DKI Jakarta',
    timezone: 'Asia/Jakarta',
  );

  /// Daftar kota populer untuk pilihan cepat pada layar pencarian.
  /// Data cuacanya diambil secara langsung dari API Open-Meteo.
  static const List<LocationModel> popularCities = [
    LocationModel(
      id: 1850147,
      name: 'Tokyo',
      latitude: 35.6895,
      longitude: 139.6917,
      country: 'Jepang',
      countryCode: 'JP',
      admin1: 'Tokyo',
      timezone: 'Asia/Tokyo',
    ),
    LocationModel(
      id: 1880252,
      name: 'Singapura',
      latitude: 1.2897,
      longitude: 103.8501,
      country: 'Singapura',
      countryCode: 'SG',
      admin1: 'Central Singapore',
      timezone: 'Asia/Singapore',
    ),
    LocationModel(
      id: 2643743,
      name: 'London',
      latitude: 51.5085,
      longitude: -0.1257,
      country: 'Inggris Raya',
      countryCode: 'GB',
      admin1: 'England',
      timezone: 'Europe/London',
    ),
    LocationModel(
      id: 2147714,
      name: 'Sydney',
      latitude: -33.8679,
      longitude: 151.2073,
      country: 'Australia',
      countryCode: 'AU',
      admin1: 'New South Wales',
      timezone: 'Australia/Sydney',
    ),
  ];

  static Uri geocodingUri(String query, {int count = 10}) {
    return Uri.parse(geocodingBaseUrl).replace(
      queryParameters: {
        'name': query.trim(),
        'count': count.toString(),
        'language': 'id',
        'format': 'json',
      },
    );
  }

  static Uri forecastUri(double latitude, double longitude) {
    return Uri.parse(forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,dew_point_2m,is_day',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,sunrise,sunset,uv_index_max,wind_speed_10m_max',
        'hourly':
            'temperature_2m,apparent_temperature,precipitation_probability,precipitation,weather_code,relative_humidity_2m,wind_speed_10m,uv_index,is_day',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );
  }

  static Uri batchCurrentWeatherUri(List<LocationModel> locations) {
    final latitudes = locations.map((e) => e.latitude.toString()).join(',');
    final longitudes = locations.map((e) => e.longitude.toString()).join(',');
    return Uri.parse(forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitudes,
        'longitude': longitudes,
        'current':
            'temperature_2m,weather_code,wind_speed_10m,is_day',
        'daily': 'precipitation_probability_max,uv_index_max',
        'timezone': 'auto',
        'forecast_days': '1',
      },
    );
  }

  static Uri airQualityUri(double latitude, double longitude) {
    return Uri.parse(airQualityBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'european_aqi,us_aqi,pm2_5,pm10',
        'timezone': 'auto',
      },
    );
  }
}
