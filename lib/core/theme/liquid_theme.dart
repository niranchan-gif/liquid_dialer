import 'package:flutter/material.dart';

/// Design tokens and styling utilities for the Pure Liquid AMOLED design system.
///
/// Embodies the concept of water droplets flowing over pure black glass:
/// - Pure AMOLED black (#000000) base.
/// - Translucent near-black graphite surfaces (#080808, #101010, #171717).
/// - Restrained silver-grey specular reflections and top-edge water menisci.
/// - Tactile fluid compression and surface-tension ripples.
/// - Color reserved strictly for purposeful states (soft emerald call, soft crimson decline, gold star).
class LiquidColors {
  LiquidColors._();

  // Background — True AMOLED Black
  static const Color background = Color(0xFF000000);

  // Surfaces — Translucent Graphite layers
  static const Color surfaceBase = Color(0xFF080808);
  static const Color surfaceDark = Color(0xFF080808);
  static const Color surfaceCard = Color(0xFF101010);
  static const Color surfaceElevated = Color(0xFF161616);
  static const Color surfaceInteractive = Color(0xFF1C1C1C);
  static const Color surfaceInteractivePressed = Color(0xFF282828);

  // Borders & Specular edge reflections
  static const Color borderSubtle = Color(0x18FFFFFF); // 9% white
  static const Color borderMedium = Color(0x28FFFFFF); // 16% white
  static const Color borderSpecular = Color(0x45FFFFFF); // 27% white
  static const Color meniscusHighlight = Color(
    0x60FFFFFF,
  ); // 38% reflective white
  static const Color specularMeniscus = Color(0x60FFFFFF);

  // Text & Typography tones
  static const Color textPrimary = Color(0xFFF4F4F4); // Crisp soft white
  static const Color textSecondary = Color(0xFF989898); // Cool mist grey
  static const Color textMuted = Color(0xFF5E5E5E); // Deep muted grey

  // Accent Tones — Reserved and intentional
  static const Color silverPrimary = Color(0xFFF4F4F4);
  static const Color silverHighlight = Color(0xFFCBD5E1);
  static const Color silverAccent = Color(0xFFE2E8F0);
  static const Color silverSecondary = Color(0xFFE2E8F0);
  static const Color silverMist = Color(0xFF94A3B8);
  static const Color mistGrey = Color(0xFF94A3B8);

  // Call Action Colors
  static const Color callGreen = Color(0xFF34D399); // Soft mint emerald
  static const Color callGreenBg = Color(0xFF13281B);
  static const Color callGreenBorder = Color(0x5534D399);

  static const Color callRed = Color(0xFFEF4444); // Soft crimson
  static const Color callRedBg = Color(0xFF2B1313);
  static const Color callRedBorder = Color(0x55EF4444);

  // Favorite Star
  static const Color favoriteGold = Color(0xFFFBBF24);
}

/// Shared motion parameters and physics curves for the Liquid system.
class LiquidMotion {
  LiquidMotion._();

  static const Duration pressDuration = Duration(milliseconds: 90);
  static const Duration releaseDuration = Duration(milliseconds: 160);
  static const Duration rippleDuration = Duration(milliseconds: 320);
  static const Duration shortTransition = Duration(milliseconds: 200);
  static const Duration standardTransition = Duration(milliseconds: 260);
  static const Duration settleDuration = Duration(milliseconds: 340);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve settleCurve = Curves.easeOutQuad;
  static const Curve fluidCurve = Curves.easeInOutCubic;
}

/// Shared surface decorations, specular meniscus gradients, and soft droplet glow.
class LiquidDecorations {
  LiquidDecorations._();

  static const double defaultBlurSigma = 10.0;
  static const double keyBlurSigma = 8.0;

  /// Specular meniscus top-edge highlight representing light catching water surface tension.
  static BoxDecoration meniscusDecoration({double opacity = 0.5}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Color.fromRGBO(255, 255, 255, opacity),
          Colors.transparent,
        ],
      ),
    );
  }

  /// Droplet surface depth gradient with directional lighting from top-left.
  static LinearGradient dropletGradient({
    Color topColor = const Color(0xFF242424),
    Color bottomColor = const Color(0xFF101010),
  }) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, bottomColor],
    );
  }

  /// Gentle droplet ambient shadow (subtle edge elevation).
  static const List<BoxShadow> dropletShadow = [
    BoxShadow(color: Color(0x60000000), blurRadius: 10.0, offset: Offset(0, 3)),
  ];

  static const List<BoxShadow> subtleDepth = dropletShadow;

  /// Active droplet specular aura (subtle silver reflection).
  static const List<BoxShadow> specularAura = [
    BoxShadow(color: Color(0x30FFFFFF), blurRadius: 16.0, spreadRadius: 1.0),
  ];

  /// Droplet glow shadow for elevated states and active buttons.
  static List<BoxShadow> dropletGlow({
    Color glowColor = const Color(0x25FFFFFF),
    double blurRadius = 14.0,
    double spreadRadius = 1.0,
  }) {
    return [
      BoxShadow(
        color: glowColor,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}
