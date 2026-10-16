import 'package:flutter/material.dart';

import '../../../core/theme/liquid_theme.dart';
import '../../calls/call_controller.dart';
import '../models/call_session.dart';
import '../models/call_state.dart';
import '../widgets/call_status_indicator.dart';
import '../widgets/incoming_call_actions.dart';

/// Full-screen Liquid Glass incoming-call screen for OnePlus Nord 4.
///
/// Features deep AMOLED black aesthetics (#000000), subtle silver liquid breathing halo,
/// prominent caller identity, and responsive Answer/Decline controls wired to native Android Telecom.
class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({
    super.key,
    required this.session,
    required this.controller,
  });

  final CallSession session;
  final CallController controller;

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _haloController;
  late final Animation<double> _haloScale;
  late final Animation<double> _haloOpacity;

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _haloScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOutSine),
    );

    _haloOpacity = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Scaffold(
      backgroundColor: LiquidColors.background,
      body: Stack(
        children: [
          // Subtle restrained silver ambient glow in background
          Positioned(
            top: MediaQuery.of(context).size.height * 0.16,
            left: MediaQuery.of(context).size.width * 0.5 - 130,
            child: Container(
              width: 260.0,
              height: 260.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x0AFFFFFF), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const SizedBox(height: 28.0),

                  // Call state indicator pill
                  const CallStatusIndicator(state: CallState.incoming),

                  const Spacer(flex: 2),

                  // Avatar with gentle breathing silver liquid halo
                  AnimatedBuilder(
                    animation: _haloController,
                    builder: (context, child) {
                      final scale = disableAnimations ? 1.0 : _haloScale.value;
                      final opacity = disableAnimations
                          ? 0.4
                          : _haloOpacity.value;

                      return Container(
                        width: 150.0,
                        height: 150.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color.fromRGBO(
                              226,
                              232,
                              240,
                              0.15 * opacity,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(
                                255,
                                255,
                                255,
                                0.08 * opacity,
                              ),
                              blurRadius: 36.0 * scale,
                              spreadRadius: 2.0 * scale,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 124.0,
                      height: 124.0,
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
                            blurRadius: 24.0,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.session.initials,
                          style: const TextStyle(
                            fontSize: 44.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: LiquidColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32.0),

                  // Caller Name with generous breathing room
                  Text(
                    widget.session.effectiveName,
                    style: const TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: LiquidColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (widget.session.hasCallerName &&
                      widget.session.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      widget.session.phoneNumber,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: LiquidColors.textSecondary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],

                  const Spacer(flex: 3),

                  // Answer & Decline Actions
                  ListenableBuilder(
                    listenable: widget.controller,
                    builder: (context, _) {
                      return IncomingCallActions(
                        isAnswering: widget.controller.isAnswering,
                        isRejecting: widget.controller.isRejecting,
                        onAnswer: () => widget.controller.answerCall(
                          widget.session.sessionId,
                        ),
                        onReject: () => widget.controller.rejectCall(
                          widget.session.sessionId,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 52.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
