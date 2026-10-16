import 'package:flutter/material.dart';

import '../../../core/theme/liquid_theme.dart';
import '../../../shared/widgets/liquid_wave_background.dart';
import '../../../shared/widgets/organic_liquid_droplet.dart';
import '../../calls/call_controller.dart';
import '../models/call_session.dart';
import '../models/call_state.dart';
import '../widgets/call_status_indicator.dart';
import '../widgets/incoming_call_actions.dart';

/// Full-screen Liquid Glass incoming-call screen matching the reference design.
///
/// Encapsulates the caller inside an organic fluid water-droplet bubble,
/// on an AMOLED black background with subtle chromatic refraction wave,
/// caller identity, and responsive Decline/Answer liquid buttons with labels.
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

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _haloScale = Tween<double>(begin: 1.0, end: 1.06).animate(
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
      body: LiquidWaveBackground(
        showWaves: true,
        showFloatingDroplets: true,
        accentTint: const Color(0x2034D399),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                const SizedBox(height: 20.0),

                // Call state indicator pill
                const CallStatusIndicator(state: CallState.incoming),

                const Spacer(flex: 2),

                // Caller Avatar inside Organic Liquid Water Droplet Bubble
                AnimatedBuilder(
                  animation: _haloController,
                  builder: (context, child) {
                    final scale = disableAnimations ? 1.0 : _haloScale.value;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: OrganicLiquidDroplet(
                    size: 168.0,
                    child: Center(
                      child: Text(
                        widget.session.initials,
                        style: const TextStyle(
                          fontSize: 48.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: LiquidColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32.0),

                // Caller Name
                Text(
                  widget.session.effectiveName,
                  style: const TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: LiquidColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6.0),

                // Caller Phone Number
                if (widget.session.hasCallerName &&
                    widget.session.phoneNumber.isNotEmpty) ...[
                  Text(
                    widget.session.phoneNumber,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: LiquidColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],

                // "Incoming call..." status subtitle
                const Text(
                  'Incoming call...',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: LiquidColors.textMuted,
                    letterSpacing: 0.4,
                  ),
                ),

                const Spacer(flex: 3),

                // Answer & Decline Actions with labels below
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

                const SizedBox(height: 48.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
