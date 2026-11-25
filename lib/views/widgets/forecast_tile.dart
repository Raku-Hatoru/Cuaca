import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/temperature_utils.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/daily_forecast.dart';
import 'glass_card.dart';

/// Baris ringkas prakiraan harian (untuk daftar 5-7 hari pada layar Hari Ini).
class ForecastTile extends StatelessWidget {
  const ForecastTile({
    super.key,
    required this.day,
    required this.isToday,
    required this.isFahrenheit,
    this.onTap,
  });

  final DailyForecast day;
  final bool isToday;
  final bool isFahrenheit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodeMapper.map(day.weatherCode, isDay: true);
    final maxText = TemperatureUtils.format(
      day.temperatureMax,
      toFahrenheit: isFahrenheit,
    );
    final minText = TemperatureUtils.format(
      day.temperatureMin,
      toFahrenheit: isFahrenheit,
    );

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 16,
      color: isToday
          ? AppColors.surfaceContainerHigh.withValues(alpha: 0.92)
          : AppColors.surfaceContainerLow.withValues(alpha: 0.88),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              condition.icon,
              color: condition.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.dayAndShortDate(day.date, isToday: isToday),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  condition.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    maxText,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    ' / $minText',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop_outlined,
                    size: 12,
                    color: AppColors.accentStart,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${day.precipitationProbabilityMax}%',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
