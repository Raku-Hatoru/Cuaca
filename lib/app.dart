import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/location_repository.dart';
import 'data/repositories/weather_repository.dart';
import 'data/services/geocoding_api_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/weather_api_service.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/screens/main_shell.dart';

/// Root widget aplikasi Cuaca dengan injeksi dependensi MVVM melalui Provider.
class CuacaApp extends StatelessWidget {
  const CuacaApp({
    super.key,
    this.weatherRepositoryOverride,
    this.locationRepositoryOverride,
    this.autoInitialize = true,
  });

  final WeatherRepository? weatherRepositoryOverride;
  final LocationRepository? locationRepositoryOverride;
  final bool autoInitialize;

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();
    final weatherRepo =
        weatherRepositoryOverride ??
        WeatherRepository(
          apiService: WeatherApiService(client: httpClient),
        );
    final locationRepo =
        locationRepositoryOverride ??
        LocationRepository(
          geocodingService: GeocodingApiService(client: httpClient),
          localStorageService: LocalStorageService(),
        );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) {
            final vm = WeatherViewModel(
              weatherRepository: weatherRepo,
              locationRepository: locationRepo,
            );
            if (autoInitialize) {
              vm.initialize();
            }
            return vm;
          },
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) {
            final vm = SearchViewModel(
              locationRepository: locationRepo,
              weatherRepository: weatherRepo,
            );
            if (autoInitialize) {
              vm.initialize();
            }
            return vm;
          },
        ),
        ChangeNotifierProvider<FavoritesViewModel>(
          create: (_) {
            final vm = FavoritesViewModel(
              locationRepository: locationRepo,
              weatherRepository: weatherRepo,
            );
            if (autoInitialize) {
              vm.loadFavorites();
            }
            return vm;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Cuaca Open-Meteo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainShell(),
      ),
    );
  }
}
