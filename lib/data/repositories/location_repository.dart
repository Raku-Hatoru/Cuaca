import '../../core/constants/api_constants.dart';
import '../models/location_model.dart';
import '../services/geocoding_api_service.dart';
import '../services/local_storage_service.dart';

/// Repository pengelolaan pencarian kota, favorit, riwayat, dan preferensi lokasi.
class LocationRepository {
  LocationRepository({
    required this._geocodingService,
    required this._localStorageService,
  });

  final GeocodingApiService _geocodingService;
  final LocalStorageService _localStorageService;

  Future<List<LocationModel>> searchCities(String query) {
    return _geocodingService.searchCities(query);
  }

  Future<LocationModel> getInitialLocation() async {
    final saved = await _localStorageService.getLastLocation();
    return saved ?? ApiConstants.defaultLocation;
  }

  Future<void> saveLastLocation(LocationModel location) {
    return _localStorageService.saveLastLocation(location);
  }

  Future<List<LocationModel>> getFavorites() {
    return _localStorageService.getFavorites();
  }

  Future<List<LocationModel>> toggleFavorite(LocationModel location) async {
    final current = List<LocationModel>.from(
      await _localStorageService.getFavorites(),
    );
    final existingIndex = current.indexWhere((item) => item.id == location.id);
    if (existingIndex >= 0) {
      current.removeAt(existingIndex);
    } else {
      current.insert(0, location);
    }
    await _localStorageService.saveFavorites(current);
    return current;
  }

  Future<List<LocationModel>> removeFavorite(int locationId) async {
    final current = List<LocationModel>.from(
      await _localStorageService.getFavorites(),
    );
    current.removeWhere((item) => item.id == locationId);
    await _localStorageService.saveFavorites(current);
    return current;
  }

  Future<List<LocationModel>> getSearchHistory() {
    return _localStorageService.getSearchHistory();
  }

  Future<List<LocationModel>> addToSearchHistory(LocationModel location) async {
    final current = List<LocationModel>.from(
      await _localStorageService.getSearchHistory(),
    );
    current.removeWhere((item) => item.id == location.id);
    current.insert(0, location);
    if (current.length > ApiConstants.maxSearchHistory) {
      current.removeRange(ApiConstants.maxSearchHistory, current.length);
    }
    await _localStorageService.saveSearchHistory(current);
    return current;
  }

  Future<List<LocationModel>> removeHistoryItem(int locationId) async {
    final current = List<LocationModel>.from(
      await _localStorageService.getSearchHistory(),
    );
    current.removeWhere((item) => item.id == locationId);
    await _localStorageService.saveSearchHistory(current);
    return current;
  }

  Future<void> clearSearchHistory() {
    return _localStorageService.saveSearchHistory(const []);
  }

  Future<bool> getUseFahrenheit() => _localStorageService.getUseFahrenheit();

  Future<void> saveUseFahrenheit(bool value) {
    return _localStorageService.saveUseFahrenheit(value);
  }
}
