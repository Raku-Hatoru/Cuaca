import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/weather_code_mapper.dart';

/// Lingkaran hero cuaca dengan halo elektrik dan cincin progres dinamis.
class WeatherRing extends StatelessWidget {
  const WeatherRing({
    super.key,
    required this.temperatureText,
    required this.unitLabel,
    required this.apparentText,
    required this.condition,
    required this.ringProgress,
    required this.onTapUpcoming,
  });

  final String temperatureText;
  final String unitLabel;
  final String apparentText;
  final WeatherConditionInfo condition;
  final double ringProgress;
  final VoidCallback onTapUpcoming;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ringSize = (screenWidth * 0.62).clamp(220.0, 296.0);

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo cahaya elektrik di belakang cincin
          Container(
            width: ringSize * 0.92,
            height: ringSize * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricGlow.withValues(alpha: 0.42),
                  blurRadius: 56,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          // Latar dalam cincin
          Container(
            width: ringSize,
            height: ringSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.62),
            ),
          ),
          // Cincin luar & aksen progres
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ringProgress.clamp(0.05, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return CustomPaint(
                size: Size(ringSize, ringSize),
                painter: _WeatherRingPainter(progress: animatedProgress),
              );
            },
          ),
          // Konten inti di dalam lingkaran
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    condition.icon,
                    size: 42,
                    color: condition.iconColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condition.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temperatureText,
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.w300,
                          height: 1.0,
                          letterSpacing: -3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 2),
                        child: Text(
                          unitLabel,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    apparentText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: onTapUpcoming,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh.withValues(
                          alpha: 0.92,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.borderGlass),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cuaca Mendatang',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherRingPainter extends CustomPainter {
  const _WeatherRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width / 2) - 4;
    final innerRadius = outerRadius - 8;

    // Lingkaran luar 18% putih
    final outerPaint = Paint()
      ..color = AppColors.ringOuter
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, outerRadius, outerPaint);

    // Trek cincin bagian dalam
    final trackPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, innerRadius, trackPaint);

    // Arc progres dengan gradien biru elektrik
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: innerRadius);

    final arcPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [
          AppColors.accentEnd,
          AppColors.accentStart,
          AppColors.primary,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

    // Titik cahaya di ujung progres
    final tipAngle = startAngle + sweepAngle;
    final tipOffset = Offset(
      center.dx + innerRadius * math.cos(tipAngle),
      center.dy + innerRadius * math.sin(tipAngle),
    );

    final glowPaint = Paint()
      ..color = AppColors.accentStart.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(tipOffset, 6, glowPaint);

    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(tipOffset, 3.5, dotPaint);

    // Kilau bintang halus di dalam ring
    final starPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.6);
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.24),
      1.8,
      starPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.30),
      1.4,
      starPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.76),
      2.0,
      starPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WeatherRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
