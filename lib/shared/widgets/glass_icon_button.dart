import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/glass_styles.dart';

/// Circular or rounded glass icon button for shortcuts, actions, and navigation.
class GlassIconButton extends StatefulWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.onLongPress,
    this.size = 46.0,
    this.iconSize = 22.0,
    this.iconColor,
    this.tooltip,
    this.semanticLabel,
    this.activeGlow = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final String? tooltip;
  final String? semanticLabel;
  final bool activeGlow;

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.90,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap!();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      HapticFeedback.mediumImpact();
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.iconColor ??
        (_isPressed ? GlassColors.cyanAccent : GlassColors.textPrimary);

    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    Widget buttonWidget = Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.tooltip,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onLongPress: widget.onLongPress != null ? _handleLongPress : null,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final scale = disableAnimations ? 1.0 : _scaleAnimation.value;
              return Transform.scale(scale: scale, child: child);
            },
            child: Center(
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: widget.activeGlow || _isPressed
                      ? [
                          BoxShadow(
                            color: widget.activeGlow
                                ? GlassColors.icyBlue.withValues(alpha: 0.3)
                                : GlassColors.cyanAccent.withValues(
                                    alpha: 0.25,
                                  ),
                            blurRadius: 14.0,
                            spreadRadius: 1.0,
                          ),
                        ]
                      : GlassDecorations.subtleShadow,
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: GlassDecorations.keyBlurSigma,
                      sigmaY: GlassDecorations.keyBlurSigma,
                    ),
                    child: AnimatedContainer(
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 140),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _isPressed
                            ? GlassDecorations.keyPressedGradient
                            : GlassDecorations.keyRestingGradient,
                        border: Border.all(
                          color: _isPressed
                              ? GlassColors.cyanAccent.withValues(alpha: 0.6)
                              : GlassColors.borderLight,
                          width: 1.1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          size: widget.iconSize,
                          color: effectiveColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: buttonWidget);
    }
    return buttonWidget;
  }
}
