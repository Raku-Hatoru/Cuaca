import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/temperature_utils.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/daily_forecast.dart';
import '../../data/models/hourly_forecast.dart';
import '../../data/models/weather_data.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/error_state_view.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_weather_view.dart';
import '../widgets/temperature_range_bar.dart';

/// Layar prakiraan 7 hari rinci dengan rentang suhu dan detail per jam tiap hari.
class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    if (vm.state == WeatherViewState.initial ||
        (vm.state == WeatherViewState.loading && vm.weatherData == null)) {
      return const LoadingWeatherView(message: 'Memuat prakiraan 7 hari...');
    }

    if (vm.state == WeatherViewState.error && vm.weatherData == null) {
      return ErrorStateView(
        title: vm.isNetworkError
            ? 'Tidak ada koneksi internet'
            : 'Gagal memuat data cuaca',
        subtitle: vm.isNetworkError
            ? 'Periksa koneksi Wi-Fi atau data seluler Anda lalu tekan Coba lagi.'
            : (vm.errorMessage ??
                  'Terjadi kesalahan saat mengambil data dari Open-Meteo.'),
        icon: vm.isNetworkError
            ? Icons.wifi_off_rounded
            : Icons.cloud_off_rounded,
        onAction: () => vm.loadWeather(),
      );
    }

    final data = vm.weatherData;
    if (data == null || data.daily.isEmpty) {
      return ErrorStateView(
        title: 'Prakiraan 7 hari belum tersedia',
        subtitle: 'Muat ulang untuk mengambil data 7 hari dari Open-Meteo.',
        onAction: () => vm.loadWeather(),
      );
    }

    final days = data.daily;
    final weekMin = days
        .map((e) => e.temperatureMin)
        .reduce((a, b) => a < b ? a : b);
    final weekMax = days
        .map((e) => e.temperatureMax)
        .reduce((a, b) => a > b ? a : b);

    final avgMax =
        days.map((e) => e.temperatureMax).reduce((a, b) => a + b) / days.length;
    final rainyDays =
        days.where((e) => e.precipitationProbabilityMax >= 50).length;

    return RefreshIndicator(
      color: AppColors.accentStart,
      backgroundColor: AppColors.surfaceContainerHigh,
      onRefresh: () => vm.loadWeather(showLoading: false),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header judul & lokasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prakiraan 7 Hari',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.pin_drop_outlined,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${data.location.name}, ${data.location.subtitle}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Ringkasan Mingguan
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 18,
              color: AppColors.surfaceContainerHigh,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RINGKASAN MINGGUAN',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rainyDays > 0
                              ? 'Suhu rata-rata ${vm.formatTemp(avgMax, withUnit: true)} dengan potensi hujan di $rainyDays hari mendatang.'
                              : 'Suhu rata-rata ${vm.formatTemp(avgMax, withUnit: true)} dengan cuaca relatif kering sepanjang pekan.',
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.35,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Daftar 7 kartu prakiraan harian
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final day = days[index];
                return _DailyForecastCard(
                  day: day,
                  isToday: index == 0,
                  weekMin: weekMin,
                  weekMax: weekMax,
                  vm: vm,
                  onTap: () => _showDayDetailSheet(context, day, data, vm, index == 0),
                );
              },
            ),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 15,
                  color: AppColors.textMuted,
                ),
                SizedBox(width: 6),
                Text(
                  'Ketuk kartu harian untuk detail per jam lengkap',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDayDetailSheet(
    BuildContext context,
    DailyForecast day,
    WeatherData data,
    WeatherViewModel vm,
    bool isToday,
  ) {
    final condition = WeatherCodeMapper.map(day.weatherCode, isDay: true);
    final dayHours = data.hourlyForDay(day.date);

    showModalBottomSheet<void>(
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
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        condition.icon,
                        color: condition.iconColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isToday
                                ? 'Hari Ini • ${DateFormatter.shortDateBadge(day.date)}'
                                : DateFormatter.dayAndShortDate(day.date),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            condition.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${vm.formatTemp(day.temperatureMax)} / ${vm.formatTemp(day.temperatureMin)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MiniDayStat(
                        label: 'Terbit / Terbenam',
                        value:
                            '${DateFormatter.formatHHmm(day.sunrise)} - ${DateFormatter.formatHHmm(day.sunset)}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniDayStat(
                        label: 'UV Maks & Angin',
                        value:
                            'UV ${day.uvIndexMax.toStringAsFixed(0)} (${TemperatureUtils.uvCategory(day.uvIndexMax)}) • ${day.windSpeedMax.round()} km/j',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Prakiraan Per Jam Hari Ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (dayHours.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Rincian per jam belum tersedia untuk tanggal ini.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 116,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dayHours.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        return _CompactHourCard(
                          hour: dayHours[idx],
                          tempText: vm.formatTemp(dayHours[idx].temperature),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DailyForecastCard extends StatelessWidget {
  const _DailyForecastCard({
    required this.day,
    required this.isToday,
    required this.weekMin,
    required this.weekMax,
    required this.vm,
    required this.onTap,
  });

  final DailyForecast day;
  final bool isToday;
  final double weekMin;
  final double weekMax;
  final WeatherViewModel vm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodeMapper.map(day.weatherCode, isDay: true);

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: 16,
      color: isToday
          ? AppColors.surfaceContainerHighest.withValues(alpha: 0.96)
          : AppColors.surfaceContainer,
      borderColor: isToday
          ? AppColors.accentStart.withValues(alpha: 0.45)
          : AppColors.borderGlass,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (isToday)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.accentStart, AppColors.accentEnd],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.surfaceContainer
                              : AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          condition.icon,
                          size: 22,
                          color: condition.iconColor,
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
                                    DateFormatter.dayAndShortDate(
                                      day.date,
                                      isToday: isToday,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isToday) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      DateFormatter.shortDateBadge(day.date),
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              condition.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                vm.formatTemp(day.temperatureMax),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                ' / ${vm.formatTemp(day.temperatureMin)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.water_drop_outlined,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${day.precipitationProbabilityMax}%',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight:
                                      day.precipitationProbabilityMax >= 50
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: day.precipitationProbabilityMax >= 50
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TemperatureRangeBar(
                    dayMin: day.temperatureMin,
                    dayMax: day.temperatureMax,
                    weekMin: weekMin,
                    weekMax: weekMax,
                    minLabel: vm.formatTemp(day.temperatureMin),
                    maxLabel: vm.formatTemp(day.temperatureMax),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniDayStat extends StatelessWidget {
  const _MiniDayStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHourCard extends StatelessWidget {
  const _CompactHourCard({
    required this.hour,
    required this.tempText,
  });

  final HourlyForecast hour;
  final String tempText;

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodeMapper.map(
      hour.weatherCode,
      isDay: hour.isDay,
    );

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormatter.formatHourCompact(hour.time),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            condition.icon,
            size: 22,
            color: condition.iconColor,
          ),
          Text(
            tempText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${hour.precipitationProbability}%',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
