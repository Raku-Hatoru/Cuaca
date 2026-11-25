import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/floating_notch_nav_bar.dart';
import '../widgets/top_location_bar.dart';
import 'daily_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'hourly_screen.dart';
import 'search_screen.dart';

/// Kerangka navigasi utama dengan latar malam berbintang, header lokasi, dan tab bar notch.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _toggleCurrentFavorite() async {
    final weatherVm = context.read<WeatherViewModel>();
    final favVm = context.read<FavoritesViewModel>();
    final location = weatherVm.activeLocation;
    final added = await favVm.toggleFavorite(location);
    if (!mounted) return;
    showAppSnackBar(
      context,
      added
          ? '${location.name} disimpan ke Favorit'
          : '${location.name} dihapus dari Favorit',
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final weatherVm = sheetContext.watch<WeatherViewModel>();
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Pengaturan Tampilan Cuaca',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Satuan Suhu',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Pilih Celcius (°C) atau Fahrenheit (°F)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(value: false, label: Text('°C')),
                          ButtonSegment<bool>(value: true, label: Text('°F')),
                        ],
                        selected: {weatherVm.isFahrenheit},
                        onSelectionChanged: (values) {
                          weatherVm.setFahrenheit(values.first);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.cloud_done_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sumber data real-time: Open-Meteo Forecast, Geocoding & Air Quality API (tanpa API key).',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMenuSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Navigasi Cepat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _QuickNavTile(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Hari Ini',
                  subtitle: 'Ringkasan cuaca terkini & detail metrik',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _selectTab(0);
                  },
                ),
                _QuickNavTile(
                  icon: Icons.schedule_outlined,
                  title: 'Prakiraan Per Jam',
                  subtitle: 'Garis waktu 24 jam & rincian tiap jam',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _selectTab(1);
                  },
                ),
                _QuickNavTile(
                  icon: Icons.search_rounded,
                  title: 'Cari & Kelola Lokasi',
                  subtitle: 'Open-Meteo Geocoding & riwayat pencarian',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _selectTab(2);
                  },
                ),
                _QuickNavTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Prakiraan 7 Hari',
                  subtitle: 'Rentang suhu mingguan & detail harian',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _selectTab(3);
                  },
                ),
                _QuickNavTile(
                  icon: Icons.star_outline_rounded,
                  title: 'Kota Favorit',
                  subtitle: 'Lokasi tersimpan secara lokal',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _selectTab(4);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final favVm = context.watch<FavoritesViewModel>();
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 80;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            // Latar belakang gradien biru malam + cahaya ambient elektrik
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundTop,
                    AppColors.backgroundBottom,
                    AppColors.surface,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    top: -90,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.electricGlow.withValues(alpha: 0.34),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 260,
                    right: -80,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondaryContainer.withValues(alpha: 0.22),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Konten utama layar
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  TopLocationBar(
                    location: weatherVm.activeLocation,
                    isFavorite: favVm.isFavorite(weatherVm.activeLocation.id),
                    isFahrenheit: weatherVm.isFahrenheit,
                    onTapLocation: () => _selectTab(2),
                    onToggleFavorite: _toggleCurrentFavorite,
                    onTapMenu: _openMenuSheet,
                    onTapSettings: _openSettingsSheet,
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        HomeScreen(
                          onNavigateTab: _selectTab,
                          onOpenSettings: _openSettingsSheet,
                        ),
                        const HourlyScreen(),
                        SearchScreen(
                          onLocationSelected: () => _selectTab(0),
                        ),
                        const DailyScreen(),
                        FavoritesScreen(
                          onOpenSearch: () => _selectTab(2),
                          onLocationSelected: () => _selectTab(0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab bar floating dengan notch (disembunyikan saat keyboard terbuka)
            if (!isKeyboardOpen)
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingNotchNavBar(
                  currentIndex: _currentIndex,
                  onSelectTab: _selectTab,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickNavTile extends StatelessWidget {
  const _QuickNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
    );
  }
}
