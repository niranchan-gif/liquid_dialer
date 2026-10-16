import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/liquid_theme.dart';
import 'glass_key.dart';

/// Preset color themes for [LiquidButton].
enum LiquidButtonTheme {
  /// Layered dark graphite with silver meniscus reflection.
  graphite,

  /// Soft mint emerald for placing or answering calls.
  callGreen,

  /// Soft crimson for ending or declining calls.
  callRed,

  /// Translucent subtle graphite for secondary shortcuts.
  subtle,
}

/// Tactile liquid button with physical droplet compression and touch-centered water ripple.
class LiquidButton extends StatefulWidget {
  const LiquidButton({
    super.key,
    required this.onTap,
    this.onLongPress,
    this.child,
    this.label,
    this.icon,
    this.theme = LiquidButtonTheme.graphite,
    this.width,
    this.height = 54.0,
    this.borderRadius,
    this.isCircle = false,
    this.semanticLabel,
    this.tooltip,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? child;
  final String? label;
  final IconData? icon;
  final LiquidButtonTheme theme;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final String? semanticLabel;
  final String? tooltip;

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _rippleController;
  late final Animation<double> _scaleAnimation;
  Offset _rippleOrigin = const Offset(20.0, 20.0);
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: LiquidMotion.pressDuration,
      reverseDuration: LiquidMotion.releaseDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _scaleController, curve: LiquidMotion.easeOut),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: LiquidMotion.rippleDuration,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() {
      _isPressed = true;
      _rippleOrigin = details.localPosition;
    });
    _scaleController.forward();
    _rippleController.forward(from: 0.0);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
    widget.onTap!();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      HapticFeedback.mediumImpact();
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth =
        widget.width ?? (widget.isCircle ? widget.height : null);
    final effectiveHeight = widget.height;
    final effectiveRadius = widget.isCircle
        ? BorderRadius.circular(effectiveHeight / 2)
        : (widget.borderRadius ?? BorderRadius.circular(20.0));

    Color topColor;
    Color bottomColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    List<BoxShadow> shadows;

    switch (widget.theme) {
      case LiquidButtonTheme.graphite:
        topColor = _isPressed
            ? const Color(0xFF323232)
            : const Color(0xFF222222);
        bottomColor = _isPressed
            ? const Color(0xFF1E1E1E)
            : const Color(0xFF121212);
        borderColor = _isPressed
            ? const Color(0x60FFFFFF)
            : const Color(0x30FFFFFF);
        iconColor = LiquidColors.textPrimary;
        textColor = LiquidColors.textPrimary;
        shadows = LiquidDecorations.dropletGlow(
          glowColor: _isPressed
              ? const Color(0x35FFFFFF)
              : const Color(0x20FFFFFF),
        );
        break;
      case LiquidButtonTheme.callGreen:
        topColor = _isPressed
            ? const Color(0xFF1F4832)
            : const Color(0xFF153323);
        bottomColor = _isPressed
            ? const Color(0xFF142E20)
            : const Color(0xFF0E2217);
        borderColor = _isPressed
            ? const Color(0x8034D399)
            : const Color(0x5534D399);
        iconColor = LiquidColors.callGreen;
        textColor = LiquidColors.callGreen;
        shadows = LiquidDecorations.dropletGlow(
          glowColor: _isPressed
              ? const Color(0x4034D399)
              : const Color(0x2834D399),
        );
        break;
      case LiquidButtonTheme.callRed:
        topColor = _isPressed
            ? const Color(0xFF4A1C1C)
            : const Color(0xFF331414);
        bottomColor = _isPressed
            ? const Color(0xFF301212)
            : const Color(0xFF200C0C);
        borderColor = _isPressed
            ? const Color(0x80EF4444)
            : const Color(0x55EF4444);
        iconColor = LiquidColors.callRed;
        textColor = LiquidColors.callRed;
        shadows = LiquidDecorations.dropletGlow(
          glowColor: _isPressed
              ? const Color(0x40EF4444)
              : const Color(0x28EF4444),
        );
        break;
      case LiquidButtonTheme.subtle:
        topColor = _isPressed
            ? const Color(0xFF202020)
            : const Color(0xFF141414);
        bottomColor = _isPressed
            ? const Color(0xFF161616)
            : const Color(0xFF0A0A0A);
        borderColor = _isPressed
            ? const Color(0x40FFFFFF)
            : const Color(0x1AFFFFFF);
        iconColor = LiquidColors.silverSecondary;
        textColor = LiquidColors.silverSecondary;
        shadows = LiquidDecorations.subtleDepth;
        break;
    }

    Widget content;
    if (widget.child != null) {
      content = widget.child!;
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: iconColor, size: 20.0),
            if (widget.label != null) const SizedBox(width: 8.0),
          ],
          if (widget.label != null)
            Text(
              widget.label!,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
        ],
      );
    }

    Widget button = Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label ?? widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: Container(
            width: effectiveWidth,
            height: effectiveHeight,
            decoration: BoxDecoration(
              shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.isCircle ? null : effectiveRadius,
              boxShadow: shadows,
            ),
            child: ClipRRect(
              borderRadius: effectiveRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: widget.isCircle
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius: widget.isCircle ? null : effectiveRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [topColor, bottomColor],
                    ),
                    border: Border.all(color: borderColor, width: 1.0),
                  ),
                  child: Stack(
                    children: [
                      // Specular top meniscus reflection
                      Positioned(
                        top: 0,
                        left: 12.0,
                        right: 12.0,
                        height: 1.2,
                        child: Container(
                          decoration: LiquidDecorations.meniscusDecoration(
                            opacity: _isPressed ? 0.70 : 0.45,
                          ),
                        ),
                      ),

                      // Touch-centered water ripple animation
                      AnimatedBuilder(
                        animation: _rippleController,
                        builder: (context, _) {
                          if (_rippleController.value == 0.0 ||
                              _rippleController.isCompleted) {
                            return const SizedBox.shrink();
                          }
                          return CustomPaint(
                            size: Size(
                              effectiveWidth ?? 200.0,
                              effectiveHeight,
                            ),
                            painter: WaterDropRipplePainter(
                              progress: _rippleController.value,
                              origin: _rippleOrigin,
                            ),
                          );
                        },
                      ),

                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: content,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
