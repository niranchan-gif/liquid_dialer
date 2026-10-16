import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../calls/call_controller.dart';

/// Liquid Glass panel displaying Android Default Phone App status
/// and an interactive button to launch the system role request.
class DefaultDialerTile extends StatefulWidget {
  const DefaultDialerTile({super.key, this.controller});

  final CallController? controller;

  @override
  State<DefaultDialerTile> createState() => _DefaultDialerTileState();
}

class _DefaultDialerTileState extends State<DefaultDialerTile>
    with WidgetsBindingObserver {
  late final CallController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = CallController();
      _ownsController = true;
    }
    _controller.checkRoleStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-verify default role status whenever app resumes from system dialogs/settings
      _controller.checkRoleStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isDefault = _controller.isDefaultDialer;
        final isRequesting = _controller.isRequestingRole;
        final feedback = _controller.roleFeedbackMessage;

        return GlassPanel(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDefault
                          ? GlassColors.mintPrimary.withValues(alpha: 0.15)
                          : GlassColors.icyBlue.withValues(alpha: 0.15),
                      border: Border.all(
                        color: isDefault
                            ? GlassColors.mintPrimary.withValues(alpha: 0.35)
                            : GlassColors.icyBlue.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      isDefault
                          ? Icons.verified_user_rounded
                          : Icons.phone_android_rounded,
                      color: isDefault
                          ? GlassColors.mintLight
                          : GlassColors.icyBlue,
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DEFAULT PHONE APP',
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: GlassColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          isDefault
                              ? 'Default Dialer Active'
                              : 'Standard App Mode',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: GlassColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: isDefault
                          ? GlassColors.mintPrimary.withValues(alpha: 0.15)
                          : GlassColors.glassFillUltraLight,
                      border: Border.all(
                        color: isDefault
                            ? GlassColors.mintPrimary.withValues(alpha: 0.3)
                            : GlassColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      isDefault ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: isDefault
                            ? GlassColors.mintLight
                            : GlassColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                isDefault
                    ? 'Liquid Dialer is configured as your system default phone app for handling outgoing and incoming calls.'
                    : 'Setting Liquid Dialer as your default phone app enables system dial intent handling and native telecom call integration.',
                style: const TextStyle(
                  fontSize: 13.0,
                  color: GlassColors.textSecondary,
                  height: 1.4,
                ),
              ),
              if (feedback != null) ...[
                const SizedBox(height: 10.0),
                Text(
                  feedback,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: isDefault
                        ? GlassColors.mintLight
                        : GlassColors.softViolet,
                  ),
                ),
              ],
              if (!isDefault) ...[
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('requestDefaultDialerButton'),
                    onPressed: isRequesting
                        ? null
                        : () => _controller.requestDefaultDialer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlassColors.icyBlue,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    child: isRequesting
                        ? const SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Set as Default Phone App',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
