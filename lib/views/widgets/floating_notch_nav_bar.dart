import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Tab bar melayang (floating) dengan lekukan notch di tengah dan tombol Cari gradien biru.
///
/// Indeks tab:
/// 0 = Hari Ini, 1 = Per Jam, 2 = Cari (tombol tengah), 3 = Harian, 4 = Favorit.
class FloatingNotchNavBar extends StatelessWidget {
  const FloatingNotchNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
  });

  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  static const double _barHeight = 68;
  static const double _centerButtonSize = 56;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SizedBox(
            height: _barHeight + 22,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Bayangan lembut di belakang bar ber-notch
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _barHeight,
                  child: CustomPaint(
                    painter: _NotchShadowPainter(),
                  ),
                ),
                // Badan bar dengan ClipPath notch + efek blur + border
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _barHeight,
                  child: ClipPath(
                    clipper: const _NotchBarClipper(),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: CustomPaint(
                        painter: _NotchBorderPainter(),
                        child: Container(
                          color: AppColors.navBarFill,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _NavBarItem(
                                      icon: Icons.wb_sunny_outlined,
                                      activeIcon: Icons.wb_sunny_rounded,
                                      label: 'Hari Ini',
                                      isActive: currentIndex == 0,
                                      onTap: () => onSelectTab(0),
                                    ),
                                    _NavBarItem(
                                      icon: Icons.schedule_outlined,
                                      activeIcon: Icons.schedule_rounded,
                                      label: 'Per Jam',
                                      isActive: currentIndex == 1,
                                      onTap: () => onSelectTab(1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 72),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _NavBarItem(
                                      icon: Icons.calendar_today_outlined,
                                      activeIcon: Icons.calendar_today_rounded,
                                      label: 'Harian',
                                      isActive: currentIndex == 3,
                                      onTap: () => onSelectTab(3),
                                    ),
                                    _NavBarItem(
                                      icon: Icons.star_outline_rounded,
                                      activeIcon: Icons.star_rounded,
                                      label: 'Favorit',
                                      isActive: currentIndex == 4,
                                      onTap: () => onSelectTab(4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Tombol bulat Cari tepat di tengah notch
                Positioned(
                  top: 2,
                  child: _CenterSearchButton(
                    isActive: currentIndex == 2,
                    size: _centerButtonSize,
                    onTap: () => onSelectTab(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterSearchButton extends StatelessWidget {
  const _CenterSearchButton({
    required this.isActive,
    required this.size,
    required this.onTap,
  });

  final bool isActive;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cari Kota',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.accentStart, AppColors.accentEnd],
            ),
            border: Border.all(
              color: isActive
                  ? AppColors.textPrimary.withValues(alpha: 0.7)
                  : AppColors.textPrimary.withValues(alpha: 0.2),
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentStart.withValues(
                  alpha: isActive ? 0.72 : 0.50,
                ),
                blurRadius: isActive ? 26 : 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.search_rounded,
            color: AppColors.textPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.textPrimary
        : AppColors.textPrimary.withValues(alpha: 0.60);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 58,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 5 : 0,
              height: isActive ? 5 : 0,
              decoration: const BoxDecoration(
                color: AppColors.accentStart,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Path _buildNotchedBarPath(Size size) {
  const double r = 28;
  final double w = size.width;
  final double h = size.height;
  final double cx = w / 2;

  return Path()
    ..moveTo(0, r)
    ..quadraticBezierTo(0, 0, r, 0)
    ..lineTo(cx - 46, 0)
    ..cubicTo(cx - 34, 0, cx - 32, 10, cx - 28, 20)
    ..cubicTo(cx - 20, 42, cx + 20, 42, cx + 28, 20)
    ..cubicTo(cx + 32, 10, cx + 34, 0, cx + 46, 0)
    ..lineTo(w - r, 0)
    ..quadraticBezierTo(w, 0, w, r)
    ..lineTo(w, h - r)
    ..quadraticBezierTo(w, h, w - r, h)
    ..lineTo(r, h)
    ..quadraticBezierTo(0, h, 0, h - r)
    ..close();
}

class _NotchBarClipper extends CustomClipper<Path> {
  const _NotchBarClipper();

  @override
  Path getClip(Size size) => _buildNotchedBarPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _NotchBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildNotchedBarPath(size);
    final borderPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotchShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildNotchedBarPath(size);
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.65),
      18,
      false,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
