import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/liquid_theme.dart';

/// Visual depth hierarchy for Liquid surfaces.
enum LiquidSurfaceLevel {
  /// Subtle major backdrop surface (Level 1)
  subtle,

  /// Card or row surface (Level 2)
  card,

  /// Interactive or floating modal surface (Level 3)
  elevated,
}

/// Reusable water-on-dark-glass surface container with specular meniscus reflection.
class LiquidSurface extends StatelessWidget {
  const LiquidSurface({
    super.key,
    required this.child,
    this.level = LiquidSurfaceLevel.card,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.blurSigma = 10.0,
    this.showMeniscus = true,
    this.customBorder,
    this.customGradient,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final LiquidSurfaceLevel level;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double blurSigma;
  final bool showMeniscus;
  final BoxBorder? customBorder;
  final Gradient? customGradient;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20.0);

    Color topColor;
    Color bottomColor;
    Color borderColor;
    List<BoxShadow> shadows;
    double meniscusOpacity;

    switch (level) {
      case LiquidSurfaceLevel.subtle:
        topColor = const Color(0xFF0F0F0F);
        bottomColor = const Color(0xFF080808);
        borderColor = LiquidColors.borderSubtle;
        shadows = LiquidDecorations.subtleDepth;
        meniscusOpacity = 0.35;
        break;
      case LiquidSurfaceLevel.card:
        topColor = const Color(0xFF161616);
        bottomColor = const Color(0xFF0E0E0E);
        borderColor = LiquidColors.borderMedium;
        shadows = LiquidDecorations.subtleDepth;
        meniscusOpacity = 0.45;
        break;
      case LiquidSurfaceLevel.elevated:
        topColor = const Color(0xFF222222);
        bottomColor = const Color(0xFF141414);
        borderColor = LiquidColors.borderSpecular;
        shadows = LiquidDecorations.dropletGlow();
        meniscusOpacity = 0.60;
        break;
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              gradient:
                  customGradient ??
                  LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [topColor, bottomColor],
                  ),
              border:
                  customBorder ?? Border.all(color: borderColor, width: 1.0),
            ),
            child: Stack(
              children: [
                // Directional top-edge specular meniscus highlight
                if (showMeniscus)
                  Positioned(
                    top: 0,
                    left: 14.0,
                    right: 14.0,
                    height: 1.2,
                    child: Container(
                      decoration: LiquidDecorations.meniscusDecoration(
                        opacity: meniscusOpacity,
                      ),
                    ),
                  ),

                // Main body
                Padding(
                  padding: padding ?? const EdgeInsets.all(16.0),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
