import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/location_model.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/glass_card.dart';

/// Layar daftar lokasi favorit yang disimpan di penyimpanan lokal.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.onOpenSearch,
    required this.onLocationSelected,
  });

  final VoidCallback onOpenSearch;
  final VoidCallback onLocationSelected;

  Future<void> _selectCity(
    BuildContext context,
    LocationModel location,
  ) async {
    final weatherVm = context.read<WeatherViewModel>();
    final searchVm = context.read<SearchViewModel>();

    await searchVm.addHistory(location);
    onLocationSelected();
    await weatherVm.selectLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    final favVm = context.watch<FavoritesViewModel>();
    final weatherVm = context.watch<WeatherViewModel>();

    return RefreshIndicator(
      color: AppColors.accentStart,
      backgroundColor: AppColors.surfaceContainerHigh,
      onRefresh: favVm.refreshWeather,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kota Favorit',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${favVm.favorites.length} lokasi tersimpan di perangkat',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onOpenSearch,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: const BorderSide(color: AppColors.borderGlass),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (favVm.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentStart,
                  ),
                ),
              )
            else if (favVm.favorites.isEmpty)
              _buildEmptyState(context)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: favVm.favorites.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final city = favVm.favorites[index];
                  final summary = favVm.summaries[city.id];
                  final isCurrent = city.id == weatherVm.activeLocation.id;
                  final condition = summary != null
                      ? WeatherCodeMapper.map(
                          summary.weatherCode,
                          isDay: summary.isDay,
                        )
                      : null;

                  return GlassCard(
                    onTap: () => _selectCity(context, city),
                    padding: const EdgeInsets.all(16),
                    borderRadius: 18,
                    color: isCurrent
                        ? AppColors.surfaceContainerHighest.withValues(
                            alpha: 0.94,
                          )
                        : AppColors.surfaceContainer,
                    borderColor: isCurrent
                        ? AppColors.accentStart.withValues(alpha: 0.45)
                        : AppColors.borderGlass,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            condition?.icon ?? Icons.star_rounded,
                            color: condition?.iconColor ?? AppColors.warning,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      city.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: const Text(
                                        'Aktif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                city.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (condition != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  '${condition.description} • Angin ${summary!.windSpeed.round()} km/j',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              summary != null
                                  ? weatherVm.formatTemp(summary.temperature)
                                  : '—°',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              padding: EdgeInsets.zero,
                              tooltip: 'Hapus dari Favorit',
                              onPressed: () async {
                                await favVm.removeFavorite(city.id);
                                if (!context.mounted) return;
                                showAppSnackBar(
                                  context,
                                  '${city.name} dihapus dari Favorit',
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      borderRadius: 24,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              size: 34,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Kota Favorit',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ketuk ikon bintang saat mencari kota atau di bagian atas layar untuk menyimpan kota favorit Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onOpenSearch,
            icon: const Icon(Icons.search_rounded, size: 18),
            label: const Text('Cari Kota'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentEnd,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
