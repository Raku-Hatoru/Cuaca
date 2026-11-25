# Cuaca Open-Meteo (Flutter + MVVM)

Aplikasi mobile prakiraan cuaca berbasis **Flutter** dan **Dart** dengan arsitektur **MVVM (Model – View – ViewModel)**, state management **Provider (`ChangeNotifier`)**, penyimpanan lokal **`shared_preferences`**, serta data cuaca dan pencarian lokasi real-time dari **Open-Meteo API** tanpa API key.

Tampilan mengikuti desain **Nocturne Celestial Weather** (`stitch_mobile_floating_notch_app`): tema malam biru tua (`#071433` → `#0B1F5C`), tipografi **Manrope**, lingkaran hero suhu bercahaya elektrik, kurva siklus matahari, dan **tab bar floating dengan notch** di tengah.

## Fitur Utama

- **Hari Ini (`HomeScreen`)**:
  - Lingkaran hero suhu terkini, kondisi WMO (ikon siang/malam), suhu terasa (*apparent temperature*), dan tombol pintas *Cuaca Mendatang →*.
  - Ringkasan 3 kolom hari ini (Terendah, Peluang Hujan, Tertinggi).
  - Detail Hari Ini: Durasi Siang/Malam, kurva **Siklus Matahari**, Kelembapan & Titik Embun, Kecepatan & Arah Angin, Peluang & Curah Hujan, Indeks UV, Tekanan Udara, dan Kualitas Udara (AQI).
  - Pratinjau prakiraan 7 hari ke depan dan *pull-to-refresh*.
- **Per Jam (`HourlyScreen`)**:
  - Prakiraan 24 jam ke depan dari waktu lokal kota, penanda jam berjalan, pemisah matahari terbit/terbenam, toggle satuan **°C / °F**, grafik tren suhu, serta *bottom sheet* detail per jam saat diketuk.
- **Cari & Kelola Lokasi (`SearchScreen`)**:
  - Pencarian kota real-time via **Open-Meteo Geocoding API** dengan debounce 500 ms (minimal 2 karakter).
  - Penanganan state loading, kota tidak ditemukan, dan error jaringan + tombol coba lagi.
  - Riwayat pencarian tersimpan lokal (maksimal 10 kota tanpa duplikat) dan daftar Kota Populer dengan data cuaca langsung dari API.
- **Harian (`DailyScreen`)**:
  - Ringkasan mingguan dan prakiraan 7 hari rinci lengkap dengan bilah rentang suhu min–maks proporsional serta *bottom sheet* detail per jam tiap hari.
- **Favorit (`FavoritesScreen`)**:
  - Daftar lokasi favorit persisten di penyimpanan lokal dengan suhu terkini, badge lokasi aktif, dan hapus favorit.

## Arsitektur MVVM

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/   (api_constants.dart, app_colors.dart)
│   ├── theme/       (app_theme.dart)
│   └── utils/       (app_snackbar.dart, date_formatter.dart, temperature_utils.dart, weather_code_mapper.dart)
├── data/
│   ├── models/      (air_quality_data.dart, current_weather.dart, daily_forecast.dart, hourly_forecast.dart, location_model.dart, weather_data.dart)
│   ├── services/    (app_exception.dart, geocoding_api_service.dart, local_storage_service.dart, weather_api_service.dart)
│   └── repositories/(location_repository.dart, weather_repository.dart)
├── viewmodels/      (favorites_viewmodel.dart, search_viewmodel.dart, weather_viewmodel.dart)
└── views/
    ├── screens/     (main_shell.dart, home_screen.dart, hourly_screen.dart, daily_screen.dart, search_screen.dart, favorites_screen.dart)
    └── widgets/     (floating_notch_nav_bar.dart, weather_ring.dart, sun_cycle_card.dart, forecast_tile.dart, ...)
```

**Alur data:** `View` → aksi pengguna → `ViewModel` (`ChangeNotifier`) → `Repository` → `Service` (`HTTP GET` / `SharedPreferences`) → `Model` → `ViewModel.notifyListeners()` → `View` rebuild.

## Endpoint API Open-Meteo

- **Geocoding API**: `https://geocoding-api.open-meteo.com/v1/search?name={kota}&count=10&language=id&format=json`
- **Forecast API**: `https://api.open-meteo.com/v1/forecast` (`current`, `daily`, `hourly`, `timezone=auto`, `forecast_days=7`)
- **Air Quality API**: `https://air-quality-api.open-meteo.com/v1/air-quality` (`european_aqi`, `us_aqi`, `pm2_5`, `pm10`)

## Cara Menjalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
