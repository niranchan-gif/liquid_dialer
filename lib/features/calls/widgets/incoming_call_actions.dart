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
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.05).animate(
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
        colors: [Color(0xFF22382B), Color(0xFF14241B)],
      ),
      borderColor: const Color(0x6034D399),
      glowColor: const Color(0x2834D399),
      iconColor: const Color(0xFFF4F4F4),
      labelColor: GlassColors.textPrimary,
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
            colors: [Color(0xFF381F1F), Color(0xFF241313)],
          ),
          borderColor: const Color(0x60F87171),
          glowColor: const Color(0x28EF4444),
          iconColor: const Color(0xFFF4F4F4),
          labelColor: GlassColors.textSecondary,
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
    required this.borderColor,
    required this.glowColor,
    required this.onTap,
    this.iconColor = Colors.white,
    this.labelColor = GlassColors.textPrimary,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color borderColor;
  final Color glowColor;
  final Color iconColor;
  final Color labelColor;
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
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 20.0,
                    spreadRadius: 1.5,
                  ),
                  const BoxShadow(
                    color: Color(0x70000000),
                    blurRadius: 12.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 26.0,
                        height: 26.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Color(0xFFF4F4F4),
                        ),
                      )
                    : Icon(icon, color: iconColor, size: 30.0),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
