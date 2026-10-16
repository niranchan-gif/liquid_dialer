import 'package:flutter/material.dart';

/// Design tokens and styling utilities for the Premium AMOLED Liquid Glass visual theme.
///
/// Designed with true AMOLED black base (#000000), near-black secondary surfaces (#090909, #101010),
/// layered graphite grey keypad buttons, delicate silver-grey borders, and soft white typography.
class GlassColors {
  GlassColors._();

  // Background tones — True AMOLED Black (#000000) and Raised Surfaces (#090909, #101010, #171717)
  static const Color background = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF090909);
  static const Color surfaceElevated = Color(0xFF101010);
  static const Color surfaceMid = Color(0xFF101010);
  static const Color surfaceHigh = Color(0xFF171717);
  static const Color cardFill = Color(0xFF171717);
  static const Color surfaceOverlay = Color(0x12FFFFFF);

  // Graphite Grey Keypad surfaces
  static const Color graphiteBase = Color(0xFF141414);
  static const Color graphiteSurface = Color(0xFF181818);
  static const Color graphiteHover = Color(0xFF222222);
  static const Color graphitePressed = Color(0xFF2A2A2A);

  // Glass panel fills (translucent)
  static const Color glassFillLight = Color(0x14FFFFFF); // 8% white
  static const Color glassFillUltraLight = Color(0x0AFFFFFF); // 4% white
  static const Color glassFillDark = Color(0x33000000); // 20% black

  // Delicate silver-grey borders and specular highlights
  static const Color borderLight = Color(0x24FFFFFF); // 14% white
  static const Color borderSubtle = Color(0x12FFFFFF); // 7% white
  static const Color specularHighlight = Color(
    0x3DFFFFFF,
  ); // 24% white highlight
  static const Color specularTopEdge = Color(
    0x59FFFFFF,
  ); // 35% white reflective top edge

  // Restrained cool silver highlights (Monochrome — No neon / colourful gradients)
  static const Color silverAccent = Color(0xFFE2E8F0);
  static const Color silverHighlight = Color(0xFFCBD5E1);
  static const Color silverSubtle = Color(0xFF94A3B8);

  // Backward compatibility alias bindings to maintain clean compilation
  static const Color cyanAccent = Color(0xFFE2E8F0);
  static const Color icyBlue = Color(0xFFCBD5E1);
  static const Color softViolet = Color(0xFF94A3B8);
  static const Color deepViolet = Color(0xFF64748B);

  // Call action colors — Refined monochrome graphite & restrained accents
  static const Color callButtonBg = Color(0xFF1E1E1E);
  static const Color callButtonPressed = Color(0xFF303030);
  static const Color mintPrimary = Color(0xFFE2E8F0);
  static const Color mintLight = Color(0xFFF1F5F9);
  static const Color mintDark = Color(0xFF262626);
  static const Color mintGlow = Color(0x26FFFFFF); // Soft cool silver glow

  // Call answer & decline refined tones
  static const Color callAnswerBg = Color(0xFF1B2E24);
  static const Color callAnswerBorder = Color(0x5534D399);
  static const Color callDeclineBg = Color(0xFF331A1A);
  static const Color callDeclineBorder = Color(0x55F87171);

  // Text colors — Soft white (#F4F4F4) and muted greys (#969696)
  static const Color textPrimary = Color(0xFFF4F4F4); // Soft white
  static const Color textSecondary = Color(0xFF969696); // Muted grey
  static const Color textMuted = Color(0xFF5A5A5A); // Deep muted grey

  // Destructive / clear
  static const Color danger = Color(0xFFEF4444);
}

/// Gradients and decorations for liquid glass panels, keys, and buttons.
class GlassDecorations {
  GlassDecorations._();

  /// Default blur sigma for glass backdrops (balanced for visual clarity and 120Hz performance).
  static const double defaultBlurSigma = 12.0;
  static const double keyBlurSigma = 8.0;

  /// Translucent glass gradient fill
  static LinearGradient get panelFillGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x16FFFFFF), // ~9% white at top-left
      Color(0x06FFFFFF), // ~2% white at bottom-right
    ],
  );

  /// Keypad button resting graphite gradient with top specular illumination
  static LinearGradient get keyRestingGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1C1C1C), // Layered graphite top
      Color(0xFF121212), // Deeper graphite bottom
    ],
  );

  /// Keypad button pressed graphite gradient (subtle surface brightening)
  static LinearGradient get keyPressedGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2C2C2C), // Brightened graphite top
      Color(0xFF1E1E1E), // Brightened graphite bottom
    ],
  );

  /// Monochrome Call button resting gradient
  static LinearGradient get callButtonGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2A2A2A), // Silver-lit graphite top
      Color(0xFF161616), // Deep graphite bottom
    ],
  );

  /// Monochrome Call button pressed gradient
  static LinearGradient get callButtonPressedGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF383838), Color(0xFF222222)],
  );

  /// Subtle specular border decoration
  static Border get specularBorder =>
      Border.all(color: GlassColors.borderLight, width: 1.0);

  /// Subtle key border
  static Border get keyBorder =>
      Border.all(color: GlassColors.borderLight, width: 1.0);

  /// Soft ambient shadow for depth
  static List<BoxShadow> get subtleShadow => [
    const BoxShadow(
      color: Color(0x66000000),
      blurRadius: 14.0,
      spreadRadius: -2.0,
      offset: Offset(0, 6),
    ),
  ];

  /// Restrained silver call button aura glow
  static List<BoxShadow> get callButtonGlow => [
    const BoxShadow(
      color: Color(0x26FFFFFF),
      blurRadius: 20.0,
      spreadRadius: 1.0,
      offset: Offset(0, 4),
    ),
  ];

  /// Active tab indicator glow
  static List<BoxShadow> get tabActiveGlow => [
    const BoxShadow(
      color: Color(0x1FFFFFFF),
      blurRadius: 10.0,
      spreadRadius: 1.0,
      offset: Offset(0, 2),
    ),
  ];
}
