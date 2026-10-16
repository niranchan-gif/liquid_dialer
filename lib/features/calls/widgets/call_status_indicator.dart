import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';
import '../models/call_state.dart';

/// Specular Liquid Glass pill indicator reflecting current Telecom call state.
class CallStatusIndicator extends StatefulWidget {
  const CallStatusIndicator({super.key, required this.state, this.customText});

  final CallState state;
  final String? customText;

  @override
  State<CallStatusIndicator> createState() => _CallStatusIndicatorState();
}

class _CallStatusIndicatorState extends State<CallStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.state) {
      case CallState.active:
        return GlassColors.mintLight;
      case CallState.incoming:
        return GlassColors.cyanAccent;
      case CallState.dialing:
      case CallState.connecting:
        return GlassColors.icyBlue;
      case CallState.holding:
        return GlassColors.softViolet;
      case CallState.disconnected:
      case CallState.disconnecting:
        return GlassColors.danger;
      case CallState.unknown:
        return GlassColors.textMuted;
    }
  }

  String get _statusLabel {
    if (widget.customText != null) return widget.customText!;
    switch (widget.state) {
      case CallState.active:
        return 'ACTIVE CALL';
      case CallState.incoming:
        return 'INCOMING CELLULAR CALL';
      case CallState.dialing:
        return 'DIALING...';
      case CallState.connecting:
        return 'CONNECTING...';
      case CallState.holding:
        return 'ON HOLD';
      case CallState.disconnected:
        return 'CALL ENDED';
      case CallState.disconnecting:
        return 'DISCONNECTING...';
      case CallState.unknown:
        return 'CALL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final dot = Container(
      width: 7.0,
      height: 7.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 6.0, spreadRadius: 1.0),
        ],
      ),
    );

    return Semantics(
      label: 'Call status: $_statusLabel',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: GlassColors.surfaceOverlay,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            disableAnimations
                ? dot
                : FadeTransition(opacity: _pulseAnimation, child: dot),
            const SizedBox(width: 8.0),
            Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
