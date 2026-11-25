import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Bar rentang suhu min-maks harian yang diposisikan secara proporsional terhadap rentang mingguan.
class TemperatureRangeBar extends StatelessWidget {
  const TemperatureRangeBar({
    super.key,
    required this.dayMin,
    required this.dayMax,
    required this.weekMin,
    required this.weekMax,
    required this.minLabel,
    required this.maxLabel,
  });

  final double dayMin;
  final double dayMax;
  final double weekMin;
  final double weekMax;
  final String minLabel;
  final String maxLabel;

  @override
  Widget build(BuildContext context) {
    final span = (weekMax - weekMin).abs();
    final startFraction = span < 0.5
        ? 0.1
        : ((dayMin - weekMin) / span).clamp(0.0, 0.85);
    final endFraction = span < 0.5
        ? 0.9
        : ((dayMax - weekMin) / span).clamp(startFraction + 0.12, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            minLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final left = width * startFraction;
              final barWidth = (width * (endFraction - startFraction)).clamp(
                14.0,
                width - left,
              );

              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: left,
                      width: barWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accentStart,
                              AppColors.warning,
                              AppColors.errorAlert,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            maxLabel,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
