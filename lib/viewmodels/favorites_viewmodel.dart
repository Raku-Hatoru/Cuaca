import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/location_model.dart';
import '../data/models/weather_data.dart';
import '../data/repositories/location_repository.dart';
import '../data/repositories/weather_repository.dart';

/// ViewModel untuk daftar kota favorit tersimpan dan ringkasan cuacanya.
class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel({
    required this._locationRepository,
    required this._weatherRepository,
  });

  final LocationRepository _locationRepository;
  final WeatherRepository _weatherRepository;

  List<LocationModel> _favorites = const [];
  Map<int, CityWeatherSummary> _summaries = const {};
  bool _isLoading = false;
  bool _isRefreshing = false;

  List<LocationModel> get favorites => _favorites;
  Map<int, CityWeatherSummary> get summaries => _summaries;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;

  bool isFavorite(int locationId) {
    return _favorites.any((item) => item.id == locationId);
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    _favorites = await _locationRepository.getFavorites();
    _isLoading = false;
    notifyListeners();

    await refreshWeather();
  }

  Future<void> refreshWeather() async {
    if (_favorites.isEmpty) return;
    _isRefreshing = true;
    notifyListeners();

    try {
      final fetched = await _weatherRepository.getCitySummaries(_favorites);
      _summaries = {..._summaries, ...fetched};
    } catch (_) {
      // Tetap tampilkan daftar favorit meskipun jaringan sedang offline.
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(LocationModel location) async {
    final updated = await _locationRepository.toggleFavorite(location);
    _favorites = updated;
    final nowFavorite = isFavorite(location.id);
    notifyListeners();

    if (nowFavorite && !_summaries.containsKey(location.id)) {
      unawaited(_fetchSingleSummary(location));
    }
    return nowFavorite;
  }

  Future<void> removeFavorite(int locationId) async {
    _favorites = await _locationRepository.removeFavorite(locationId);
    notifyListeners();
  }

  Future<void> _fetchSingleSummary(LocationModel location) async {
    try {
      final fetched = await _weatherRepository.getCitySummaries([location]);
      if (fetched.isNotEmpty) {
        _summaries = {..._summaries, ...fetched};
        notifyListeners();
      }
    } catch (_) {}
  }
}
