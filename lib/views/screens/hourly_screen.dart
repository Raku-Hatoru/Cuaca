import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/daily_forecast.dart';
import '../../data/models/hourly_forecast.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/error_state_view.dart';
import '../widgets/glass_card.dart';
import '../widgets/hour_detail_sheet.dart';
import '../widgets/loading_weather_view.dart';

/// Layar prakiraan per jam (24 jam ke depan) dengan penanda matahari & grafik tren.
class HourlyScreen extends StatefulWidget {
  const HourlyScreen({super.key});

  @override
  State<HourlyScreen> createState() => _HourlyScreenState();
}

class _HourlyScreenState extends State<HourlyScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    if (vm.state == WeatherViewState.initial ||
        (vm.state == WeatherViewState.loading && vm.weatherData == null)) {
      return const LoadingWeatherView(message: 'Memuat prakiraan per jam...');
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
    if (data == null || data.next24Hours.isEmpty) {
      return ErrorStateView(
        title: 'Data per jam tidak tersedia',
        subtitle: 'Muat ulang untuk mengambil data prakiraan per jam.',
        onAction: () => vm.loadWeather(),
      );
    }

    final hours = data.next24Hours;
    final activeIndex = _selectedIndex < hours.length ? _selectedIndex : 0;
    final timelineRows = _buildTimelineRows(hours, data.daily);
    final trendSummary = _buildHourlyTrendSummary(hours, vm);

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
            // Header hari dan toggle °C / °F
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          DateFormatter.dayName(hours.first.time),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Hari ini, 24 Jam',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _UnitSegmentedToggle(
                  isFahrenheit: vm.isFahrenheit,
                  onChanged: vm.setFahrenheit,
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Mini-banner tren suhu 24 jam
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderRadius: 14,
              color: AppColors.surfaceContainer,
              child: Row(
                children: [
                  Icon(
                    trendSummary.isRainRisk
                        ? Icons.water_drop_outlined
                        : Icons.wb_twilight_outlined,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      trendSummary.message,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trendSummary.badge,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: trendSummary.isRainRisk
                          ? AppColors.warning
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Daftar 24 jam ke depan + separator matahari terbit/terbenam
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timelineRows.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, rowIndex) {
                final entry = timelineRows[rowIndex];
                if (entry.sunEvent != null) {
                  return _SunEventSeparator(event: entry.sunEvent!);
                }

                final hourIndex = entry.hourIndex!;
                final hour = hours[hourIndex];
                final isNow = hourIndex == 0;
                final isSelected = hourIndex == activeIndex;

                return _HourlyRowTile(
                  hour: hour,
                  isNow: isNow,
                  isSelected: isSelected,
                  tempText: vm.formatTemp(hour.temperature),
                  apparentText: vm.formatTemp(hour.apparentTemperature),
                  onTap: () {
                    setState(() => _selectedIndex = hourIndex);
                    showHourDetailSheet(
                      context,
                      hour: hour,
                      isCurrentHour: isNow,
                      isFahrenheit: vm.isFahrenheit,
                      airQuality: data.airQuality,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            // Micro-chart tren suhu 10 jam ke depan
            _HourlyTrendChartCard(
              hours: hours.take(10).toList(),
              vm: vm,
              onTapHour: (hour, index) {
                setState(() => _selectedIndex = index);
                showHourDetailSheet(
                  context,
                  hour: hour,
                  isCurrentHour: index == 0,
                  isFahrenheit: vm.isFahrenheit,
                  airQuality: data.airQuality,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_TimelineEntry> _buildTimelineRows(
    List<HourlyForecast> hours,
    List<DailyForecast> daily,
  ) {
    final entries = <_TimelineEntry>[];
    final sunEvents = <_SunEvent>[];

    for (final day in daily.take(2)) {
      sunEvents.add(
        _SunEvent(
          time: day.sunrise,
          label: 'Matahari terbit',
          icon: Icons.wb_sunny_outlined,
        ),
      );
      sunEvents.add(
        _SunEvent(
          time: day.sunset,
          label: 'Matahari terbenam',
          icon: Icons.wb_twilight_outlined,
        ),
      );
    }

    for (var i = 0; i < hours.length; i++) {
      final hour = hours[i];
      entries.add(_TimelineEntry.hour(i));

      if (i + 1 < hours.length) {
        final nextHour = hours[i + 1];
        for (final event in sunEvents) {
          if (!event.time.isBefore(hour.time) &&
              event.time.isBefore(nextHour.time)) {
            entries.add(_TimelineEntry.sun(event));
          }
        }
      }
    }

    return entries;
  }

  _TrendSummary _buildHourlyTrendSummary(
    List<HourlyForecast> hours,
    WeatherViewModel vm,
  ) {
    var maxPop = 0;
    var maxTemp = hours.first.temperature;
    for (final h in hours) {
      if (h.precipitationProbability > maxPop) {
        maxPop = h.precipitationProbability;
      }
      if (h.temperature > maxTemp) {
        maxTemp = h.temperature;
      }
    }

    if (maxPop >= 60) {
      return _TrendSummary(
        message: 'Potensi hujan hingga $maxPop% dalam 24 jam ke depan.',
        badge: 'WASPADA',
        isRainRisk: true,
      );
    }

    return _TrendSummary(
      message:
          'Suhu puncak ${vm.formatTemp(maxTemp, withUnit: true)} dengan peluang hujan maks $maxPop%.',
      badge: 'AMAN',
      isRainRisk: false,
    );
  }
}

class _TrendSummary {
  const _TrendSummary({
    required this.message,
    required this.badge,
    required this.isRainRisk,
  });

  final String message;
  final String badge;
  final bool isRainRisk;
}

class _SunEvent {
  const _SunEvent({
    required this.time,
    required this.label,
    required this.icon,
  });

  final DateTime time;
  final String label;
  final IconData icon;
}

class _TimelineEntry {
  const _TimelineEntry.hour(this.hourIndex) : sunEvent = null;
  const _TimelineEntry.sun(this.sunEvent) : hourIndex = null;

  final int? hourIndex;
  final _SunEvent? sunEvent;
}

class _UnitSegmentedToggle extends StatelessWidget {
  const _UnitSegmentedToggle({
    required this.isFahrenheit,
    required this.onChanged,
  });

  final bool isFahrenheit;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UnitChip(
            label: '°C',
            selected: !isFahrenheit,
            onTap: () => onChanged(false),
          ),
          _UnitChip(
            label: '°F',
            selected: isFahrenheit,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AppColors.onPrimaryContainer
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HourlyRowTile extends StatelessWidget {
  const _HourlyRowTile({
    required this.hour,
    required this.isNow,
    required this.isSelected,
    required this.tempText,
    required this.apparentText,
    required this.onTap,
  });

  final HourlyForecast hour;
  final bool isNow;
  final bool isSelected;
  final String tempText;
  final String apparentText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodeMapper.map(
      hour.weatherCode,
      isDay: hour.isDay,
    );
    final timeStr = DateFormatter.formatHourCompact(hour.time);

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: isNow ? 12 : 10,
      ),
      borderRadius: isNow ? 18 : 14,
      color: isNow
          ? AppColors.surfaceContainerHighest
          : isSelected
          ? AppColors.surfaceContainerHigh
          : AppColors.surfaceContainerLow.withValues(alpha: 0.72),
      borderColor: isSelected
          ? AppColors.accentStart.withValues(alpha: 0.5)
          : AppColors.borderGlass,
      child: Row(
        children: [
          if (isNow)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.backgroundTop,
                ),
              ),
            )
          else
            SizedBox(
              width: 60,
              child: Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              condition.icon,
              size: 19,
              color: condition.iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isNow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tempText,
                        style: const TextStyle(
                          fontSize: 16,
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
                  )
                : Row(
                    children: [
                      Text(
                        tempText,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Terasa $apparentText',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.water_drop_outlined,
                size: 14,
                color: hour.precipitationProbability >= 20
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 3),
              Text(
                '${hour.precipitationProbability}%',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: hour.precipitationProbability >= 20
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              if (isNow) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.radio_button_checked,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SunEventSeparator extends StatelessWidget {
  const _SunEventSeparator({required this.event});

  final _SunEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  event.icon,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                event.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            DateFormatter.formatHHmm(event.time),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyTrendChartCard extends StatelessWidget {
  const _HourlyTrendChartCard({
    required this.hours,
    required this.vm,
    required this.onTapHour,
  });

  final List<HourlyForecast> hours;
  final WeatherViewModel vm;
  final void Function(HourlyForecast hour, int index) onTapHour;

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const SizedBox.shrink();

    var minTemp = hours.first.temperature;
    var maxTemp = hours.first.temperature;
    var peakHour = hours.first;

    for (final h in hours) {
      if (h.temperature < minTemp) minTemp = h.temperature;
      if (h.temperature > maxTemp) {
        maxTemp = h.temperature;
        peakHour = h;
      }
    }
    final range = math.max(maxTemp - minTemp, 1.0);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      color: AppColors.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tren Suhu & Terasa',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  'Puncak ${vm.formatTemp(peakHour.temperature, withUnit: true)} pukul ${DateFormatter.formatHHmm(peakHour.time)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 118,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(hours.length, (i) {
                final h = hours[i];
                final norm = ((h.temperature - minTemp) / range).clamp(
                  0.0,
                  1.0,
                );
                final barHeight = 14 + (norm * 32);
                final isPeak = h.time == peakHour.time;
                final barColor = isPeak
                    ? AppColors.warning
                    : i == 0
                    ? AppColors.primaryContainer
                    : AppColors.primary.withValues(alpha: 0.45 + (norm * 0.4));

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTapHour(h, i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              vm.formatTemp(h.temperature),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: isPeak
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isPeak
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            h.time.hour.toString().padLeft(2, '0'),
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
