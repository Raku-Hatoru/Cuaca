import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/location_model.dart';
import '../../data/models/weather_data.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/error_state_view.dart';
import '../widgets/glass_card.dart';

/// Layar Cari & Kelola Lokasi menggunakan Open-Meteo Geocoding API, riwayat, dan kota populer.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.onLocationSelected,
  });

  final VoidCallback onLocationSelected;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectCity(LocationModel location) async {
    _focusNode.unfocus();
    final weatherVm = context.read<WeatherViewModel>();
    final searchVm = context.read<SearchViewModel>();

    await searchVm.addHistory(location);
    searchVm.clearSearch();
    _controller.clear();

    widget.onLocationSelected();
    await weatherVm.selectLocation(location);
  }

  Future<void> _toggleFavorite(LocationModel location) async {
    final favVm = context.read<FavoritesViewModel>();
    final added = await favVm.toggleFavorite(location);
    if (!mounted) return;
    showAppSnackBar(
      context,
      added
          ? '${location.name} ditambahkan ke Favorit'
          : '${location.name} dihapus dari Favorit',
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();
    final weatherVm = context.watch<WeatherViewModel>();
    final favVm = context.watch<FavoritesViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kolom pencarian pill dengan glow elektrik
          _buildSearchField(searchVm),
          const SizedBox(height: 18),
          if (searchVm.isSearching)
            _buildSearchBody(searchVm, favVm)
          else ...[
            _buildHistorySection(searchVm, weatherVm, favVm),
            const SizedBox(height: 22),
            _buildPopularCitiesSection(searchVm, weatherVm, favVm),
            const SizedBox(height: 20),
            _buildGlobalInfoCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(SearchViewModel searchVm) {
    final isLoading = searchVm.state == SearchViewState.loading;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentStart.withValues(alpha: 0.22),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        onChanged: searchVm.onQueryChanged,
        onSubmitted: (val) => searchVm.searchNow(val),
        decoration: InputDecoration(
          hintText: 'Cari kota atau daerah...',
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14.5,
          ),
          filled: true,
          fillColor: AppColors.surfaceContainer.withValues(alpha: 0.94),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  tooltip: 'Bersihkan pencarian',
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 19,
                  ),
                  onPressed: () {
                    _controller.clear();
                    searchVm.clearSearch();
                    _focusNode.requestFocus();
                  },
                ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.borderGlass),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.borderGlass),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(
              color: AppColors.accentStart,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBody(
    SearchViewModel searchVm,
    FavoritesViewModel favVm,
  ) {
    switch (searchVm.state) {
      case SearchViewState.initial:
      case SearchViewState.loading:
        return GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: const Column(
            children: [
              CircularProgressIndicator(color: AppColors.accentStart),
              SizedBox(height: 14),
              Text(
                'Mencari lokasi di Open-Meteo...',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );

      case SearchViewState.error:
        return ErrorStateView(
          title: searchVm.isNetworkError
              ? 'Tidak ada koneksi internet'
              : 'Gagal mencari lokasi',
          subtitle: searchVm.isNetworkError
              ? 'Periksa koneksi internet Anda lalu tekan Coba lagi.'
              : (searchVm.errorMessage ??
                    'Terjadi kesalahan saat menghubungi layanan Geocoding.'),
          icon: searchVm.isNetworkError
              ? Icons.wifi_off_rounded
              : Icons.error_outline_rounded,
          onAction: () => searchVm.searchNow(),
        );

      case SearchViewState.empty:
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          borderRadius: 24,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceGlassActive,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.travel_explore_rounded,
                  size: 30,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Kota tidak ditemukan',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Periksa ejaan nama kota atau coba kata kunci wilayah yang lebih luas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _controller.clear();
                  searchVm.clearSearch();
                  _focusNode.requestFocus();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.borderGlass),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text('Coba Kata Kunci Lain'),
              ),
            ],
          ),
        );

      case SearchViewState.success:
        final results = searchVm.results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HASIL GEOCODING (OPEN-METEO)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${results.length} ditemukan',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final city = results[index];
                final isFav = favVm.isFavorite(city.id);
                return GlassCard(
                  onTap: () => _selectCity(city),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.85),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.explore_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${city.subtitle} • ${city.coordinatesLabel}',
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
                      IconButton(
                        tooltip: isFav
                            ? 'Hapus dari Favorit'
                            : 'Simpan ke Favorit',
                        onPressed: () => _toggleFavorite(city),
                        icon: Icon(
                          isFav
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isFav
                              ? AppColors.warning
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
    }
  }

  Widget _buildHistorySection(
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
    FavoritesViewModel favVm,
  ) {
    final history = searchVm.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 19,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Riwayat Pencarian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (history.isNotEmpty)
              TextButton(
                onPressed: searchVm.clearHistory,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Hapus Riwayat',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (history.isEmpty)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            color: AppColors.surfaceContainer.withValues(alpha: 0.55),
            child: const Text(
              'Belum ada riwayat pencarian. Ketik minimal 2 huruf pada kolom di atas untuk mencari kota.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final city = history[index];
              final isCurrent = city.id == weatherVm.activeLocation.id;
              final isFav = favVm.isFavorite(city.id);
              final summary = searchVm.citySummaries[city.id];

              return GlassCard(
                onTap: () => _selectCity(city),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                color: AppColors.surfaceContainer.withValues(alpha: 0.72),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceGlassActive,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.primary,
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
                                  city.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Lokasi Ini',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            city.subtitle,
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
                    if (summary != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          weatherVm.formatTemp(
                            summary.temperature,
                            withUnit: true,
                          ),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    IconButton(
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: isFav
                          ? 'Hapus dari Favorit'
                          : 'Simpan ke Favorit',
                      onPressed: () => _toggleFavorite(city),
                      icon: Icon(
                        isFav
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 20,
                        color: isFav ? AppColors.warning : AppColors.textMuted,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'Hapus dari riwayat',
                      onPressed: () => searchVm.removeHistoryItem(city.id),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPopularCitiesSection(
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
    FavoritesViewModel favVm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  size: 19,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Kota Populer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'Pilihan Cepat',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < ApiConstants.popularCities.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildPopularCard(
                    ApiConstants.popularCities[i],
                    searchVm,
                    weatherVm,
                    favVm,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < ApiConstants.popularCities.length
                      ? _buildPopularCard(
                          ApiConstants.popularCities[i + 1],
                          searchVm,
                          weatherVm,
                          favVm,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPopularCard(
    LocationModel city,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
    FavoritesViewModel favVm,
  ) {
    return _PopularCityCard(
      city: city,
      summary: searchVm.citySummaries[city.id],
      isFavorite: favVm.isFavorite(city.id),
      weatherVm: weatherVm,
      onTap: () => _selectCity(city),
      onToggleFavorite: () => _toggleFavorite(city),
    );
  }

  Widget _buildGlobalInfoCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.85),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.public_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cakupan Global Tanpa Batas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ketik nama kota atau daerah mana pun di dunia. Didukung integrasi Open-Meteo Geocoding API secara real-time.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
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

class _PopularCityCard extends StatelessWidget {
  const _PopularCityCard({
    required this.city,
    required this.summary,
    required this.isFavorite,
    required this.weatherVm,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final LocationModel city;
  final CityWeatherSummary? summary;
  final bool isFavorite;
  final WeatherViewModel weatherVm;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final condition = summary != null
        ? WeatherCodeMapper.map(summary!.weatherCode, isDay: summary!.isDay)
        : null;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(13),
      color: AppColors.surfaceContainer.withValues(alpha: 0.78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      city.country,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onToggleFavorite,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 19,
                    color: isFavorite ? AppColors.warning : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary != null
                          ? weatherVm.formatTemp(summary!.temperature)
                          : '—°',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      condition?.description ?? 'Ketuk untuk lihat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    condition?.icon ?? Icons.public_outlined,
                    size: 22,
                    color: condition?.iconColor ?? AppColors.primary,
                  ),
                  if (summary?.precipitationProbability != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${summary!.precipitationProbability}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
