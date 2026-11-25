import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../models/location_model.dart';

/// Service penyimpanan lokal menggunakan SharedPreferences untuk favorit, riwayat, dan lokasi terakhir.
class LocalStorageService {
  LocalStorageService({this._preferences});

  SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await _prefs();
    return _decodeLocationList(prefs.getString(ApiConstants.favoritesKey));
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await _prefs();
    final encoded = jsonEncode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString(ApiConstants.favoritesKey, encoded);
  }

  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await _prefs();
    return _decodeLocationList(prefs.getString(ApiConstants.searchHistoryKey));
  }

  Future<void> saveSearchHistory(List<LocationModel> history) async {
    final prefs = await _prefs();
    final encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(ApiConstants.searchHistoryKey, encoded);
  }

  Future<LocationModel?> getLastLocation() async {
    final prefs = await _prefs();
    final raw = prefs.getString(ApiConstants.lastLocationKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return LocationModel.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await _prefs();
    await prefs.setString(
      ApiConstants.lastLocationKey,
      jsonEncode(location.toJson()),
    );
  }

  Future<bool> getUseFahrenheit() async {
    final prefs = await _prefs();
    return prefs.getBool(ApiConstants.useFahrenheitKey) ?? false;
  }

  Future<void> saveUseFahrenheit(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(ApiConstants.useFahrenheitKey, value);
  }

  List<LocationModel> _decodeLocationList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
