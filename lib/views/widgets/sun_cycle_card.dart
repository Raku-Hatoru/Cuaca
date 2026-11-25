import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/daily_forecast.dart';
import 'glass_card.dart';

/// Kartu Durasi Siang/Malam dan kurva Siklus Matahari dari data terbit/terbenam API.
class SunCycleSection extends StatelessWidget {
  const SunCycleSection({
    super.key,
    required this.today,
    required this.cityLocalNow,
    required this.timezoneAbbreviation,
    required this.sunProgress,
  });

  final DailyForecast today;
  final DateTime cityLocalNow;
  final String timezoneAbbreviation;
  final double sunProgress;

  @override
  Widget build(BuildContext context) {
    final percentText = '${(sunProgress * 100).round()}%';

    return Column(
      children: [
        // Kartu Durasi Siang & Malam
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: _DurationColumn(
                  icon: Icons.wb_sunny_outlined,
                  iconColor: AppColors.warning,
                  label: 'DURASI SIANG',
                  value: DateFormatter.formatDurationHm(today.daylightDuration),
                ),
              ),
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: AppColors.surfaceContainerHighest,
              ),
              Expanded(
                child: _DurationColumn(
                  icon: Icons.dark_mode_outlined,
                  iconColor: AppColors.secondary,
                  label: 'DURASI MALAM',
                  value: DateFormatter.formatDurationHm(today.nightDuration),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Kartu Siklus Matahari dengan kurva arc
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.wb_twilight_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Siklus Matahari',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timezoneAbbreviation,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 70,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SunArcPainter(progress: sunProgress),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terbit',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          DateFormatter.formatHHmm(today.sunrise),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Sekarang: ${DateFormatter.formatHHmm(cityLocalNow)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Posisi $percentText',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Terbenam',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          DateFormatter.formatHHmm(today.sunset),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DurationColumn extends StatelessWidget {
  const _DurationColumn({
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
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 21),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  const _SunArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final p0 = Offset(14, size.height - 8);
    final p1 = Offset(size.width / 2, -16);
    final p2 = Offset(size.width - 14, size.height - 8);

    // Garis lintasan putus-putus
    final fullPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);

    final dashedPaint = Paint()
      ..color = AppColors.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (final metric in fullPath.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + 5, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), dashedPaint);
        distance += 10;
      }
    }

    // Arc progres matahari hingga posisi saat ini
    final clamped = progress.clamp(0.0, 1.0);
    if (clamped > 0.01) {
      final activePaint = Paint()
        ..color = AppColors.accentStart
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      for (final metric in fullPath.computeMetrics()) {
        final activePath = metric.extractPath(0, metric.length * clamped);
        canvas.drawPath(activePath, activePaint);
      }
    }

    // Titik posisi matahari pada kurva Bezier kuadratik
    final t = clamped;
    final sunX =
        math.pow(1 - t, 2) * p0.dx +
        2 * (1 - t) * t * p1.dx +
        math.pow(t, 2) * p2.dx;
    final sunY =
        math.pow(1 - t, 2) * p0.dy +
        2 * (1 - t) * t * p1.dy +
        math.pow(t, 2) * p2.dy;
    final sunCenter = Offset(sunX.toDouble(), sunY.toDouble());

    canvas.drawCircle(
      sunCenter,
      11,
      Paint()..color = AppColors.warning.withValues(alpha: 0.24),
    );
    canvas.drawCircle(
      sunCenter,
      6,
      Paint()..color = AppColors.warning,
    );
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
