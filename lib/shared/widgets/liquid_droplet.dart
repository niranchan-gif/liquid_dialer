import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/liquid_theme.dart';

/// Organic liquid water droplet container with specular rim light and internal liquid depth.
class LiquidDroplet extends StatelessWidget {
  const LiquidDroplet({
    super.key,
    required this.child,
    this.size = 48.0,
    this.width,
    this.height,
    this.borderRadius,
    this.isCircle = true,
    this.surfaceColor = const Color(0xFF161616),
    this.bottomColor = const Color(0xFF0E0E0E),
    this.borderColor = const Color(0x30FFFFFF),
    this.glowColor = const Color(0x20FFFFFF),
    this.showRimLight = true,
    this.padding,
  });

  final Widget child;
  final double size;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Color surfaceColor;
  final Color bottomColor;
  final Color borderColor;
  final Color glowColor;
  final bool showRimLight;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;
    final effectiveRadius = isCircle
        ? BorderRadius.circular(effectiveWidth / 2)
        : (borderRadius ?? BorderRadius.circular(16.0));

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : effectiveRadius,
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 12.0,
            spreadRadius: 0.5,
            offset: const Offset(0, 1),
          ),
          const BoxShadow(
            color: Color(0x66000000),
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : effectiveRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [surfaceColor, bottomColor],
              ),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Stack(
              children: [
                // Directional top-edge specular meniscus highlight
                if (showRimLight)
                  Positioned(
                    top: 0,
                    left: effectiveWidth * 0.2,
                    right: effectiveWidth * 0.2,
                    height: 1.2,
                    child: Container(
                      decoration: LiquidDecorations.meniscusDecoration(
                        opacity: 0.55,
                      ),
                    ),
                  ),

                Center(
                  child: Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: child,
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
