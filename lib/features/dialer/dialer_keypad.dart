import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/glass_styles.dart';
import '../../shared/widgets/glass_key.dart';
import 'dialer_controller.dart';

/// Key specification data model for keypad buttons.
class KeypadKeySpec {
  const KeypadKeySpec({required this.digit, this.letters, this.longPressChar});

  final String digit;
  final String? letters;
  final String? longPressChar;
}

/// 3-column keypad with 1-9, *, 0, # and a prominent mint/emerald call action.
class DialerKeypad extends StatelessWidget {
  const DialerKeypad({super.key, required this.controller, this.onCallMessage});

  final DialerController controller;

  /// Optional callback invoked with the call feedback message.
  final void Function(String message)? onCallMessage;

  static const List<KeypadKeySpec> keys = [
    KeypadKeySpec(digit: '1'),
    KeypadKeySpec(digit: '2', letters: 'ABC'),
    KeypadKeySpec(digit: '3', letters: 'DEF'),
    KeypadKeySpec(digit: '4', letters: 'GHI'),
    KeypadKeySpec(digit: '5', letters: 'JKL'),
    KeypadKeySpec(digit: '6', letters: 'MNO'),
    KeypadKeySpec(digit: '7', letters: 'PQRS'),
    KeypadKeySpec(digit: '8', letters: 'TUV'),
    KeypadKeySpec(digit: '9', letters: 'WXYZ'),
    KeypadKeySpec(digit: '*'),
    KeypadKeySpec(digit: '0', letters: '+', longPressChar: '+'),
    KeypadKeySpec(digit: '#'),
  ];

  Future<void> _handleCall(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final message = await controller.call();

    if (context.mounted) {
      if (onCallMessage != null) {
        onCallMessage!(message);
      } else {
        final isSuccess = message.toLowerCase().contains('initiated');
        final isWarning =
            message.toLowerCase().contains('enter') ||
            message.toLowerCase().contains('already');
        final iconData = isSuccess
            ? Icons.phone_in_talk_rounded
            : (isWarning
                  ? Icons.info_outline_rounded
                  : Icons.error_outline_rounded);
        final iconColor = isSuccess
            ? GlassColors.silverHighlight
            : (isWarning ? GlassColors.silverAccent : GlassColors.danger);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: GlassColors.surfaceDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: const BorderSide(
                color: GlassColors.borderSubtle,
                width: 1.0,
              ),
            ),
            content: Row(
              children: [
                Icon(iconData, color: iconColor, size: 20.0),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: GlassColors.textPrimary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keySize = (screenWidth * 0.17).clamp(58.0, 72.0);
    final horizontalSpacing = (screenWidth * 0.05).clamp(12.0, 26.0);
    const verticalSpacing = 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 4 rows of 3 columns
        for (int row = 0; row < 4; row++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int col = 0; col < 3; col++) ...[
                if (col > 0) SizedBox(width: horizontalSpacing),
                () {
                  final spec = keys[row * 3 + col];
                  return GlassKey(
                    key: Key('keypad_${spec.digit}'),
                    digit: spec.digit,
                    letters: spec.letters,
                    size: keySize,
                    onTap: () => controller.appendDigit(spec.digit),
                    onLongPress: spec.longPressChar != null
                        ? () => controller.appendDigit(spec.longPressChar!)
                        : null,
                  );
                }(),
              ],
            ],
          ),
          const SizedBox(height: verticalSpacing),
        ],

        const SizedBox(height: 8.0),

        // Call Action Button
        _CallActionButton(size: keySize, onTap: () => _handleCall(context)),
      ],
    );
  }
}

/// Dedicated monochrome call action button with layered graphite gradient,
/// reflective specular meniscus, silver aura glow, and tactile feedback.
class _CallActionButton extends StatefulWidget {
  const _CallActionButton({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  State<_CallActionButton> createState() => _CallActionButtonState();
}

class _CallActionButtonState extends State<_CallActionButton>
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
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    const cornerRadius = 24.0;

    return Semantics(
      button: true,
      label: 'Place call',
      child: GestureDetector(
        key: const Key('callButton'),
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: Container(
            width: widget.size * 1.15,
            height: widget.size * 0.92,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              boxShadow: _isPressed
                  ? const [
                      BoxShadow(
                        color: Color(0x35FFFFFF),
                        blurRadius: 22.0,
                        spreadRadius: 1.5,
                        offset: Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Color(0x88000000),
                        blurRadius: 12.0,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : GlassDecorations.callButtonGlow,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                gradient: _isPressed
                    ? GlassDecorations.callButtonPressedGradient
                    : GlassDecorations.callButtonGradient,
                border: Border.all(
                  color: _isPressed
                      ? const Color(0x60FFFFFF)
                      : const Color(0x30FFFFFF),
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [
                  // Specular meniscus highlight at top edge
                  Positioned(
                    top: 0,
                    left: 16,
                    right: 16,
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
                  const Center(
                    child: Icon(
                      Icons.phone_rounded,
                      color: GlassColors.textPrimary,
                      size: 28.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
