import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Kontainer permukaan kaca (glassmorphic) sesuai tema Nocturne Celestial Weather.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.color,
    this.borderColor,
    this.onTap,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final decoration = BoxDecoration(
      color: color ?? AppColors.surfaceContainerLow.withValues(alpha: 0.92),
      borderRadius: radius,
      border: Border.all(
        color: borderColor ?? AppColors.borderGlass,
        width: 1,
      ),
      boxShadow:
          boxShadow ??
          [
            BoxShadow(
              color: AppColors.backgroundTop.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: decoration,
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );
  }
}
