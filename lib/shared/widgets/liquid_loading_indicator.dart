import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/liquid_theme.dart';

/// Fluid water-droplet pulsating loading indicator.
///
/// Features three harmonic liquid droplets that float and pulsate with surface tension ripples.
class LiquidLoadingIndicator extends StatefulWidget {
  const LiquidLoadingIndicator({
    super.key,
    this.size = 48.0,
    this.color = LiquidColors.silverHighlight,
    this.label,
  });

  final double size;
  final Color color;
  final String? label;

  @override
  State<LiquidLoadingIndicator> createState() => _LiquidLoadingIndicatorState();
}

class _LiquidLoadingIndicatorState extends State<LiquidLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (disableAnimations) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.6),
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: 12.0),
              Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: LiquidColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final phase = index * (math.pi / 2.5);
                  final progress =
                      (_controller.value * 2 * math.pi + phase) % (2 * math.pi);
                  final scale = 0.65 + 0.35 * (math.sin(progress) + 1) / 2;
                  final opacity = 0.30 + 0.65 * (math.sin(progress) + 1) / 2;
                  final yOffset = -4.0 * math.sin(progress);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: widget.size * 0.22,
                          height: widget.size * 0.22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                widget.color.withValues(alpha: opacity),
                                widget.color.withValues(alpha: opacity * 0.4),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: opacity * 0.5,
                              ),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(
                                  alpha: opacity * 0.3,
                                ),
                                blurRadius: 8.0,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          if (widget.label != null) ...[
            const SizedBox(height: 14.0),
            Text(
              widget.label!,
              style: const TextStyle(
                fontSize: 13.0,
                color: LiquidColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
