import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/temperature_utils.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/air_quality_data.dart';
import '../../data/models/hourly_forecast.dart';

/// Menampilkan bottom sheet rincian cuaca untuk satu jam terpilih.
Future<void> showHourDetailSheet(
  BuildContext context, {
  required HourlyForecast hour,
  required bool isCurrentHour,
  required bool isFahrenheit,
  AirQualityData? airQuality,
}) {
  final condition = WeatherCodeMapper.map(
    hour.weatherCode,
    isDay: hour.isDay,
  );
  final tempText = TemperatureUtils.format(
    hour.temperature,
    toFahrenheit: isFahrenheit,
  );
  final apparentText = TemperatureUtils.format(
    hour.apparentTemperature,
    toFahrenheit: isFahrenheit,
  );
  final dayText = DateFormatter.dayName(hour.time);
  final timeText = DateFormatter.formatHourCompact(hour.time);

  final advice = _buildHourlyAdvice(hour, isFahrenheit);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainerHigh,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pegangan modal
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              // Header waktu, kondisi, dan suhu
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      condition.icon,
                      color: condition.iconColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '$timeText, $dayText',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isCurrentHour ? 'Aktif' : 'Prakiraan',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${condition.description} • Angin ${hour.windSpeed.round()} km/j',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tempText,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Terasa $apparentText',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Grid 4 metrik rinci
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _DetailTile(
                        icon: Icons.air_rounded,
                        iconColor: AppColors.primary,
                        label: 'KECEPATAN ANGIN',
                        value: '${hour.windSpeed.round()} km/j',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DetailTile(
                        icon: Icons.water_drop_outlined,
                        iconColor: AppColors.primary,
                        label: 'KELEMBAPAN',
                        value: '${hour.relativeHumidity}%',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _DetailTile(
                        icon: airQuality != null
                            ? Icons.waves_rounded
                            : Icons.wb_sunny_outlined,
                        iconColor: AppColors.warning,
                        label: airQuality != null
                            ? 'KUALITAS UDARA'
                            : 'INDEKS UV',
                        value: airQuality != null
                            ? '${airQuality.europeanAqi} ${TemperatureUtils.aqiCategory(airQuality.europeanAqi)}'
                            : '${hour.uvIndex.toStringAsFixed(1)} ${TemperatureUtils.uvCategory(hour.uvIndex)}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DetailTile(
                        icon: Icons.umbrella_outlined,
                        iconColor: AppColors.primary,
                        label: 'HUJAN / JAM',
                        value:
                            '${hour.precipitation.toStringAsFixed(1)} mm (${hour.precipitationProbability}%)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Saran aktivitas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        advice,
                        style: const TextStyle(
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

String _buildHourlyAdvice(HourlyForecast hour, bool isFahrenheit) {
  if (hour.precipitationProbability >= 60 || hour.precipitation >= 1.0) {
    return 'Peluang hujan tinggi (${hour.precipitationProbability}%). Siapkan payung atau jas hujan saat bepergian.';
  }
  if (hour.uvIndex >= 6) {
    return 'Indeks UV tinggi (${hour.uvIndex.toStringAsFixed(1)}). Gunakan tabir surya dan pelindung mata di luar ruangan.';
  }
  if (hour.temperature >= 32) {
    final feels = TemperatureUtils.format(
      hour.apparentTemperature,
      toFahrenheit: isFahrenheit,
      withUnit: true,
    );
    return 'Cuaca cukup terik dengan suhu terasa $feels. Jaga hidrasi dengan minum air yang cukup.';
  }
  if (!hour.isDay) {
    return 'Udara malam cenderung sejuk dan nyaman untuk beristirahat.';
  }
  return 'Kondisi cuaca mendukung untuk beraktivitas di luar ruangan.';
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
