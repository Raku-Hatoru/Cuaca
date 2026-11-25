import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cuaca/app.dart';
import 'package:cuaca/data/repositories/location_repository.dart';
import 'package:cuaca/data/repositories/weather_repository.dart';
import 'package:cuaca/data/services/geocoding_api_service.dart';
import 'package:cuaca/data/services/local_storage_service.dart';
import 'package:cuaca/data/services/weather_api_service.dart';
import 'package:cuaca/views/screens/favorites_screen.dart';
import 'package:cuaca/views/screens/search_screen.dart';
import 'package:cuaca/views/widgets/floating_notch_nav_bar.dart';

Map<String, dynamic> _forecastPayload({double baseTemp = 29.0}) {
  return {
    'latitude': -6.2,
    'longitude': 106.8,
    'utc_offset_seconds': 25200,
    'timezone': 'Asia/Jakarta',
    'timezone_abbreviation': 'GMT+7',
    'current': {
      'time': '2026-11-25T10:00',
      'temperature_2m': baseTemp,
      'relative_humidity_2m': 80,
      'apparent_temperature': baseTemp + 3.0,
      'precipitation': 0.5,
      'weather_code': 1,
      'wind_speed_10m': 12.0,
      'wind_direction_10m': 180,
      'surface_pressure': 1012.0,
      'dew_point_2m': 24.0,
      'is_day': 1,
    },
    'daily': {
      'time': List.generate(
        7,
        (i) => '2026-11-${(25 + i).toString().padLeft(2, '0')}',
      ),
      'weather_code': [1, 2, 3, 61, 80, 0, 1],
      'temperature_2m_max': [32.0, 31.0, 33.0, 30.0, 29.0, 34.0, 31.0],
      'temperature_2m_min': [24.0, 25.0, 24.0, 23.0, 23.0, 25.0, 24.0],
      'precipitation_probability_max': [35, 40, 20, 75, 80, 10, 30],
      'precipitation_sum': [1.0, 0.5, 0.0, 12.0, 15.0, 0.0, 0.5],
      'sunrise': List.generate(
        7,
        (i) => '2026-11-${(25 + i).toString().padLeft(2, '0')}T05:30',
      ),
      'sunset': List.generate(
        7,
        (i) => '2026-11-${(25 + i).toString().padLeft(2, '0')}T17:55',
      ),
      'uv_index_max': [7.0, 6.5, 5.0, 4.0, 3.0, 8.5, 7.0],
      'wind_speed_10m_max': [15.0, 14.0, 13.0, 20.0, 22.0, 12.0, 14.0],
    },
    'hourly': {
      'time': List.generate(26, (i) {
        final dt = DateTime(2026, 11, 25, 10).add(Duration(hours: i));
        final hh = dt.hour.toString().padLeft(2, '0');
        final dd = dt.day.toString().padLeft(2, '0');
        return '2026-11-${dd}T$hh:00';
      }),
      'temperature_2m': List.generate(26, (i) => baseTemp - 2 + (i % 6)),
      'apparent_temperature': List.generate(26, (i) => baseTemp + 1 + (i % 6)),
      'precipitation_probability': List.generate(26, (i) => (i * 5) % 70),
      'precipitation': List.generate(26, (i) => i % 4 == 0 ? 0.2 : 0.0),
      'weather_code': List.generate(26, (i) => 1),
      'relative_humidity_2m': List.generate(26, (i) => 75),
      'wind_speed_10m': List.generate(26, (i) => 12.0),
      'uv_index': List.generate(26, (i) => 3.0),
      'is_day': List.generate(26, (i) => ((10 + i) % 24) < 18 && ((10 + i) % 24) >= 6 ? 1 : 0),
    },
  };
}

Future<CuacaApp> _buildTestApp({bool simulateOffline = false}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final mockClient = MockClient((request) async {
    if (simulateOffline) {
      throw const SocketException('Offline');
    }

    if (request.url.host.contains('geocoding-api')) {
      final query = request.url.queryParameters['name'] ?? '';
      if (query.toLowerCase().contains('zzzz')) {
        return http.Response(jsonEncode({'generationtime_ms': 0.2}), 200);
      }
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
    }

    if (request.url.host.contains('air-quality-api')) {
      return http.Response(
        jsonEncode({
          'current': {'european_aqi': 45, 'us_aqi': 52, 'pm2_5': 11.2, 'pm10': 18.4},
        }),
        200,
      );
    }

    final latParam = request.url.queryParameters['latitude'] ?? '';
    if (latParam.contains(',')) {
      final count = latParam.split(',').length;
      return http.Response(
        jsonEncode(List.generate(count, (_) => _forecastPayload(baseTemp: 24.0))),
        200,
      );
    }

    final isBandung = latParam.startsWith('-6.92');
    return http.Response(
      jsonEncode(_forecastPayload(baseTemp: isBandung ? 22.0 : 29.0)),
      200,
    );
  });

  return CuacaApp(
    weatherRepositoryOverride: WeatherRepository(
      apiService: WeatherApiService(client: mockClient),
    ),
    locationRepositoryOverride: LocationRepository(
      geocodingService: GeocodingApiService(client: mockClient),
      localStorageService: LocalStorageService(preferences: prefs),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Alur utama: tampilkan cuaca Jakarta, pindah tab, cari kota, dan kelola favorit', (
    tester,
  ) async {
    final app = await _buildTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Tab Hari Ini memuat Jakarta & data dari API
    expect(find.text('Jakarta, ID'), findsOneWidget);
    expect(find.text('29'), findsOneWidget);
    expect(find.text('Detail Hari Ini'), findsOneWidget);
    expect(find.text('Prakiraan 7 Hari'), findsWidgets);

    // Pindah ke tab Per Jam
    await tester.tap(find.text('Per Jam'));
    await tester.pumpAndSettle();
    expect(find.text('Hari ini, 24 Jam'), findsOneWidget);

    // Ketuk baris jam pertama untuk membuka bottom sheet detail jam
    await tester.tap(find.text('10:00').first);
    await tester.pumpAndSettle();
    expect(find.text('KECEPATAN ANGIN'), findsOneWidget);
    Navigator.of(tester.element(find.text('KECEPATAN ANGIN'))).pop();
    await tester.pumpAndSettle();

    // Ubah satuan suhu ke °F lalu kembalikan ke °C
    await tester.tap(find.text('°F').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('°C').last);
    await tester.pumpAndSettle();

    // Pindah ke tab Harian
    await tester.tap(find.text('Harian'));
    await tester.pumpAndSettle();
    expect(find.text('RINGKASAN MINGGUAN'), findsOneWidget);

    // Buka layar Cari melalui tombol tengah notch
    await tester.tap(
      find.descendant(
        of: find.byType(FloatingNotchNavBar),
        matching: find.byIcon(Icons.search_rounded),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kota Populer'), findsOneWidget);

    // Uji pencarian kosong (zzzzz) -> tampil 'Kota tidak ditemukan'
    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Kota tidak ditemukan'), findsOneWidget);

    // Ketik Bandung dan tunggu debounce pencarian
    await tester.enterText(find.byType(TextField), 'Bandung');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('HASIL GEOCODING (OPEN-METEO)'), findsOneWidget);

    // Bintangi Bandung di dalam hasil pencarian
    await tester.tap(
      find.descendant(
        of: find.byType(SearchScreen),
        matching: find.byIcon(Icons.star_outline_rounded),
      ),
    );
    await tester.pumpAndSettle();

    // Pilih Bandung dari hasil pencarian -> kembali ke Hari Ini dengan suhu baru (22°)
    await tester.tap(
      find.descendant(
        of: find.byType(SearchScreen),
        matching: find.text('Bandung'),
      ).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Bandung, ID'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);

    // Cek tab Favorit berisi Bandung lalu hapus favorit
    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Kota Favorit'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FavoritesScreen),
        matching: find.text('Bandung'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(FavoritesScreen),
        matching: find.byIcon(Icons.delete_outline_rounded),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum Ada Kota Favorit'), findsOneWidget);
  });

  testWidgets('State error tampil tanpa crash saat jaringan gagal', (tester) async {
    final app = await _buildTestApp(simulateOffline: true);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada koneksi internet'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('Responsif pada layar sempit dengan skala font besar tanpa overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = await _buildTestApp();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: app,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
