import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/utils/temperature_utils.dart';
import '../data/models/location_model.dart';
import '../data/models/weather_data.dart';
import '../data/repositories/location_repository.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/app_exception.dart';

enum WeatherViewState { initial, loading, success, error }

/// ViewModel utama untuk mengelola lokasi aktif, data cuaca terkini, dan satuan suhu.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({
    required this._weatherRepository,
    required this._locationRepository,
  });

  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;

  WeatherViewState _state = WeatherViewState.initial;
  WeatherData? _weatherData;
  LocationModel _activeLocation = ApiConstants.defaultLocation;
  String? _errorMessage;
  bool _isNetworkError = false;
  bool _isFahrenheit = false;
  int _loadToken = 0;

  WeatherViewState get state => _state;
  WeatherData? get weatherData => _weatherData;
  LocationModel get activeLocation => _activeLocation;
  String? get errorMessage => _errorMessage;
  bool get isNetworkError => _isNetworkError;
  bool get isFahrenheit => _isFahrenheit;
  bool get isLoading => _state == WeatherViewState.loading;

  Future<void> initialize() async {
    _isFahrenheit = await _locationRepository.getUseFahrenheit();
    _activeLocation = await _locationRepository.getInitialLocation();
    notifyListeners();
    await loadWeather();
  }

  Future<void> loadWeather({bool showLoading = true}) async {
    final token = ++_loadToken;
    if (showLoading || _weatherData == null) {
      _state = WeatherViewState.loading;
      _errorMessage = null;
      _isNetworkError = false;
      notifyListeners();
    }

    try {
      final data = await _weatherRepository.getWeatherForLocation(
        _activeLocation,
      );
      if (token != _loadToken) return;
      _weatherData = data;
      _state = WeatherViewState.success;
      _errorMessage = null;
      _isNetworkError = false;
    } on AppException catch (e) {
      if (token != _loadToken) return;
      _errorMessage = e.message;
      _isNetworkError = e.isNetworkError;
      _state = WeatherViewState.error;
    } catch (_) {
      if (token != _loadToken) return;
      _errorMessage = 'Gagal memuat data cuaca';
      _isNetworkError = false;
      _state = WeatherViewState.error;
    }
    notifyListeners();
  }

  Future<void> selectLocation(LocationModel location) async {
    _activeLocation = location;
    _weatherData = null;
    await _locationRepository.saveLastLocation(location);
    await loadWeather(showLoading: true);
  }

  Future<void> setFahrenheit(bool useFahrenheit) async {
    if (_isFahrenheit == useFahrenheit) return;
    _isFahrenheit = useFahrenheit;
    notifyListeners();
    await _locationRepository.saveUseFahrenheit(useFahrenheit);
  }

  String formatTemp(double celsius, {bool withUnit = false}) {
    return TemperatureUtils.format(
      celsius,
      toFahrenheit: _isFahrenheit,
      withUnit: withUnit,
    );
  }

  double convertTemp(double celsius) {
    return TemperatureUtils.convert(celsius, _isFahrenheit);
  }
}
