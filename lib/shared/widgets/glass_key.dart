import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/liquid_theme.dart';

/// Interactive circular liquid dialer key with pure water-droplet geometry,
/// top specular meniscus reflection, concentric ripple wave, and glowing touch aura.
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

  /// Base dimension (width/height) of the circular key.
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
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
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
              shape: BoxShape.circle,
              boxShadow: _isPressed
                  ? [
                      const BoxShadow(
                        color: Color(0x55FFFFFF),
                        blurRadius: 18.0,
                        spreadRadius: 1.5,
                      ),
                      const BoxShadow(
                        color: Color(0x90000000),
                        blurRadius: 10.0,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x60000000),
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _isPressed
                          ? const [Color(0xFF2C2C2C), Color(0xFF161616)]
                          : const [Color(0xFF1E1E1E), Color(0xFF101010)],
                    ),
                    border: Border.all(
                      color: _isPressed
                          ? const Color(0x75FFFFFF)
                          : const Color(0x28FFFFFF),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top liquid meniscus specular reflection
                      Positioned(
                        top: 0,
                        left: widget.size * 0.22,
                        right: widget.size * 0.22,
                        height: 1.5,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0x60FFFFFF),
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
                            painter: WaterDropRipplePainter(
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
                                    : 26.0,
                                fontWeight: FontWeight.w600,
                                color: _isPressed
                                    ? Colors.white
                                    : LiquidColors.textPrimary,
                                height: 1.0,
                              ),
                            ),
                            if (widget.letters != null &&
                                widget.letters!.isNotEmpty) ...[
                              const SizedBox(height: 3.0),
                              Text(
                                widget.letters!,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                  color: _isPressed
                                      ? LiquidColors.silverHighlight
                                      : LiquidColors.textSecondary,
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

/// Dynamic dual-concentric water ripple wave painter representing droplet impact
class WaterDropRipplePainter extends CustomPainter {
  const WaterDropRipplePainter({required this.progress, required this.origin});

  final double progress;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final maxRadius = size.longestSide * 0.75;
    final primaryRadius = maxRadius * progress;
    final secondaryRadius = primaryRadius * 0.70;

    // Primary wave crest (specular reflection)
    final primaryOpacity = (1.0 - progress).clamp(0.0, 1.0) * 0.35;
    final primaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * (1.0 - progress)
      ..color = Color.fromRGBO(255, 255, 255, primaryOpacity);

    canvas.drawCircle(origin, primaryRadius, primaryPaint);

    // Secondary concentric surface tension wave
    if (progress > 0.15) {
      final secondaryOpacity = (1.0 - progress).clamp(0.0, 1.0) * 0.20;
      final secondaryPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * (1.0 - progress)
        ..color = Color.fromRGBO(255, 255, 255, secondaryOpacity);

      canvas.drawCircle(origin, secondaryRadius, secondaryPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WaterDropRipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.origin != origin;
  }
}
