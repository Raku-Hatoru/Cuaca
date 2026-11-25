import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../data/models/location_model.dart';
import '../data/models/weather_data.dart';
import '../data/repositories/location_repository.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/app_exception.dart';

enum SearchViewState { initial, loading, success, empty, error }

/// ViewModel untuk layar Cari & Kelola Lokasi (pencarian Geocoding, riwayat, dan kota populer).
class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required this._locationRepository,
    required this._weatherRepository,
    this._debounceDuration = const Duration(milliseconds: 500),
  });

  final LocationRepository _locationRepository;
  final WeatherRepository _weatherRepository;
  final Duration _debounceDuration;

  SearchViewState _state = SearchViewState.initial;
  String _query = '';
  List<LocationModel> _results = const [];
  List<LocationModel> _history = const [];
  Map<int, CityWeatherSummary> _citySummaries = const {};
  bool _isLoadingSummaries = false;
  String? _errorMessage;
  bool _isNetworkError = false;
  Timer? _debounce;
  int _searchToken = 0;

  SearchViewState get state => _state;
  String get query => _query;
  List<LocationModel> get results => _results;
  List<LocationModel> get history => _history;
  Map<int, CityWeatherSummary> get citySummaries => _citySummaries;
  bool get isLoadingSummaries => _isLoadingSummaries;
  String? get errorMessage => _errorMessage;
  bool get isNetworkError => _isNetworkError;
  bool get isSearching => _query.trim().length >= 2;

  Future<void> initialize() async {
    _history = await _locationRepository.getSearchHistory();
    notifyListeners();
    await refreshCitySummaries();
  }

  Future<void> refreshCitySummaries() async {
    final targets = <LocationModel>[
      ...ApiConstants.popularCities,
      ..._history,
    ];
    final uniqueById = <int, LocationModel>{
      for (final city in targets) city.id: city,
    }.values.toList();

    if (uniqueById.isEmpty) return;

    _isLoadingSummaries = true;
    notifyListeners();

    try {
      final fetched = await _weatherRepository.getCitySummaries(uniqueById);
      _citySummaries = {..._citySummaries, ...fetched};
    } catch (_) {
      // Abaikan kegagalan ringkasan cuaca kota populer agar layar cari tetap responsif.
    } finally {
      _isLoadingSummaries = false;
      notifyListeners();
    }
  }

  void onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      _searchToken++;
      _results = const [];
      _errorMessage = null;
      _isNetworkError = false;
      _state = SearchViewState.initial;
      notifyListeners();
      return;
    }

    _state = SearchViewState.loading;
    _errorMessage = null;
    notifyListeners();

    _debounce = Timer(_debounceDuration, () {
      _performSearch(trimmed);
    });
  }

  Future<void> searchNow([String? overrideQuery]) async {
    _debounce?.cancel();
    final target = (overrideQuery ?? _query).trim();
    _query = overrideQuery ?? _query;
    if (target.length < 2) {
      _state = SearchViewState.initial;
      _results = const [];
      notifyListeners();
      return;
    }
    await _performSearch(target);
  }

  Future<void> _performSearch(String trimmedQuery) async {
    final token = ++_searchToken;
    _state = SearchViewState.loading;
    _errorMessage = null;
    _isNetworkError = false;
    notifyListeners();

    try {
      final locations = await _locationRepository.searchCities(trimmedQuery);
      if (token != _searchToken) return;

      _results = locations;
      if (locations.isEmpty) {
        _state = SearchViewState.empty;
      } else {
        _state = SearchViewState.success;
      }
    } on AppException catch (e) {
      if (token != _searchToken) return;
      _results = const [];
      _errorMessage = e.message;
      _isNetworkError = e.isNetworkError;
      _state = SearchViewState.error;
    } catch (_) {
      if (token != _searchToken) return;
      _results = const [];
      _errorMessage = 'Gagal memuat hasil pencarian kota';
      _isNetworkError = false;
      _state = SearchViewState.error;
    }
    notifyListeners();
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchToken++;
    _query = '';
    _results = const [];
    _errorMessage = null;
    _isNetworkError = false;
    _state = SearchViewState.initial;
    notifyListeners();
  }

  Future<void> addHistory(LocationModel location) async {
    _history = await _locationRepository.addToSearchHistory(location);
    notifyListeners();
    unawaited(_fetchSingleSummaryIfMissing(location));
  }

  Future<void> _fetchSingleSummaryIfMissing(LocationModel location) async {
    if (_citySummaries.containsKey(location.id)) return;
    try {
      final summary = await _weatherRepository.getCitySummaries([location]);
      if (summary.isNotEmpty) {
        _citySummaries = {..._citySummaries, ...summary};
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> removeHistoryItem(int locationId) async {
    _history = await _locationRepository.removeHistoryItem(locationId);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _locationRepository.clearSearchHistory();
    _history = const [];
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
