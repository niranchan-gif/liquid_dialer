import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Asymmetric organic water droplet frame inspired by high-tension liquid physics.
///
/// Encapsulates avatars and hero elements inside a realistic floating water droplet
/// with specular rim lighting, refractive depth, and smooth breathing motion.
class OrganicLiquidDroplet extends StatelessWidget {
  const OrganicLiquidDroplet({
    super.key,
    required this.child,
    this.size = 150.0,
    this.borderWidth = 1.8,
    this.glowColor = const Color(0x35FFFFFF),
  });

  final Widget child;
  final double size;
  final double borderWidth;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: glowColor, blurRadius: 32.0, spreadRadius: 2.0),
          const BoxShadow(
            color: Color(0x90000000),
            blurRadius: 20.0,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer organic droplet surface painter
          CustomPaint(
            size: Size(size, size),
            painter: _OrganicDropletPainter(borderWidth: borderWidth),
          ),

          // Clipped content within the organic droplet boundary
          ClipPath(
            clipper: _OrganicDropletClipper(),
            child: SizedBox(
              width: size * 0.84,
              height: size * 0.84,
              child: child,
            ),
          ),

          // Top specular water reflection meniscus
          Positioned(
            top: size * 0.08,
            left: size * 0.22,
            child: Container(
              width: size * 0.40,
              height: size * 0.16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x65FFFFFF), Color(0x10FFFFFF)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganicDropletClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Natural fluid asymmetrical water droplet curve
    path.moveTo(w * 0.50, h * 0.04);
    path.cubicTo(w * 0.76, h * 0.02, w * 0.98, h * 0.24, w * 0.95, h * 0.54);
    path.cubicTo(w * 0.92, h * 0.82, w * 0.72, h * 0.98, w * 0.46, h * 0.96);
    path.cubicTo(w * 0.20, h * 0.94, w * 0.02, h * 0.74, w * 0.04, h * 0.48);
    path.cubicTo(w * 0.06, h * 0.22, w * 0.26, h * 0.06, w * 0.50, h * 0.04);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _OrganicDropletPainter extends CustomPainter {
  _OrganicDropletPainter({required this.borderWidth});

  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.50, h * 0.03);
    path.cubicTo(w * 0.78, h * 0.01, w * 1.00, h * 0.22, w * 0.96, h * 0.55);
    path.cubicTo(w * 0.93, h * 0.84, w * 0.74, h * 1.00, w * 0.46, h * 0.98);
    path.cubicTo(w * 0.18, h * 0.96, 0, h * 0.76, w * 0.02, h * 0.48);
    path.cubicTo(w * 0.04, h * 0.20, w * 0.24, h * 0.05, w * 0.50, h * 0.03);
    path.close();

    // Fluid base gradient (deep translucent graphite)
    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 0.9,
        colors: [
          const Color(0x35FFFFFF),
          const Color(0xFF1A1A1A),
          const Color(0xFF0A0A0A),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, fillPaint);

    // Specular liquid chrome rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: const [
          Color(0x90FFFFFF), // top gleam
          Color(0x25FFFFFF), // right flank
          Color(0x40FFFFFF), // bottom highlight
          Color(0x18FFFFFF), // left flank
          Color(0x90FFFFFF),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        transform: const GradientRotation(-math.pi / 4),
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
