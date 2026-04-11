import 'dart:math';

import 'package:flutter/material.dart';

import 'package:chirp/ui/theme/app_theme_extension.dart';

/// A circular arc timer with rounded stroke caps and smooth animated progress.
class CircularTimer extends StatelessWidget {
  final double progress;
  final String timeText;
  final String label;
  final Color? progressColor;
  final double size;
  final double strokeWidth;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.timeText,
    required this.label,
    this.progressColor,
    this.size = 180,
    this.strokeWidth = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ChirpColors.of(context);
    final effectiveColor = progressColor ?? colors.brand;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: progress, end: progress),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, animatedProgress, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _ArcPainter(
                  progress: animatedProgress,
                  progressColor: effectiveColor,
                  backgroundColor: colors.surfaceSubtle,
                  strokeWidth: strokeWidth,
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeText,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontFeatures: [const FontFeature.tabularFigures()],
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _ArcPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background arc (full circle)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    // Progress arc (starts at 12 o'clock)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
