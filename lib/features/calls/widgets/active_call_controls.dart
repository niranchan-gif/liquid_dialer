import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/glass_styles.dart';
import '../models/audio_route.dart';
import 'audio_route_selector.dart';

/// Interactive 6-button control matrix and prominent End Call button for active calls.
class ActiveCallControls extends StatelessWidget {
  const ActiveCallControls({
    super.key,
    required this.isMuted,
    required this.isHolding,
    required this.audioState,
    required this.onToggleMute,
    required this.onToggleHold,
    required this.onSelectAudioRoute,
    required this.onEndCall,
    this.onToggleKeypad,
    this.isKeypadVisible = false,
    this.isEnding = false,
  });

  final bool isMuted;
  final bool isHolding;
  final AudioRouteState audioState;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleHold;
  final ValueChanged<AudioRoute> onSelectAudioRoute;
  final VoidCallback onEndCall;
  final VoidCallback? onToggleKeypad;
  final bool isKeypadVisible;
  final bool isEnding;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 2 rows of 3 glass buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute Button
            _ControlGridButton(
              key: const Key('activeCallMuteButton'),
              icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: isMuted ? 'Unmute' : 'Mute',
              isActive: isMuted,
              activeColor: GlassColors.danger,
              onTap: () {
                HapticFeedback.lightImpact();
                onToggleMute();
              },
            ),

            // Keypad Button
            _ControlGridButton(
              key: const Key('activeCallKeypadButton'),
              icon: Icons.dialpad_rounded,
              label: 'Keypad',
              isActive: isKeypadVisible,
              activeColor: GlassColors.silverAccent,
              onTap: () {
                HapticFeedback.lightImpact();
                onToggleKeypad?.call();
              },
            ),

            // Speaker / Audio Route Button
            _ControlGridButton(
              key: const Key('activeCallAudioRouteButton'),
              icon: _iconForRoute(audioState.currentRoute),
              label: audioState.isSpeakerOn ? 'Speaker' : 'Audio',
              isActive: audioState.isSpeakerOn,
              activeColor: GlassColors.silverAccent,
              onTap: () {
                HapticFeedback.lightImpact();
                if (audioState.supportedRoutes.length > 2) {
                  AudioRouteSelector.show(
                    context,
                    audioState: audioState,
                    onSelectRoute: onSelectAudioRoute,
                  );
                } else {
                  // Quick toggle between earpiece and speaker
                  final next = audioState.isSpeakerOn
                      ? AudioRoute.earpiece
                      : AudioRoute.speaker;
                  onSelectAudioRoute(next);
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 20.0),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Hold Button
            _ControlGridButton(
              key: const Key('activeCallHoldButton'),
              icon: isHolding ? Icons.play_arrow_rounded : Icons.pause_rounded,
              label: isHolding ? 'Resume' : 'Hold',
              isActive: isHolding,
              activeColor: GlassColors.silverHighlight,
              onTap: () {
                HapticFeedback.lightImpact();
                onToggleHold();
              },
            ),

            // Add Call Button (disabled indicator for single-party call)
            _ControlGridButton(
              key: const Key('activeCallAddButton'),
              icon: Icons.add_call,
              label: 'Add Call',
              isActive: false,
              isDisabled: true,
              onTap: () {},
            ),

            // Audio Selector button (direct route sheet)
            _ControlGridButton(
              key: const Key('activeCallRouteSheetButton'),
              icon: Icons.speaker_group_rounded,
              label: 'Outputs',
              isActive: false,
              onTap: () {
                HapticFeedback.lightImpact();
                AudioRouteSelector.show(
                  context,
                  audioState: audioState,
                  onSelectRoute: onSelectAudioRoute,
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 36.0),

        // End Call Button
        Semantics(
          button: true,
          label: 'End call',
          enabled: !isEnding,
          child: GestureDetector(
            key: const Key('activeCallEndButton'),
            onTap: isEnding
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    onEndCall();
                  },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 72.0,
              height: 72.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF381F1F), Color(0xFF241313)],
                ),
                border: Border.all(color: const Color(0x60F87171), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x28EF4444),
                    blurRadius: 20.0,
                    spreadRadius: 1.5,
                  ),
                  BoxShadow(
                    color: Color(0x70000000),
                    blurRadius: 12.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isEnding
                    ? const SizedBox(
                        width: 26.0,
                        height: 26.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Color(0xFFF4F4F4),
                        ),
                      )
                    : const Icon(
                        Icons.call_end_rounded,
                        color: Color(0xFFF4F4F4),
                        size: 30.0,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconForRoute(AudioRoute route) {
    switch (route) {
      case AudioRoute.speaker:
        return Icons.volume_up_rounded;
      case AudioRoute.bluetooth:
        return Icons.bluetooth_audio_rounded;
      case AudioRoute.wiredHeadset:
        return Icons.headphones_rounded;
      case AudioRoute.earpiece:
        return Icons.phone_android_rounded;
    }
  }
}

class _ControlGridButton extends StatelessWidget {
  const _ControlGridButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor = GlassColors.silverAccent,
    this.isDisabled = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
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
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? const Color(0xFF222222)
                    : const Color(0xFF101010),
                border: Border.all(
                  color: isActive
                      ? const Color(0x45FFFFFF)
                      : GlassColors.borderSubtle,
                  width: 1.2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0x20FFFFFF),
                          blurRadius: 16.0,
                          spreadRadius: 1.0,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isDisabled
                    ? GlassColors.textMuted.withValues(alpha: 0.5)
                    : (isActive ? activeColor : GlassColors.textPrimary),
                size: 26.0,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: isDisabled
                  ? GlassColors.textMuted
                  : GlassColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
