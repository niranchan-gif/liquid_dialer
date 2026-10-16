import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/glass_styles.dart';

/// Interactive Liquid Glass Answer and Decline action buttons for incoming calls.
class IncomingCallActions extends StatefulWidget {
  const IncomingCallActions({
    super.key,
    required this.onAnswer,
    required this.onReject,
    this.isAnswering = false,
    this.isRejecting = false,
  });

  final VoidCallback onAnswer;
  final VoidCallback onReject;
  final bool isAnswering;
  final bool isRejecting;

  @override
  State<IncomingCallActions> createState() => _IncomingCallActionsState();
}

class _IncomingCallActionsState extends State<IncomingCallActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = widget.isAnswering || widget.isRejecting;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final answerButton = _CallCircleButton(
      key: const Key('incomingAnswerButton'),
      label: 'Answer',
      icon: Icons.call_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [GlassColors.mintLight, GlassColors.mintPrimary],
      ),
      glowColor: GlassColors.mintGlow,
      isLoading: widget.isAnswering,
      isDisabled: isBusy,
      onTap: () {
        HapticFeedback.heavyImpact();
        widget.onAnswer();
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Decline Button
        _CallCircleButton(
          key: const Key('incomingDeclineButton'),
          label: 'Decline',
          icon: Icons.call_end_rounded,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          ),
          glowColor: const Color(0x60EF4444),
          isLoading: widget.isRejecting,
          isDisabled: isBusy,
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onReject();
          },
        ),

        // Answer Button (with subtle pulse animation or static if reduced-motion)
        disableAnimations
            ? answerButton
            : ScaleTransition(scale: _pulseScale, child: answerButton),
      ],
    );
  }
}

class _CallCircleButton extends StatelessWidget {
  const _CallCircleButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color glowColor;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: !isDisabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isDisabled ? null : onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 72.0,
              height: 72.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 20.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 28.0,
                        height: 28.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(icon, color: Colors.white, size: 32.0),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: GlassColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
