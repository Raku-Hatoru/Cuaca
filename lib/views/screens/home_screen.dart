import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/temperature_utils.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/weather_data.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/error_state_view.dart';
import '../widgets/forecast_tile.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_weather_view.dart';
import '../widgets/metric_grid_card.dart';
import '../widgets/sun_cycle_card.dart';
import '../widgets/weather_ring.dart';

/// Layar utama (Tab Hari Ini) menampilkan ring suhu, ringkasan, detail, dan prakiraan 7 hari.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateTab,
    required this.onOpenSettings,
  });

  final ValueChanged<int> onNavigateTab;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    if (vm.state == WeatherViewState.initial ||
        (vm.state == WeatherViewState.loading && vm.weatherData == null)) {
      return const LoadingWeatherView();
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
    if (data == null) {
      return ErrorStateView(
        title: 'Data cuaca belum tersedia',
        subtitle: 'Tekan tombol di bawah untuk memuat ulang data dari Open-Meteo.',
        onAction: () => vm.loadWeather(),
      );
    }

    return RefreshIndicator(
      color: AppColors.accentStart,
      backgroundColor: AppColors.surfaceContainerHigh,
      onRefresh: () => vm.loadWeather(showLoading: false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 680;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
            child: isTablet
                ? _buildTabletLayout(context, vm, data)
                : _buildMobileLayout(context, vm, data),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WeatherViewModel vm,
    WeatherData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopQuickRow(context, vm, data),
        const SizedBox(height: 8),
        Center(child: _buildHeroRing(vm, data)),
        const SizedBox(height: 18),
        _buildSummaryCard(vm, data),
        const SizedBox(height: 22),
        _buildDetailsSection(context, vm, data),
        const SizedBox(height: 22),
        _buildWeeklyPreviewSection(context, vm, data),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WeatherViewModel vm,
    WeatherData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopQuickRow(context, vm, data),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Center(child: _buildHeroRing(vm, data)),
                  const SizedBox(height: 18),
                  _buildSummaryCard(vm, data),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  _buildDetailsSection(context, vm, data),
                  const SizedBox(height: 22),
                  _buildWeeklyPreviewSection(context, vm, data),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopQuickRow(
    BuildContext context,
    WeatherViewModel vm,
    WeatherData data,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoundQuickButton(
          icon: Icons.settings_outlined,
          tooltip: 'Pengaturan Satuan',
          onTap: onOpenSettings,
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.borderGlass),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'DIPERBARUI ${DateFormatter.formatHHmm(data.fetchedAt)} ${data.timezoneAbbreviation}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _RoundQuickButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Muat Ulang Cuaca',
          isBusy: vm.isLoading,
          onTap: () => vm.loadWeather(showLoading: false),
        ),
      ],
    );
  }

  Widget _buildHeroRing(WeatherViewModel vm, WeatherData data) {
    final condition = WeatherCodeMapper.map(
      data.current.weatherCode,
      isDay: data.current.isDay,
    );
    final tempNumber = vm.convertTemp(data.current.temperature).round().toString();
    final apparent = vm.formatTemp(data.current.apparentTemperature);
    final pop = data.todayDaily?.precipitationProbabilityMax ?? 0;
    final ringProgress = pop > 0
        ? (pop / 100.0)
        : (data.current.relativeHumidity / 100.0);

    return WeatherRing(
      temperatureText: tempNumber,
      unitLabel: TemperatureUtils.unitLabel(vm.isFahrenheit),
      apparentText: 'Terasa seperti $apparent',
      condition: condition,
      ringProgress: ringProgress,
      onTapUpcoming: () => onNavigateTab(3),
    );
  }

  Widget _buildSummaryCard(WeatherViewModel vm, WeatherData data) {
    final today = data.todayDaily;
    final minTemp = today != null
        ? vm.formatTemp(today.temperatureMin)
        : vm.formatTemp(data.current.temperature);
    final maxTemp = today != null
        ? vm.formatTemp(today.temperatureMax)
        : vm.formatTemp(data.current.temperature);
    final pop = today?.precipitationProbabilityMax ?? 0;
    final todayCondition = WeatherCodeMapper.map(
      today?.weatherCode ?? data.current.weatherCode,
      isDay: true,
    );

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      borderRadius: 18,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SummaryColumn(
                label: 'TERENDAH',
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.primary,
                value: minTemp,
                sublabel: 'Min hari ini',
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'HARI INI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      todayCondition.icon,
                      size: 26,
                      color: todayCondition.iconColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pop%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Peluang hujan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _SummaryColumn(
                label: 'TERTINGGI',
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.warning,
                value: maxTemp,
                sublabel: 'Maks hari ini',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    WeatherViewModel vm,
    WeatherData data,
  ) {
    final current = data.current;
    final today = data.todayDaily;
    final uvValue = data.currentUvIndex;
    final aqi = data.airQuality;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Detail Hari Ini',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => onNavigateTab(1),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Info Per Jam →',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (today != null) ...[
          SunCycleSection(
            today: today,
            cityLocalNow: data.cityLocalNow,
            timezoneAbbreviation: data.timezoneAbbreviation,
            sunProgress: data.sunCycleProgress,
          ),
          const SizedBox(height: 12),
        ],
        _MetricRowPair(
          left: MetricGridCard(
            icon: Icons.water_drop_outlined,
            label: 'Kelembapan',
            value: '${current.relativeHumidity}',
            unit: '%',
            subtitle:
                'Titik embun ${vm.formatTemp(current.dewPoint, withUnit: true)}',
          ),
          right: MetricGridCard(
            icon: Icons.air_rounded,
            label: 'Angin',
            value: '${current.windSpeed.round()}',
            unit: 'km/j',
            subtitle: TemperatureUtils.windDirectionLabel(
              current.windDirection,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _MetricRowPair(
          left: MetricGridCard(
            icon: Icons.umbrella_outlined,
            label: 'Peluang Hujan',
            value: '${today?.precipitationProbabilityMax ?? 0}',
            unit: '%',
            subtitle: 'Prediksi hari ini',
          ),
          right: MetricGridCard(
            icon: Icons.grain,
            label: 'Curah Hujan',
            value: current.precipitation.toStringAsFixed(1),
            unit: 'mm',
            subtitle:
                'Total hari ini ${today?.precipitationSum.toStringAsFixed(1) ?? '0.0'} mm',
          ),
        ),
        const SizedBox(height: 12),
        _MetricRowPair(
          left: MetricGridCard(
            icon: Icons.wb_sunny_outlined,
            iconColor: AppColors.warning,
            label: 'Indeks UV',
            value: uvValue.toStringAsFixed(0),
            unit: TemperatureUtils.uvCategory(uvValue),
            progressValue: (uvValue / 11).clamp(0.08, 1.0),
            progressColor: uvValue >= 6
                ? AppColors.errorAlert
                : AppColors.warning,
          ),
          right: MetricGridCard(
            icon: Icons.speed_outlined,
            label: 'Tekanan Udara',
            value: '${current.surfacePressure.round()}',
            unit: 'hPa',
            subtitle: TemperatureUtils.pressureDescription(
              current.surfacePressure,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.energy_savings_leaf_outlined,
                  color: AppColors.onSecondaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Kualitas Udara',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (aqi != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              TemperatureUtils.aqiCategory(aqi.europeanAqi),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      aqi != null
                          ? 'AQI ${aqi.europeanAqi} • ${TemperatureUtils.aqiAdvice(aqi.europeanAqi)}'
                          : 'Data kualitas udara sedang tidak tersedia untuk lokasi ini',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyPreviewSection(
    BuildContext context,
    WeatherViewModel vm,
    WeatherData data,
  ) {
    final days = data.daily.take(7).toList();
    if (days.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Prakiraan 7 Hari',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => onNavigateTab(3),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Detail Harian →',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return ForecastTile(
              day: days[index],
              isToday: index == 0,
              isFahrenheit: vm.isFahrenheit,
              onTap: () => onNavigateTab(3),
            );
          },
        ),
      ],
    );
  }
}

class _RoundQuickButton extends StatelessWidget {
  const _RoundQuickButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isBusy = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGlass),
          ),
          child: isBusy
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.sublabel,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRowPair extends StatelessWidget {
  const _MetricRowPair({
    required this.left,
    required this.right,
  });

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }
}
