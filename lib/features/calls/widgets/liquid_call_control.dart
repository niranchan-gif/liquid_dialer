import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/liquid_theme.dart';
import '../../../shared/widgets/glass_key.dart';

/// Reusable circular water-droplet control for active call operations (mute, speaker, hold, keypad).
class LiquidCallControl extends StatefulWidget {
  const LiquidCallControl({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor = LiquidColors.silverAccent,
    this.isDisabled = false,
    this.size = 64.0,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final bool isDisabled;
  final double size;

  @override
  State<LiquidCallControl> createState() => _LiquidCallControlState();
}

class _LiquidCallControlState extends State<LiquidCallControl>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _rippleController;
  late final Animation<double> _scaleAnimation;
  Offset _rippleOrigin = const Offset(32.0, 32.0);
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: LiquidMotion.pressDuration,
      reverseDuration: LiquidMotion.releaseDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
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
    if (widget.isDisabled) return;
    setState(() {
      _isPressed = true;
      _rippleOrigin = details.localPosition;
    });
    _scaleController.forward();
    _rippleController.forward(from: 0.0);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isDisabled) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final activeBg = widget.isActive
        ? const Color(0xFF262626)
        : const Color(0xFF121212);
    final borderColor = widget.isActive
        ? const Color(0x60FFFFFF)
        : (widget.isDisabled
              ? const Color(0x10FFFFFF)
              : const Color(0x28FFFFFF));
    final iconColor = widget.isDisabled
        ? LiquidColors.textMuted.withValues(alpha: 0.5)
        : (widget.isActive ? widget.activeColor : LiquidColors.textPrimary);

    return Semantics(
      button: true,
      label: widget.label,
      enabled: !widget.isDisabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: widget.isDisabled ? null : _handleTapDown,
            onTapUp: widget.isDisabled ? null : _handleTapUp,
            onTapCancel: widget.isDisabled ? null : _handleTapCancel,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isDisabled ? 1.0 : _scaleAnimation.value,
                  child: child,
                );
              },
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: widget.isActive || _isPressed
                      ? [
                          BoxShadow(
                            color: widget.isActive
                                ? widget.activeColor.withValues(alpha: 0.25)
                                : const Color(0x20FFFFFF),
                            blurRadius: 16.0,
                            spreadRadius: 1.0,
                          ),
                        ]
                      : LiquidDecorations.subtleDepth,
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            activeBg,
                            widget.isActive
                                ? const Color(0xFF161616)
                                : const Color(0xFF090909),
                          ],
                        ),
                        border: Border.all(color: borderColor, width: 1.2),
                      ),
                      child: Stack(
                        children: [
                          // Top specular meniscus line on the droplet
                          Positioned(
                            top: 0,
                            left: widget.size * 0.25,
                            right: widget.size * 0.25,
                            height: 1.2,
                            child: Container(
                              decoration: LiquidDecorations.meniscusDecoration(
                                opacity: widget.isActive ? 0.70 : 0.40,
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
                                size: Size(widget.size, widget.size),
                                painter: WaterDropRipplePainter(
                                  progress: _rippleController.value,
                                  origin: _rippleOrigin,
                                ),
                              );
                            },
                          ),

                          Center(
                            child: Icon(
                              widget.icon,
                              color: iconColor,
                              size: widget.size * 0.40,
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
          const SizedBox(height: 8.0),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: widget.isDisabled
                  ? LiquidColors.textMuted
                  : LiquidColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
