import 'package:flutter/material.dart';

import '../../core/theme/liquid_theme.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/liquid_droplet.dart';
import '../../shared/widgets/liquid_loading_indicator.dart';
import '../../shared/widgets/liquid_surface.dart';
import '../../shared/widgets/liquid_wave_background.dart';
import '../settings/settings_screen.dart';
import 'controllers/recents_controller.dart';
import 'models/call_history_item.dart';
import 'widgets/call_history_tile.dart';
import 'widgets/recents_permission_panel.dart';

/// Recents / Call History screen displaying real device call logs
/// with liquid glass styling, permission controls, and dialer integration.
class RecentsScreen extends StatefulWidget {
  const RecentsScreen({super.key, this.controller, this.onSelectNumber});

  final RecentsController? controller;
  final ValueChanged<String>? onSelectNumber;

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  late final RecentsController _controller;
  bool _ownsController = false;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = RecentsController();
      _ownsController = true;
    }

    _controller.initialize();
  }

  @override
  void dispose() {
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
        return LiquidWaveBackground(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12.0),

                  // Header with Title and Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recents',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: LiquidColors.textPrimary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_controller.isPermissionGranted)
                            GlassIconButton(
                              key: const Key('recentsRefreshButton'),
                              icon: Icons.refresh_rounded,
                              tooltip: 'Refresh call history',
                              onTap: _controller.refresh,
                            ),
                          const SizedBox(width: 8.0),
                          GlassIconButton(
                            key: const Key('recentsSettingsButton'),
                            icon: Icons.tune_rounded,
                            tooltip: 'Settings',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14.0),

                  // Filter Chips row (All, Missed, Incoming, Outgoing)
                  _buildFilterChips(),

                  const SizedBox(height: 14.0),

                  // Body Content
                  Expanded(child: _buildBodyContent()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Missed', 'Incoming', 'Outgoing'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 7.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0x28FFFFFF)
                      : const Color(0x0CFFFFFF),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0x60FFFFFF)
                        : const Color(0x18FFFFFF),
                    width: 1.0,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x20FFFFFF),
                            blurRadius: 8.0,
                            spreadRadius: 1.0,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter == 'Outgoing' ? 'Outgoing\u200B' : filter,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? LiquidColors.textPrimary
                        : LiquidColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBodyContent() {
    // 1. Loading State
    if (_controller.isLoading && _controller.callHistory.isEmpty) {
      return const Center(
        child: LiquidLoadingIndicator(label: 'Loading call history...'),
      );
    }

    // 2. Permission Denied / Not Requested State
    if (!_controller.isPermissionGranted) {
      return RecentsPermissionPanel(
        status: _controller.permissionStatus,
        onRequestPermission: _controller.requestPermissionAndLoad,
        onOpenSettings: _controller.openAppSettings,
      );
    }

    // 3. Error State
    if (_controller.errorMessage != null && _controller.callHistory.isEmpty) {
      return Center(
        child: LiquidSurface(
          level: LiquidSurfaceLevel.card,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 40.0,
                color: LiquidColors.callRed,
              ),
              const SizedBox(height: 14.0),
              const Text(
                'Failed to Load Call History',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: LiquidColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: LiquidColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18.0),
              ElevatedButton.icon(
                key: const Key('recentsRetryButton'),
                onPressed: _controller.refresh,
                icon: const Icon(Icons.refresh_rounded, size: 16.0),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LiquidColors.silverHighlight,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Empty Call History State
    if (_controller.isEmpty) {
      return Center(
        child: LiquidSurface(
          level: LiquidSurfaceLevel.card,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LiquidDroplet(
                size: 60.0,
                child: const Center(
                  child: Icon(
                    Icons.history_toggle_off_rounded,
                    size: 28.0,
                    color: LiquidColors.silverHighlight,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'No Recent Calls',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: LiquidColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'No incoming or outgoing calls have been logged yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  color: LiquidColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 5. Active Call Log List (Filtered)
    final allHistory = _controller.callHistory;
    final history = allHistory.where((item) {
      if (_selectedFilter == 'Missed') {
        return item.callType == CallHistoryType.missed ||
            item.callType == CallHistoryType.rejected;
      } else if (_selectedFilter == 'Incoming') {
        return item.callType == CallHistoryType.incoming;
      } else if (_selectedFilter == 'Outgoing') {
        return item.callType == CallHistoryType.outgoing;
      }
      return true;
    }).toList();

    if (history.isEmpty) {
      return Center(
        child: Text(
          'No $_selectedFilter calls',
          style: const TextStyle(
            fontSize: 15.0,
            color: LiquidColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: LiquidColors.silverHighlight,
      backgroundColor: LiquidColors.surfaceElevated,
      onRefresh: _controller.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 90.0),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return CallHistoryTile(
            key: Key('callHistoryTile_${index}_${item.number}'),
            item: item,
            onTap: () {
              if (item.number.isNotEmpty) {
                widget.onSelectNumber?.call(item.number);
              }
            },
          );
        },
      ),
    );
  }
}
