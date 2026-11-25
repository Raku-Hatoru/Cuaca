import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/air_quality_data.dart';
import '../models/location_model.dart';
import '../models/weather_data.dart';
import 'app_exception.dart';

/// Service HTTP GET untuk mengambil data prakiraan cuaca dan kualitas udara dari Open-Meteo.
class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherData> fetchForecast(LocationModel location) async {
    final uri = ApiConstants.forecastUri(location.latitude, location.longitude);
    final decoded = await _getJson(uri);
    if (decoded is! Map<String, dynamic>) {
      throw const AppException('Gagal memuat data cuaca');
    }
    return WeatherData.fromForecastJson(decoded, location: location);
  }

  Future<AirQualityData> fetchAirQuality(
    double latitude,
    double longitude,
  ) async {
    final uri = ApiConstants.airQualityUri(latitude, longitude);
    final decoded = await _getJson(uri);
    if (decoded is! Map<String, dynamic>) {
      throw const AppException('Gagal memuat data kualitas udara');
    }
    return AirQualityData.fromJson(decoded);
  }

  Future<Map<int, CityWeatherSummary>> fetchCitySummaries(
    List<LocationModel> locations,
  ) async {
    if (locations.isEmpty) return const {};
    final uri = ApiConstants.batchCurrentWeatherUri(locations);
    final decoded = await _getJson(uri);

    final result = <int, CityWeatherSummary>{};
    if (decoded is List) {
      for (var i = 0; i < locations.length && i < decoded.length; i++) {
        final item = decoded[i];
        if (item is Map<String, dynamic>) {
          result[locations[i].id] = CityWeatherSummary.fromJson(item);
        }
      }
    } else if (decoded is Map<String, dynamic> && locations.length == 1) {
      result[locations.first.id] = CityWeatherSummary.fromJson(decoded);
    }

    return result;
  }

  Future<dynamic> _getJson(Uri uri) async {
    try {
      final response = await _client
          .get(uri)
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw const AppException('Gagal memuat data cuaca');
      }

      return jsonDecode(response.body);
    } on AppException {
      rethrow;
    } on TimeoutException {
      throw const AppException(
        'Tidak ada koneksi internet',
        isNetworkError: true,
      );
    } on SocketException {
      throw const AppException(
        'Tidak ada koneksi internet',
        isNetworkError: true,
      );
    } on http.ClientException {
      throw const AppException(
        'Tidak ada koneksi internet',
        isNetworkError: true,
      );
    } on FormatException {
      throw const AppException('Gagal memuat data cuaca');
    }
  }
}
