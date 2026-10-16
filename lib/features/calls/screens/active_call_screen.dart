import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';
import '../../../shared/widgets/glass_key.dart';
import '../call_controller.dart';
import '../models/call_session.dart';
import '../widgets/active_call_controls.dart';
import '../widgets/call_status_indicator.dart';

/// Full-screen Liquid Glass active-call screen for OnePlus Nord 4.
///
/// Features caller identity, duration timer calculated from Telecom connect timestamps,
/// mute, speaker, audio route selection, hold, and disconnect actions.
class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({
    super.key,
    required this.session,
    required this.controller,
    this.onDismiss,
  });

  final CallSession session;
  final CallController controller;
  final VoidCallback? onDismiss;

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  Timer? _dismissTimer;
  bool _isDialpadVisible = false;
  String _dtmfDigits = '';

  @override
  void initState() {
    super.initState();
    _checkTerminalDismiss();
  }

  @override
  void didUpdateWidget(covariant ActiveCallScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkTerminalDismiss();
  }

  void _checkTerminalDismiss() {
    if (widget.session.state.isTerminal && _dismissTimer == null) {
      _dismissTimer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) {
          widget.onDismiss?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _handleDtmfDigit(String digit) {
    setState(() => _dtmfDigits += digit);
  }

  Widget _buildDtmfDialpad() {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: GlassColors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _dtmfDigits.isEmpty ? 'Touch tones (DTMF)' : _dtmfDigits,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: _dtmfDigits.isEmpty
                        ? GlassColors.textMuted
                        : GlassColors.silverAccent,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                key: const Key('closeDtmfDialpadButton'),
                icon: const Icon(
                  Icons.close_rounded,
                  color: GlassColors.textSecondary,
                  size: 20.0,
                ),
                onPressed: () => setState(() => _isDialpadVisible = false),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          for (final row in keys) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final key in row)
                    GlassKey(
                      key: Key('dtmf_key_$key'),
                      digit: key,
                      size: 52.0,
                      onTap: () => _handleDtmfDigit(key),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: GlassColors.background,
      body: Stack(
        children: [
          // Ambient soft restrained silver background glow
          Positioned(
            top: mediaQuery.size.height * 0.12,
            left: mediaQuery.size.width * 0.5 - 120,
            child: Container(
              width: 240.0,
              height: 240.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x08FFFFFF), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 680;
                final avatarSize = isCompact ? 80.0 : 100.0;
                final avatarFontSize = isCompact ? 30.0 : 36.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      SizedBox(height: isCompact ? 10.0 : 18.0),

                      // Call state indicator pill
                      CallStatusIndicator(
                        state: widget.session.state,
                        customText: widget.session.disconnectReason,
                      ),

                      if (_isDialpadVisible) ...[
                        const SizedBox(height: 12.0),
                        _buildDtmfDialpad(),
                      ] else ...[
                        const Spacer(flex: 1),

                        // Caller Avatar Monogram
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1C1C1C), Color(0xFF0F0F0F)],
                            ),
                            border: Border.all(
                              color: const Color(0x35FFFFFF),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x80000000),
                                blurRadius: 20.0,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.session.initials,
                              style: TextStyle(
                                fontSize: avatarFontSize,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: GlassColors.textPrimary,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isCompact ? 12.0 : 20.0),

                        // Caller Name
                        Text(
                          widget.session.effectiveName,
                          style: TextStyle(
                            fontSize: isCompact ? 24.0 : 28.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            color: GlassColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4.0),

                        // Formatted Number or Subtitle
                        if (widget.session.hasCallerName &&
                            widget.session.phoneNumber.isNotEmpty) ...[
                          Text(
                            widget.session.phoneNumber,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: GlassColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                        ],
                      ],

                      // Elapsed Call Duration
                      ListenableBuilder(
                        listenable: widget.controller,
                        builder: (context, _) {
                          if (widget.session.state.isActive) {
                            return Text(
                              _formatDuration(
                                widget.controller.elapsedDuration,
                              ),
                              style: TextStyle(
                                fontSize: isCompact ? 18.0 : 22.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: GlassColors.textPrimary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            );
                          } else if (widget.session.state.isConnecting) {
                            return const Text(
                              'Calling...',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: GlassColors.silverHighlight,
                                letterSpacing: 0.5,
                              ),
                            );
                          } else if (widget.session.state.isHolding) {
                            return const Text(
                              'On Hold',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: GlassColors.silverSubtle,
                                letterSpacing: 0.5,
                              ),
                            );
                          } else if (widget.session.state.isTerminal) {
                            return Text(
                              widget.session.disconnectReason ?? 'Call Ended',
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: GlassColors.danger,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const Spacer(flex: 2),

                      // Active Call Controls Matrix
                      ListenableBuilder(
                        listenable: widget.controller,
                        builder: (context, _) {
                          return ActiveCallControls(
                            isMuted: widget.controller.audioRouteState.isMuted,
                            isHolding: widget.session.state.isHolding,
                            audioState: widget.controller.audioRouteState,
                            isKeypadVisible: _isDialpadVisible,
                            isEnding: widget.controller.isDisconnecting,
                            onToggleMute: widget.controller.toggleMute,
                            onToggleHold: () {
                              if (widget.session.state.isHolding) {
                                widget.controller.unholdCall(
                                  widget.session.sessionId,
                                );
                              } else {
                                widget.controller.holdCall(
                                  widget.session.sessionId,
                                );
                              }
                            },
                            onSelectAudioRoute: widget.controller.setAudioRoute,
                            onToggleKeypad: () {
                              setState(() {
                                _isDialpadVisible = !_isDialpadVisible;
                              });
                            },
                            onEndCall: () {
                              widget.controller.disconnectCall(
                                widget.session.sessionId,
                              );
                            },
                          );
                        },
                      ),

                      SizedBox(height: isCompact ? 16.0 : 30.0),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
