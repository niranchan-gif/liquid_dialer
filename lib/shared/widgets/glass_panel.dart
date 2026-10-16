import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/glass_styles.dart';

/// Reusable Liquid Glass container widget.
///
/// Features a translucent background, controlled background blur via [BackdropFilter],
/// a delicate specular border, and soft depth shadows.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.blurSigma = GlassDecorations.defaultBlurSigma,
    this.border,
    this.gradient,
    this.boxShadow,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final BoxBorder? border;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(24.0);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: boxShadow ?? GlassDecorations.subtleShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              gradient: gradient ?? GlassDecorations.panelFillGradient,
              border: border ?? GlassDecorations.specularBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
