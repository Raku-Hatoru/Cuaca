import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cuaca/core/constants/api_constants.dart';
import 'package:cuaca/core/utils/date_formatter.dart';
import 'package:cuaca/core/utils/temperature_utils.dart';
import 'package:cuaca/core/utils/weather_code_mapper.dart';
import 'package:cuaca/data/models/location_model.dart';
import 'package:cuaca/data/models/weather_data.dart';
import 'package:cuaca/data/repositories/location_repository.dart';
import 'package:cuaca/data/repositories/weather_repository.dart';
import 'package:cuaca/data/services/app_exception.dart';
import 'package:cuaca/data/services/geocoding_api_service.dart';
import 'package:cuaca/data/services/local_storage_service.dart';
import 'package:cuaca/data/services/weather_api_service.dart';
import 'package:cuaca/viewmodels/search_viewmodel.dart';
import 'package:cuaca/viewmodels/weather_viewmodel.dart';

Map<String, dynamic> _sampleForecastJson() {
  return {
    'latitude': -6.2,
    'longitude': 106.8,
    'utc_offset_seconds': 25200,
    'timezone': 'Asia/Jakarta',
    'timezone_abbreviation': 'GMT+7',
    'current': {
      'time': '2026-11-25T10:00',
      'temperature_2m': 29.4,
      'relative_humidity_2m': 78,
      'apparent_temperature': 33.1,
      'precipitation': 0.4,
      'weather_code': 2,
      'wind_speed_10m': 14.2,
      'wind_direction_10m': 225,
      'surface_pressure': 1011.5,
      'dew_point_2m': 24.1,
      'is_day': 1,
    },
    'daily': {
      'time': [
        '2026-11-25',
        '2026-11-26',
        '2026-11-27',
        '2026-11-28',
        '2026-11-29',
        '2026-11-30',
        '2026-12-01',
      ],
      'weather_code': [80, 1, 2, 0, 51, 63, 1],
      'temperature_2m_max': [32.0, 31.0, 33.0, 34.0, 30.0, 29.0, 31.0],
      'temperature_2m_min': [24.0, 25.0, 24.0, 25.0, 24.0, 23.0, 24.0],
      'precipitation_probability_max': [70, 40, 20, 10, 60, 75, 30],
      'precipitation_sum': [8.5, 1.2, 0.0, 0.0, 3.4, 12.1, 0.5],
      'sunrise': [
        '2026-11-25T05:27',
        '2026-11-26T05:27',
        '2026-11-27T05:27',
        '2026-11-28T05:28',
        '2026-11-29T05:28',
        '2026-11-30T05:28',
        '2026-12-01T05:28',
      ],
      'sunset': [
        '2026-11-25T17:54',
        '2026-11-26T17:55',
        '2026-11-27T17:55',
        '2026-11-28T17:56',
        '2026-11-29T17:56',
        '2026-11-30T17:57',
        '2026-12-01T17:57',
      ],
      'uv_index_max': [8.2, 7.5, 9.0, 9.4, 5.1, 4.3, 7.8],
      'wind_speed_10m_max': [18.0, 15.0, 14.0, 12.0, 20.0, 22.0, 16.0],
    },
    'hourly': {
      'time': List.generate(
        30,
        (i) {
          final dt = DateTime(2026, 11, 25, 8).add(Duration(hours: i));
          final hh = dt.hour.toString().padLeft(2, '0');
          final dd = dt.day.toString().padLeft(2, '0');
          return '2026-11-${dd}T$hh:00';
        },
      ),
      'temperature_2m': List.generate(30, (i) => 26.0 + (i % 7)),
      'apparent_temperature': List.generate(30, (i) => 29.0 + (i % 7)),
      'precipitation_probability': List.generate(30, (i) => (i * 5) % 80),
      'precipitation': List.generate(30, (i) => i % 3 == 0 ? 0.4 : 0.0),
      'weather_code': List.generate(30, (i) => i % 2 == 0 ? 1 : 61),
      'relative_humidity_2m': List.generate(30, (i) => 70 + (i % 15)),
      'wind_speed_10m': List.generate(30, (i) => 10.0 + (i % 8)),
      'uv_index': List.generate(30, (i) => (i % 9).toDouble()),
      'is_day': List.generate(30, (i) {
        final h = (8 + i) % 24;
        return (h >= 6 && h < 18) ? 1 : 0;
      }),
    },
  };
}

void main() {
  group('WeatherCodeMapper & Utils', () {
    test('memetakan kode WMO siang dan malam dengan benar', () {
      final clearDay = WeatherCodeMapper.map(0, isDay: true);
      expect(clearDay.description, 'Cerah');
      expect(clearDay.icon, Icons.wb_sunny_outlined);

      final clearNight = WeatherCodeMapper.map(0, isDay: false);
      expect(clearNight.icon, Icons.nightlight_outlined);

      final storm = WeatherCodeMapper.map(95, isDay: true);
      expect(storm.description, 'Badai petir');
      expect(storm.icon, Icons.thunderstorm_outlined);

      final rain = WeatherCodeMapper.map(63, isDay: true);
      expect(rain.description, 'Hujan');
      expect(rain.icon, Icons.water_drop_outlined);
    });

    test('konversi suhu °C/°F dan arah angin bekerja akurat', () {
      expect(TemperatureUtils.convert(0, true), 32);
      expect(TemperatureUtils.convert(25, true), 77);
      expect(
        TemperatureUtils.format(25, toFahrenheit: false, withUnit: true),
        '25°C',
      );
      expect(
        TemperatureUtils.format(25, toFahrenheit: true, withUnit: true),
        '77°F',
      );
      expect(TemperatureUtils.windDirectionLabel(225), 'Barat Daya (SW)');
      expect(TemperatureUtils.uvCategory(2), 'Rendah');
      expect(TemperatureUtils.uvCategory(7), 'Tinggi');
    });

    test('DateFormatter memformat tanggal dan durasi berbahasa Indonesia', () {
      final date = DateTime(2026, 11, 25); // Rabu
      expect(DateFormatter.dayName(date), 'Rabu');
      expect(DateFormatter.dayAndShortDate(date, isToday: false), 'Rabu, 25 Nov');
      expect(DateFormatter.dayAndShortDate(date, isToday: true), 'Hari Ini');
      expect(
        DateFormatter.formatDurationHm(const Duration(hours: 11, minutes: 46)),
        '11 jam 46 mnt',
      );
    });
  });

  group('Model Parsing', () {
    test('LocationModel fromJson & toJson menangani field opsional', () {
      final city = LocationModel.fromJson({
        'id': 1650357,
        'name': 'Bandung',
        'latitude': -6.9222,
        'longitude': 107.6069,
        'country': 'Indonesia',
        'country_code': 'ID',
        'admin1': 'Jawa Barat',
        'timezone': 'Asia/Jakarta',
      });
      expect(city.name, 'Bandung');
      expect(city.subtitle, 'Jawa Barat, Indonesia');
      expect(city.headerLabel, 'Bandung, ID');

      final restored = LocationModel.fromJson(city.toJson());
      expect(restored, city);
    });

    test('WeatherData.fromForecastJson menggabungkan array paralel daily & hourly', () {
      final data = WeatherData.fromForecastJson(
        _sampleForecastJson(),
        location: ApiConstants.defaultLocation,
      );

      expect(data.current.temperature, 29.4);
      expect(data.current.isDay, isTrue);
      expect(data.daily.length, 7);
      expect(data.daily.first.precipitationProbabilityMax, 70);
      expect(data.hourly.length, 30);

      final next24 = data.next24Hours;
      expect(next24.length, 24);
      expect(next24.first.time, DateTime(2026, 11, 25, 10));
    });
  });

  group('Services & Repositories', () {
    test('GeocodingApiService mengembalikan daftar kosong jika key results tidak ada', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'generationtime_ms': 0.3}), 200);
      });
      final service = GeocodingApiService(client: client);
      final results = await service.searchCities('zzzzzx');
      expect(results, isEmpty);
    });

    test('GeocodingApiService mem-parsing hasil pencarian dengan benar', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 1650357,
                'name': 'Bandung',
                'latitude': -6.9222,
                'longitude': 107.6069,
                'country': 'Indonesia',
                'country_code': 'ID',
                'admin1': 'Jawa Barat',
                'timezone': 'Asia/Jakarta',
              },
            ],
          }),
          200,
        );
      });
      final service = GeocodingApiService(client: client);
      final results = await service.searchCities('Bandung');
      expect(results.length, 1);
      expect(results.first.name, 'Bandung');
    });

    test('WeatherApiService melempar AppException saat status bukan 200 atau tanpa internet', () async {
      final errorClient = MockClient(
        (request) async => http.Response('Server error', 500),
      );
      final weatherService = WeatherApiService(client: errorClient);
      expect(
        () => weatherService.fetchForecast(ApiConstants.defaultLocation),
        throwsA(isA<AppException>()),
      );

      final offlineClient = MockClient(
        (request) async => throw const SocketException('No internet'),
      );
      final offlineService = WeatherApiService(client: offlineClient);
      expect(
        () => offlineService.fetchForecast(ApiConstants.defaultLocation),
        throwsA(
          isA<AppException>().having((e) => e.isNetworkError, 'isNetworkError', true),
        ),
      );
    });

    test('LocationRepository mengelola favorit, riwayat maks 10, dan lokasi terakhir', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocationRepository(
        geocodingService: GeocodingApiService(
          client: MockClient((_) async => http.Response('{}', 200)),
        ),
        localStorageService: LocalStorageService(preferences: prefs),
      );

      expect(await repo.getInitialLocation(), ApiConstants.defaultLocation);

      const bandung = LocationModel(
        id: 1650357,
        name: 'Bandung',
        latitude: -6.92,
        longitude: 107.61,
        country: 'Indonesia',
        countryCode: 'ID',
        admin1: 'Jawa Barat',
        timezone: 'Asia/Jakarta',
      );

      await repo.saveLastLocation(bandung);
      expect((await repo.getInitialLocation()).id, bandung.id);

      final favAfterAdd = await repo.toggleFavorite(bandung);
      expect(favAfterAdd.length, 1);
      final favAfterRemove = await repo.toggleFavorite(bandung);
      expect(favAfterRemove, isEmpty);

      for (var i = 1; i <= 12; i++) {
        await repo.addToSearchHistory(
          LocationModel(
            id: i,
            name: 'Kota $i',
            latitude: 0,
            longitude: 0,
            country: 'ID',
            countryCode: 'ID',
            admin1: '',
            timezone: 'auto',
          ),
        );
      }
      final history = await repo.getSearchHistory();
      expect(history.length, 10);
      expect(history.first.id, 12);

      await repo.clearSearchHistory();
      expect(await repo.getSearchHistory(), isEmpty);
    });
  });

  group('ViewModels', () {
    test('WeatherViewModel memuat cuaca dan memperbarui state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final mockClient = MockClient((request) async {
        if (request.url.host.contains('air-quality')) {
          return http.Response(
            jsonEncode({
              'current': {'european_aqi': 42, 'us_aqi': 50, 'pm2_5': 12.0, 'pm10': 20.0},
            }),
            200,
          );
        }
        return http.Response(jsonEncode(_sampleForecastJson()), 200);
      });

      final weatherVm = WeatherViewModel(
        weatherRepository: WeatherRepository(
          apiService: WeatherApiService(client: mockClient),
        ),
        locationRepository: LocationRepository(
          geocodingService: GeocodingApiService(client: mockClient),
          localStorageService: LocalStorageService(preferences: prefs),
        ),
      );

      await weatherVm.initialize();
      expect(weatherVm.state, WeatherViewState.success);
      expect(weatherVm.weatherData?.current.temperature, 29.4);
      expect(weatherVm.weatherData?.airQuality?.europeanAqi, 42);
    });

    test('SearchViewModel melakukan debounce pencarian dan menangani kota kosong', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final mockClient = MockClient((request) async {
        if (request.url.queryParameters['name'] == 'zzzzzx') {
          return http.Response(jsonEncode({'generationtime_ms': 0.2}), 200);
        }
        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 1650357,
                'name': 'Bandung',
                'latitude': -6.92,
                'longitude': 107.6,
                'country': 'Indonesia',
                'country_code': 'ID',
                'admin1': 'Jawa Barat',
                'timezone': 'Asia/Jakarta',
              },
            ],
          }),
          200,
        );
      });

      final searchVm = SearchViewModel(
        locationRepository: LocationRepository(
          geocodingService: GeocodingApiService(client: mockClient),
          localStorageService: LocalStorageService(preferences: prefs),
        ),
        weatherRepository: WeatherRepository(
          apiService: WeatherApiService(client: mockClient),
        ),
        debounceDuration: const Duration(milliseconds: 20),
      );

      searchVm.onQueryChanged('Bandung');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(searchVm.state, SearchViewState.success);
      expect(searchVm.results.first.name, 'Bandung');

      searchVm.onQueryChanged('zzzzzx');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(searchVm.state, SearchViewState.empty);
      searchVm.dispose();
    });
  });
}
