import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/glass_styles.dart';

/// Interactive liquid glass dialer key with organic squircle geometry,
/// specular meniscus reflection, and tactile water-drop ripple motion.
class GlassKey extends StatefulWidget {
  const GlassKey({
    super.key,
    required this.digit,
    this.letters,
    required this.onTap,
    this.onLongPress,
    this.size = 72.0,
    this.semanticLabel,
  });

  /// Primary digit or symbol character ('1', '2', '*', '0', '#').
  final String digit;

  /// Secondary letters label ('ABC', 'DEF', '+') or null for keys without subtext.
  final String? letters;

  /// Callback when key is tapped.
  final VoidCallback onTap;

  /// Optional long press callback (e.g., holding '0' to input '+').
  final VoidCallback? onLongPress;

  /// Base dimension (width/height) of the squircle key.
  final double size;

  /// Semantic description for accessibility.
  final String? semanticLabel;

  @override
  State<GlassKey> createState() => _GlassKeyState();
}

class _GlassKeyState extends State<GlassKey> with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _rippleController;
  late final Animation<double> _scaleAnimation;
  Offset _rippleOrigin = const Offset(36.0, 36.0);
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
      _rippleOrigin = details.localPosition;
    });
    _scaleController.forward();
    _rippleController.forward(from: 0.0);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    widget.onTap();
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
    final effectiveSemanticLabel =
        widget.semanticLabel ??
        (widget.letters != null && widget.letters!.isNotEmpty
            ? '${widget.digit}, ${widget.letters}'
            : widget.digit);

    const cornerRadius = 21.0;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: effectiveSemanticLabel,
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
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              boxShadow: _isPressed
                  ? const [
                      BoxShadow(
                        color: Color(0x22FFFFFF),
                        blurRadius: 14.0,
                        spreadRadius: 0.5,
                      ),
                      BoxShadow(
                        color: Color(0x77000000),
                        blurRadius: 8.0,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cornerRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: GlassDecorations.keyBlurSigma,
                  sigmaY: GlassDecorations.keyBlurSigma,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _isPressed
                          ? const [Color(0xFF262626), Color(0xFF141414)]
                          : const [Color(0xFF191919), Color(0xFF0F0F0F)],
                    ),
                    border: Border.all(
                      color: _isPressed
                          ? const Color(0x50FFFFFF)
                          : const Color(0x22FFFFFF),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top liquid meniscus specular highlight
                      Positioned(
                        top: 0,
                        left: 12,
                        right: 12,
                        height: 1.5,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0x40FFFFFF),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Fluid water droplet ripple wave
                      AnimatedBuilder(
                        animation: _rippleController,
                        builder: (context, _) {
                          if (_rippleController.value == 0.0 ||
                              _rippleController.isCompleted) {
                            return const SizedBox.shrink();
                          }
                          return CustomPaint(
                            size: Size(widget.size, widget.size),
                            painter: _WaterDropRipplePainter(
                              progress: _rippleController.value,
                              origin: _rippleOrigin,
                            ),
                          );
                        },
                      ),

                      // Digit and Secondary Letters
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.digit,
                              style: TextStyle(
                                fontSize:
                                    widget.digit == '*' || widget.digit == '#'
                                    ? 28.0
                                    : 25.0,
                                fontWeight: FontWeight.w500,
                                color: _isPressed
                                    ? Colors.white
                                    : GlassColors.textPrimary,
                                height: 1.0,
                              ),
                            ),
                            if (widget.letters != null &&
                                widget.letters!.isNotEmpty) ...[
                              const SizedBox(height: 3.5),
                              Text(
                                widget.letters!,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: _isPressed
                                      ? GlassColors.silverHighlight
                                      : GlassColors.textSecondary,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ],
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
  }
}

/// Custom painter for the organic liquid water-drop expanding ripple wave.
class _WaterDropRipplePainter extends CustomPainter {
  const _WaterDropRipplePainter({required this.progress, required this.origin});

  final double progress;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = size.longestSide * 0.9;
    final currentRadius = lerpDouble(
      4.0,
      maxRadius,
      Curves.easeOutQuad.transform(progress),
    )!;
    final alpha = ((1.0 - progress) * 0.35).clamp(0.0, 1.0);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(255, 255, 255, alpha * 0.8),
          Color.fromRGBO(255, 255, 255, alpha * 0.2),
          const Color(0x00FFFFFF),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: origin, radius: currentRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(origin, currentRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterDropRipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.origin != origin;
  }
}
