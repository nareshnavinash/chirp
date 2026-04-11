import 'dart:math';

import 'package:flutter/material.dart';

/// A circular progress ring with a gentle breathing animation — subtle scale
/// oscillation and a pulsing glow behind the ring. Designed for the break
/// screen's calming aesthetic.
class BreathingProgressRing extends StatefulWidget {
  final double progress;
  final String timeText;
  final double size;
  final double strokeWidth;

  const BreathingProgressRing({
    super.key,
    required this.progress,
    required this.timeText,
    this.size = 160,
    this.strokeWidth = 4,
  });

  @override
  State<BreathingProgressRing> createState() => _BreathingProgressRingState();
}

class _BreathingProgressRingState extends State<BreathingProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _glowOpacity = Tween(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scale = Tween(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow shadow behind the ring
                Container(
                  width: widget.size - widget.strokeWidth * 2,
                  height: widget.size - widget.strokeWidth * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white
                            .withValues(alpha: _glowOpacity.value),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
                // Progress ring
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _BreathingArcPainter(
                    progress: widget.progress,
                    strokeWidth: widget.strokeWidth,
                  ),
                ),
                // Center time text
                child!,
              ],
            ),
          ),
        );
      },
      child: Text(
        widget.timeText,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w200,
          fontFeatures: [const FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _BreathingArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _BreathingArcPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_BreathingArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
