import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/location_model.dart';

/// Header aplikasi atas yang menampilkan pemilih kota aktif, favorit cepat, dan menu.
class TopLocationBar extends StatelessWidget {
  const TopLocationBar({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.isFahrenheit,
    required this.onTapLocation,
    required this.onToggleFavorite,
    required this.onTapMenu,
    required this.onTapSettings,
  });

  final LocationModel location;
  final bool isFavorite;
  final bool isFahrenheit;
  final VoidCallback onTapLocation;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTapMenu;
  final VoidCallback onTapSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _CircleHeaderButton(
            icon: Icons.menu_rounded,
            tooltip: 'Menu Navigasi',
            onTap: onTapMenu,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onTapLocation,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.borderGlass),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          location.headerLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleHeaderButton(
            icon: isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            iconColor: isFavorite ? AppColors.warning : AppColors.textSecondary,
            tooltip: isFavorite ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
            onTap: onToggleFavorite,
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTapSettings,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Text(
                  isFahrenheit ? '°F' : '°C',
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleHeaderButton extends StatelessWidget {
  const _CircleHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGlass),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
