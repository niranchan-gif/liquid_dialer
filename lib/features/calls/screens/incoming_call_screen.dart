import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';
import '../call_controller.dart';
import '../models/call_session.dart';
import '../models/call_state.dart';
import '../widgets/call_status_indicator.dart';
import '../widgets/incoming_call_actions.dart';

/// Full-screen Liquid Glass incoming-call screen for OnePlus Nord 4.
///
/// Features deep AMOLED black aesthetics, specular halo lighting, contact details,
/// and responsive Answer/Decline controls wired to native Android Telecom.
class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({
    super.key,
    required this.session,
    required this.controller,
  });

  final CallSession session;
  final CallController controller;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: GlassColors.background,
      body: Stack(
        children: [
          // Ambient cyan & violet background glows
          Positioned(
            top: mediaQuery.size.height * 0.15,
            left: mediaQuery.size.width * 0.5 - 130,
            child: Container(
              width: 260.0,
              height: 260.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GlassColors.cyanAccent.withValues(alpha: 0.18),
                    GlassColors.softViolet.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 24.0),

                  // Status indicator pill
                  const CallStatusIndicator(state: CallState.incoming),

                  const Spacer(flex: 2),

                  // Glowing Avatar Halo & Monogram
                  Container(
                    width: 130.0,
                    height: 130.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GlassColors.cyanAccent.withValues(alpha: 0.25),
                          GlassColors.deepViolet.withValues(alpha: 0.15),
                        ],
                      ),
                      border: Border.all(
                        color: GlassColors.cyanAccent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: GlassColors.cyanAccent.withValues(alpha: 0.2),
                          blurRadius: 32.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        session.initials,
                        style: const TextStyle(
                          fontSize: 48.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: GlassColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28.0),

                  // Caller Name
                  Text(
                    session.effectiveName,
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: GlassColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (session.hasCallerName &&
                      session.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      session.phoneNumber,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: GlassColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],

                  const Spacer(flex: 3),

                  // Answer & Decline Actions
                  ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      return IncomingCallActions(
                        isAnswering: controller.isAnswering,
                        isRejecting: controller.isRejecting,
                        onAnswer: () =>
                            controller.answerCall(session.sessionId),
                        onReject: () =>
                            controller.rejectCall(session.sessionId),
                      );
                    },
                  ),

                  const SizedBox(height: 48.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
