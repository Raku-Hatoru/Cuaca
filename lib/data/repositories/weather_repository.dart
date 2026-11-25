import '../models/air_quality_data.dart';
import '../models/location_model.dart';
import '../models/weather_data.dart';
import '../services/weather_api_service.dart';

/// Repository yang menggabungkan data prakiraan cuaca dan kualitas udara Open-Meteo.
class WeatherRepository {
  WeatherRepository({required this._apiService});

  final WeatherApiService _apiService;

  Future<WeatherData> getWeatherForLocation(LocationModel location) async {
    final forecastFuture = _apiService.fetchForecast(location);
    final airQualityFuture = _tryFetchAirQuality(
      location.latitude,
      location.longitude,
    );

    final forecast = await forecastFuture;
    final airQuality = await airQualityFuture;
    return forecast.copyWith(airQuality: airQuality);
  }

  Future<Map<int, CityWeatherSummary>> getCitySummaries(
    List<LocationModel> locations,
  ) async {
    return _apiService.fetchCitySummaries(locations);
  }

  Future<AirQualityData?> _tryFetchAirQuality(
    double latitude,
    double longitude,
  ) async {
    try {
      return await _apiService.fetchAirQuality(latitude, longitude);
    } catch (_) {
      // Kualitas udara bersifat pelengkap; kegagalan AQI tidak menggagalkan prakiraan utama.
      return null;
    }
  }
}
