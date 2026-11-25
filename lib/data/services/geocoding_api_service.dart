import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/location_model.dart';
import 'app_exception.dart';

/// Service HTTP GET untuk pencarian kota menggunakan Open-Meteo Geocoding API.
class GeocodingApiService {
  GeocodingApiService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<LocationModel>> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    final uri = ApiConstants.geocodingUri(trimmed);

    try {
      final response = await _client
          .get(uri)
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw const AppException('Gagal memuat hasil pencarian kota');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AppException('Gagal memuat hasil pencarian kota');
      }

      // Open-Meteo tidak menyertakan key `results` jika kota tidak ditemukan.
      final rawResults = decoded['results'];
      if (rawResults == null || rawResults is! List) {
        return const [];
      }

      return rawResults
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList(growable: false);
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
      throw const AppException('Gagal memuat hasil pencarian kota');
    }
  }
}
