import 'package:flutter/material.dart';

import '../../core/theme/liquid_theme.dart';

/// Organic flowing liquid mercury / water-droplet wave background for Pure AMOLED displays.
///
/// Paints smooth, hardware-accelerated fluid curves with specular edge highlights
/// and subtle floating droplets, matching the signature Liquid Dialer visual language.
class LiquidWaveBackground extends StatelessWidget {
  const LiquidWaveBackground({
    super.key,
    required this.child,
    this.showWaves = true,
    this.showFloatingDroplets = true,
    this.waveAlignment = Alignment.topRight,
    this.accentTint,
  });

  final Widget child;
  final bool showWaves;
  final bool showFloatingDroplets;
  final Alignment waveAlignment;
  final Color? accentTint;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LiquidColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showWaves)
            Positioned.fill(
              child: CustomPaint(
                painter: _LiquidWavePainter(
                  alignment: waveAlignment,
                  accentTint: accentTint,
                ),
              ),
            ),
          if (showFloatingDroplets)
            Positioned.fill(
              child: CustomPaint(painter: _FloatingDropletsPainter()),
            ),
          child,
        ],
      ),
    );
  }
}

class _LiquidWavePainter extends CustomPainter {
  _LiquidWavePainter({required this.alignment, this.accentTint});

  final Alignment alignment;
  final Color? accentTint;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Organic top-right / top wave (flowing liquid chrome ridge)
    final path1 = Path();
    path1.moveTo(w * 0.1, 0);
    path1.cubicTo(w * 0.35, h * 0.12, w * 0.70, h * 0.04, w, h * 0.22);
    path1.lineTo(w, 0);
    path1.close();

    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0x18FFFFFF),
          const Color(0x08FFFFFF),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.25));

    canvas.drawPath(path1, paint1);

    // Specular wave ridge highlight (liquid surface tension line)
    final ridgePaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0x40FFFFFF),
          const Color(0x15FFFFFF),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.2, 0, w * 0.8, h * 0.25));

    final ridgePath1 = Path();
    ridgePath1.moveTo(w * 0.1, 0);
    ridgePath1.cubicTo(w * 0.35, h * 0.12, w * 0.70, h * 0.04, w, h * 0.22);
    canvas.drawPath(ridgePath1, ridgePaint1);

    // Bottom organic liquid wave (smooth dark mercury swell)
    final path2 = Path();
    path2.moveTo(0, h * 0.82);
    path2.cubicTo(w * 0.30, h * 0.76, w * 0.65, h * 0.88, w, h * 0.84);
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0x1AFFFFFF),
          const Color(0x06FFFFFF),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.75, w, h * 0.25));

    canvas.drawPath(path2, paint2);

    // Bottom wave specular ridge
    final ridgePaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0x35FFFFFF),
          const Color(0x12FFFFFF),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.75, w, h * 0.25));

    final ridgePath2 = Path();
    ridgePath2.moveTo(0, h * 0.82);
    ridgePath2.cubicTo(w * 0.30, h * 0.76, w * 0.65, h * 0.88, w, h * 0.84);
    canvas.drawPath(ridgePath2, ridgePaint2);

    // Optional subtle chromatic accent tint (for incoming/active calls)
    if (accentTint != null) {
      final tintPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [accentTint!.withValues(alpha: 0.12), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(w * 0.8, h * 0.3),
                radius: w * 0.6,
              ),
            );
      canvas.drawPaint(tintPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiquidWavePainter oldDelegate) {
    return oldDelegate.alignment != alignment ||
        oldDelegate.accentTint != accentTint;
  }
}

class _FloatingDropletsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fixed realistic water droplet positions
    final droplets = [
      _Droplet(Offset(w * 0.88, h * 0.14), 16.0, 0.35),
      _Droplet(Offset(w * 0.12, h * 0.28), 9.0, 0.25),
      _Droplet(Offset(w * 0.92, h * 0.42), 12.0, 0.28),
      _Droplet(Offset(w * 0.08, h * 0.65), 14.0, 0.30),
      _Droplet(Offset(w * 0.85, h * 0.78), 8.0, 0.22),
    ];

    for (final d in droplets) {
      // Internal gradient
      final paint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.8,
          colors: [
            Color.fromRGBO(255, 255, 255, d.opacity * 0.6),
            Color.fromRGBO(30, 30, 30, d.opacity * 0.4),
            Color.fromRGBO(10, 10, 10, d.opacity * 0.8),
          ],
        ).createShader(Rect.fromCircle(center: d.center, radius: d.radius));

      canvas.drawCircle(d.center, d.radius, paint);

      // Specular rim light
      final rimPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Color.fromRGBO(255, 255, 255, d.opacity * 0.5);

      canvas.drawCircle(d.center, d.radius, rimPaint);

      // Tiny specular gleam
      final gleamPaint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, d.opacity * 0.9);

      canvas.drawCircle(
        Offset(d.center.dx - d.radius * 0.35, d.center.dy - d.radius * 0.35),
        d.radius * 0.2,
        gleamPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Droplet {
  const _Droplet(this.center, this.radius, this.opacity);
  final Offset center;
  final double radius;
  final double opacity;
}
