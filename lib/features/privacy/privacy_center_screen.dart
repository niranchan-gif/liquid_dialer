import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/permissions/phone_permissions_service.dart';
import '../../core/theme/liquid_theme.dart';
import '../../core/utils/privacy_logger.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/liquid_loading_indicator.dart';
import '../../shared/widgets/liquid_surface.dart';
import '../calls/call_controller.dart';

/// Full-screen Liquid Glass Permission & Privacy Center.
///
/// Transparently details each required and optional Android capability,
/// explains why each is needed, enables in-app requests or system settings navigation,
/// and certifies zero-telemetry, zero-cloud data preservation.
class PrivacyCenterScreen extends StatefulWidget {
  const PrivacyCenterScreen({
    super.key,
    this.permissionsService,
    this.callController,
  });

  final PhonePermissionsService? permissionsService;
  final CallController? callController;

  @override
  State<PrivacyCenterScreen> createState() => _PrivacyCenterScreenState();
}

class _PrivacyCenterScreenState extends State<PrivacyCenterScreen> {
  late final PhonePermissionsService _permissionsService;
  late final CallController _callController;
  bool _ownsCallController = false;

  AppPermissionStatus _contactsStatus = AppPermissionStatus.denied;
  AppPermissionStatus _callLogStatus = AppPermissionStatus.denied;
  AppPermissionStatus _callPhoneStatus = AppPermissionStatus.denied;
  AppPermissionStatus _notificationStatus = AppPermissionStatus.denied;
  bool _isDefaultDialer = false;
  bool _isLoading = true;
  bool _showDiagnostics = false;

  @override
  void initState() {
    super.initState();
    _permissionsService =
        widget.permissionsService ?? const DevicePhonePermissionsService();
    if (widget.callController != null) {
      _callController = widget.callController!;
    } else {
      _callController = CallController();
      _ownsCallController = true;
    }
    _refreshStatuses();
  }

  @override
  void dispose() {
    if (_ownsCallController) {
      _callController.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshStatuses() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _permissionsService.checkContactsPermission();
      final callLog = await _permissionsService.checkCallLogPermission();
      final callPhone = await _permissionsService.checkCallPhonePermission();
      final notification = await _permissionsService
          .checkNotificationPermission();
      await _callController.checkRoleStatus();

      if (mounted) {
        setState(() {
          _contactsStatus = contacts;
          _callLogStatus = callLog;
          _callPhoneStatus = callPhone;
          _notificationStatus = notification;
          _isDefaultDialer = _callController.isDefaultDialer;
          _isLoading = false;
        });
      }
    } catch (e) {
      PrivacyLogger.error(
        'PrivacyCenter',
        'Error querying permission statuses',
        e,
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestRole() async {
    HapticFeedback.lightImpact();
    await _callController.requestDefaultDialer();
    await _refreshStatuses();
  }

  Future<void> _requestContacts() async {
    HapticFeedback.lightImpact();
    final status = await _permissionsService.requestContactsPermission();
    if (mounted) setState(() => _contactsStatus = status);
  }

  Future<void> _requestCallLog() async {
    HapticFeedback.lightImpact();
    final status = await _permissionsService.requestCallLogPermission();
    if (mounted) setState(() => _callLogStatus = status);
  }

  Future<void> _requestCallPhone() async {
    HapticFeedback.lightImpact();
    final status = await _permissionsService.requestCallPhonePermission();
    if (mounted) setState(() => _callPhoneStatus = status);
  }

  Future<void> _requestNotification() async {
    HapticFeedback.lightImpact();
    final status = await _permissionsService.requestNotificationPermission();
    if (mounted) setState(() => _notificationStatus = status);
  }

  Future<void> _openSettings() async {
    HapticFeedback.mediumImpact();
    await _permissionsService.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiquidColors.background,
      body: Stack(
        children: [
          // Subtle top liquid halo
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    LiquidColors.specularMeniscus.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      GlassIconButton(
                        key: const Key('privacyCenterBackButton'),
                        icon: Icons.arrow_back_ios_new_rounded,
                        tooltip: 'Back',
                        iconSize: 18.0,
                        size: 48.0,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 14.0),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Permissions & Privacy',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 19.0,
                                fontWeight: FontWeight.w700,
                                color: LiquidColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'Local on-device protection',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: LiquidColors.silverHighlight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: LiquidColors.textSecondary,
                          size: 22.0,
                        ),
                        tooltip: 'Refresh Statuses',
                        onPressed: _refreshStatuses,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    children: [
                      // Zero-Tracking Privacy Guarantee Banner
                      _buildPrivacyHeroCard(),
                      const SizedBox(height: 24.0),

                      // Section Title: System Capabilities
                      const Text(
                        'SYSTEM PERMISSIONS & ROLES',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: LiquidColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // 1. Default Phone Role
                      _buildPermissionCard(
                        title: 'Default Phone App',
                        subtitle: 'ROLE_DIALER (System Telecom)',
                        rationale: 'Enables lockscreen call UI, incoming call notification controls, and native audio management.',
                        icon: Icons.phone_android_rounded,
                        isGranted: _isDefaultDialer,
                        isPermanentlyDenied: false,
                        onAction: _requestRole,
                        actionLabel: 'Set as Default',
                      ),
                      const SizedBox(height: 12.0),

                      // 2. Phone Calls
                      _buildPermissionCard(
                        title: 'Direct Phone Calls',
                        subtitle: 'android.permission.CALL_PHONE',
                        rationale: 'Allows initiating cellular calls directly from the keypad and contacts without extra confirmation prompts.',
                        icon: Icons.call_rounded,
                        isGranted: _callPhoneStatus.isGranted,
                        isPermanentlyDenied:
                            _callPhoneStatus.isPermanentlyDenied,
                        onAction: _requestCallPhone,
                        actionLabel: 'Grant Call Access',
                      ),
                      const SizedBox(height: 12.0),

                      // 3. Contacts
                      _buildPermissionCard(
                        title: 'Device Contacts',
                        subtitle: 'android.permission.READ_CONTACTS',
                        rationale: 'Searches your address book, displays caller identities on incoming calls, and manages local favorites.',
                        icon: Icons.contacts_rounded,
                        isGranted: _contactsStatus.isGranted,
                        isPermanentlyDenied:
                            _contactsStatus.isPermanentlyDenied,
                        onAction: _requestContacts,
                        actionLabel: 'Grant Contacts Access',
                      ),
                      const SizedBox(height: 12.0),

                      // 4. Call History
                      _buildPermissionCard(
                        title: 'Call History Log',
                        subtitle: 'android.permission.READ_CALL_LOG',
                        rationale: 'Displays recent incoming, outgoing, and missed cellular calls in the Recents tab.',
                        icon: Icons.history_rounded,
                        isGranted: _callLogStatus.isGranted,
                        isPermanentlyDenied: _callLogStatus.isPermanentlyDenied,
                        onAction: _requestCallLog,
                        actionLabel: 'Grant Call Log Access',
                      ),
                      const SizedBox(height: 12.0),

                      // 5. Notifications
                      _buildPermissionCard(
                        title: 'Incoming Call Notifications',
                        subtitle: 'android.permission.POST_NOTIFICATIONS',
                        rationale: 'Presents heads-up incoming call alerts with instant Answer and Decline actions while using other apps.',
                        icon: Icons.notifications_active_rounded,
                        isGranted: _notificationStatus.isGranted,
                        isPermanentlyDenied:
                            _notificationStatus.isPermanentlyDenied,
                        onAction: _requestNotification,
                        actionLabel: 'Grant Notification Access',
                      ),

                      const SizedBox(height: 24.0),

                      // Section Title: Architecture Guarantees
                      const Text(
                        'ON-DEVICE ARCHITECTURE',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: LiquidColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      _buildArchitectureCard(),

                      const SizedBox(height: 24.0),

                      // Diagnostics & Privacy Logs Toggle
                      _buildDiagnosticsSection(),

                      const SizedBox(height: 20.0),

                      // Open System Settings Action Button
                      LiquidSurface(
                        level: LiquidSurfaceLevel.card,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 14.0,
                        ),
                        child: InkWell(
                          key: const Key('openSystemSettingsButton'),
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: _openSettings,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings_rounded,
                                size: 18.0,
                                color: LiquidColors.silverHighlight,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Open System Settings',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: LiquidColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: LiquidLoadingIndicator(
                    label: 'Verifying permissions...',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrivacyHeroCard() {
    return LiquidSurface(
      level: LiquidSurfaceLevel.card,
      padding: const EdgeInsets.all(18.0),
      borderRadius: BorderRadius.circular(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x2034D399),
              border: Border.all(color: const Color(0x6034D399)),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Color(0xFF4ADE80),
              size: 24.0,
            ),
          ),
          const SizedBox(width: 14.0),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% On-Device Privacy Guaranteed',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: LiquidColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.0),
                Text(
                  'Liquid Dialer contains zero analytics SDKs, zero advertising trackers, and zero cloud synchronization. Your contacts, history, and calls strictly remain on this device.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: LiquidColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String subtitle,
    required String rationale,
    required IconData icon,
    required bool isGranted,
    required bool isPermanentlyDenied,
    required VoidCallback onAction,
    required String actionLabel,
  }) {
    return LiquidSurface(
      level: LiquidSurfaceLevel.card,
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: isGranted
                      ? const Color(0x2034D399)
                      : LiquidColors.surfaceElevated,
                  border: Border.all(
                    color: isGranted
                        ? const Color(0x6034D399)
                        : LiquidColors.borderSubtle,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20.0,
                  color: isGranted
                      ? const Color(0xFF4ADE80)
                      : LiquidColors.silverHighlight,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: LiquidColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.0,
                        color: LiquidColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(
                isGranted: isGranted,
                isPermanentlyDenied: isPermanentlyDenied,
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            rationale,
            style: const TextStyle(
              fontSize: 12.0,
              height: 1.4,
              color: LiquidColors.textSecondary,
            ),
          ),
          if (!isGranted) ...[
            const SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: isPermanentlyDenied
                  ? OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: LiquidColors.callRed,
                        side: BorderSide(
                          color: LiquidColors.callRed.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings_outlined, size: 16.0),
                      label: const Text(
                        'Open Settings',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LiquidColors.surfaceElevated,
                        foregroundColor: LiquidColors.silverHighlight,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: LiquidColors.specularMeniscus.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                      onPressed: onAction,
                      icon: const Icon(Icons.check_circle_outline, size: 16.0),
                      label: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusPill({
    required bool isGranted,
    required bool isPermanentlyDenied,
  }) {
    if (isGranted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: const Color(0x2034D399),
          border: Border.all(color: const Color(0x6034D399)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: 12.0, color: Color(0xFF4ADE80)),
            SizedBox(width: 4.0),
            Text(
              'Granted',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4ADE80),
              ),
            ),
          ],
        ),
      );
    } else if (isPermanentlyDenied) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: LiquidColors.callRed.withValues(alpha: 0.15),
          border: Border.all(
            color: LiquidColors.callRed.withValues(alpha: 0.5),
          ),
        ),
        child: const Text(
          'Denied in Settings',
          style: TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
            color: LiquidColors.callRed,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: const Color(0x26F59E0B),
          border: Border.all(color: const Color(0x66F59E0B)),
        ),
        child: const Text(
          'Not Granted',
          style: TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFBBF24),
          ),
        ),
      );
    }
  }

  Widget _buildArchitectureCard() {
    return LiquidSurface(
      level: LiquidSurfaceLevel.card,
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(14.0),
      child: Column(
        children: [
          _buildFeatureBullet(
            icon: Icons.cloud_off_rounded,
            title: 'No Internet Permission',
            description:
                'Liquid Dialer does not declare android.permission.INTERNET.',
          ),
          const Divider(color: LiquidColors.borderSubtle, height: 20.0),
          _buildFeatureBullet(
            icon: Icons.mic_none_rounded,
            title: 'No Audio Surveillance',
            description: 'No background call recording or microphone logging.',
          ),
          const Divider(color: LiquidColors.borderSubtle, height: 20.0),
          _buildFeatureBullet(
            icon: Icons.storage_rounded,
            title: 'Transient Content Queries',
            description: 'Contacts and call logs are queried directly from Android OS on-demand.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.0, color: LiquidColors.silverHighlight),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: LiquidColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: LiquidColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticsSection() {
    final recentLogs = PrivacyLogger.recentLogs;

    return LiquidSurface(
      level: LiquidSurfaceLevel.card,
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.terminal_rounded,
                size: 18.0,
                color: LiquidColors.mistGrey,
              ),
              const SizedBox(width: 10.0),
              const Expanded(
                child: Text(
                  'Diagnostics & Logs',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: LiquidColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _showDiagnostics = !_showDiagnostics);
                },
                child: Text(
                  _showDiagnostics ? 'Hide' : 'View (${recentLogs.length})',
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: LiquidColors.silverHighlight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          const Text(
            'All technical diagnostic entries automatically scrub and mask phone numbers (***-***-1234) and sensitive parameters.',
            style: TextStyle(fontSize: 11.5, color: LiquidColors.textSecondary),
          ),
          if (_showDiagnostics) ...[
            const SizedBox(height: 12.0),
            Container(
              height: 160.0,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: LiquidColors.borderSubtle),
              ),
              child: recentLogs.isEmpty
                  ? const Center(
                      child: Text(
                        'No diagnostic events recorded yet.',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: LiquidColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: recentLogs.length,
                      itemBuilder: (context, index) {
                        final log = recentLogs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            log.format(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              color: LiquidColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
