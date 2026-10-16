import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/liquid_theme.dart';
import '../../shared/widgets/glass_key.dart';
import 'dialer_controller.dart';

/// Key specification data model for keypad buttons.
class KeypadKeySpec {
  const KeypadKeySpec({required this.digit, this.letters, this.longPressChar});

  final String digit;
  final String? letters;
  final String? longPressChar;
}

/// 3-column keypad matching the reference design with circular dark graphite keys,
/// glowing pressed droplet halos, wide pill-shaped liquid call button, and add-contact/backspace actions.
class DialerKeypad extends StatelessWidget {
  const DialerKeypad({
    super.key,
    required this.controller,
    this.onCallMessage,
    this.onAddContact,
  });

  final DialerController controller;
  final void Function(String message)? onCallMessage;
  final VoidCallback? onAddContact;

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
            ? LiquidColors.silverHighlight
            : (isWarning ? LiquidColors.silverAccent : LiquidColors.callRed);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: LiquidColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: const BorderSide(
                color: LiquidColors.borderSubtle,
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
                      color: LiquidColors.textPrimary,
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
    final keySize = (screenWidth * 0.175).clamp(60.0, 74.0);
    final horizontalSpacing = (screenWidth * 0.055).clamp(14.0, 28.0);
    const verticalSpacing = 11.0;

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

        const SizedBox(height: 10.0),

        // Bottom Action Row: Add Contact (Left), Liquid Call Pill (Center), Delete Button (Right)
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final hasNumber = controller.hasNumber;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left: Add contact action
                SizedBox(
                  width: keySize,
                  height: keySize * 0.85,
                  child: Center(
                    child: _CircleDropletButton(
                      key: const Key('keypadAddContactButton'),
                      size: keySize * 0.76,
                      icon: Icons.person_add_outlined,
                      tooltip: 'Add contact',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onAddContact?.call();
                      },
                    ),
                  ),
                ),

                SizedBox(width: horizontalSpacing),

                // Center: Signature wide pill liquid call button
                _LiquidCallPillButton(
                  width: keySize * 1.35,
                  height: keySize * 0.86,
                  onTap: () => _handleCall(context),
                ),

                SizedBox(width: horizontalSpacing),

                // Right: Backspace / delete button
                SizedBox(
                  width: keySize,
                  height: keySize * 0.85,
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: hasNumber ? 1.0 : 0.45,
                      child: _CircleDropletButton(
                        key: const Key('keypadDeleteButton'),
                        size: keySize * 0.76,
                        icon: Icons.backspace_outlined,
                        tooltip: 'Delete',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.deleteDigit();
                        },
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          controller.clearNumber();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Wide pill-shaped liquid mercury call button with top specular meniscus and internal depth.
class _LiquidCallPillButton extends StatefulWidget {
  const _LiquidCallPillButton({
    required this.width,
    required this.height,
    required this.onTap,
  });

  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  State<_LiquidCallPillButton> createState() => _LiquidCallPillButtonState();
}

class _LiquidCallPillButtonState extends State<_LiquidCallPillButton>
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
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Place call',
      child: GestureDetector(
        key: const Key('callButton'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
          HapticFeedback.mediumImpact();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow: [
                BoxShadow(
                  color: _isPressed
                      ? const Color(0x60FFFFFF)
                      : const Color(0x35FFFFFF),
                  blurRadius: _isPressed ? 22.0 : 16.0,
                  spreadRadius: _isPressed ? 2.0 : 0.5,
                  offset: const Offset(0, 2),
                ),
                const BoxShadow(
                  color: Color(0x90000000),
                  blurRadius: 14.0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Base liquid graphite/mercury surface
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _isPressed
                          ? const [Color(0xFF383838), Color(0xFF202020)]
                          : const [Color(0xFF282828), Color(0xFF141414)],
                    ),
                    border: Border.all(
                      color: _isPressed
                          ? const Color(0x80FFFFFF)
                          : const Color(0x45FFFFFF),
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.phone_rounded,
                      color: Color(0xFFF5F5F5),
                      size: 24.0,
                    ),
                  ),
                ),

                // Top specular meniscus crescent
                Positioned(
                  top: 0,
                  left: widget.width * 0.18,
                  right: widget.width * 0.18,
                  height: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.0),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0x90FFFFFF),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular dark droplet button used for secondary keypad actions (Add contact & Delete).
class _CircleDropletButton extends StatefulWidget {
  const _CircleDropletButton({
    super.key,
    required this.size,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.onLongPress,
  });

  final double size;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<_CircleDropletButton> createState() => _CircleDropletButtonState();
}

class _CircleDropletButtonState extends State<_CircleDropletButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
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

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _controller.forward(),
        onTap: () {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        onLongPress: widget.onLongPress != null
            ? () {
                _controller.reverse();
                widget.onLongPress!();
              }
            : null,
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
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF222222), Color(0xFF101010)],
              ),
              border: Border.all(color: const Color(0x30FFFFFF), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x60000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: LiquidColors.textSecondary,
                size: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
