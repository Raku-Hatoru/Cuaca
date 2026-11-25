import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Informasi tampilan kondisi cuaca hasil pemetaan kode WMO Open-Meteo.
class WeatherConditionInfo {
  const WeatherConditionInfo({
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  final String description;
  final IconData icon;
  final Color iconColor;
}

/// Memetakan kode WMO Open-Meteo menjadi deskripsi Bahasa Indonesia dan ikon outline.
class WeatherCodeMapper {
  WeatherCodeMapper._();

  static WeatherConditionInfo map(int weatherCode, {bool isDay = true}) {
    switch (weatherCode) {
      case 0:
        return WeatherConditionInfo(
          description: isDay ? 'Cerah' : 'Cerah malam',
          icon: isDay ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
          iconColor: isDay ? AppColors.warning : AppColors.primary,
        );
      case 1:
        return WeatherConditionInfo(
          description: 'Cerah berawan',
          icon: isDay ? Icons.wb_cloudy_outlined : Icons.nights_stay_outlined,
          iconColor: isDay ? AppColors.primary : AppColors.secondary,
        );
      case 2:
        return WeatherConditionInfo(
          description: 'Berawan sebagian',
          icon: isDay ? Icons.wb_cloudy_outlined : Icons.nights_stay_outlined,
          iconColor: AppColors.secondary,
        );
      case 3:
        return const WeatherConditionInfo(
          description: 'Mendung',
          icon: Icons.cloud_outlined,
          iconColor: AppColors.secondary,
        );
      case 45:
      case 48:
        return const WeatherConditionInfo(
          description: 'Berkabut',
          icon: Icons.foggy,
          iconColor: AppColors.textSecondary,
        );
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return const WeatherConditionInfo(
          description: 'Gerimis',
          icon: Icons.grain,
          iconColor: AppColors.primary,
        );
      case 61:
        return const WeatherConditionInfo(
          description: 'Hujan ringan',
          icon: Icons.water_drop_outlined,
          iconColor: AppColors.primary,
        );
      case 63:
        return const WeatherConditionInfo(
          description: 'Hujan',
          icon: Icons.water_drop_outlined,
          iconColor: AppColors.primaryContainer,
        );
      case 65:
      case 66:
      case 67:
        return const WeatherConditionInfo(
          description: 'Hujan lebat',
          icon: Icons.umbrella_outlined,
          iconColor: AppColors.primaryContainer,
        );
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return const WeatherConditionInfo(
          description: 'Salju',
          icon: Icons.ac_unit,
          iconColor: AppColors.textPrimary,
        );
      case 80:
      case 81:
      case 82:
        return const WeatherConditionInfo(
          description: 'Hujan lebat sesaat',
          icon: Icons.thunderstorm_outlined,
          iconColor: AppColors.primaryContainer,
        );
      case 95:
      case 96:
      case 99:
        return const WeatherConditionInfo(
          description: 'Badai petir',
          icon: Icons.thunderstorm_outlined,
          iconColor: AppColors.warning,
        );
      default:
        return WeatherConditionInfo(
          description: 'Berawan',
          icon: isDay ? Icons.cloud_queue_outlined : Icons.nights_stay_outlined,
          iconColor: AppColors.secondary,
        );
    }
  }
}
