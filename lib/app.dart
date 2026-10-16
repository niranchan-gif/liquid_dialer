import 'dart:async';

import 'package:flutter/material.dart';

import 'core/platform/dialer_bridge.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/glass_styles.dart';
import 'features/calls/call_controller.dart';
import 'features/calls/screens/active_call_screen.dart';
import 'features/calls/screens/incoming_call_screen.dart';
import 'features/contacts/contacts_screen.dart';
import 'features/contacts/controllers/contacts_controller.dart';
import 'features/dialer/dialer_controller.dart';
import 'features/dialer/dialer_screen.dart';
import 'features/recents/controllers/recents_controller.dart';
import 'features/recents/recents_screen.dart';
import 'shared/widgets/glass_bottom_navigation.dart';

/// Root application widget configuring theme and primary shell.
class LiquidDialerApp extends StatelessWidget {
  const LiquidDialerApp({super.key, this.callService, this.callController});

  final CallService? callService;
  final CallController? callController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTheme.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MainShellScreen(
        callService: callService,
        callController: callController,
      ),
    );
  }
}

/// Primary shell screen orchestrating tab navigation, persistent state,
/// and live Telecom incoming/active call presentation.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialIndex = 1,
    this.callService,
    this.callController,
    this.contactsController,
    this.recentsController,
  });

  /// The tab initially displayed. Defaults to 1 (Keypad).
  final int initialIndex;

  /// Optional call service for test mocking.
  final CallService? callService;

  /// Optional call controller for test injection and state control.
  final CallController? callController;

  /// Optional contacts controller for test injection.
  final ContactsController? contactsController;

  /// Optional recents controller for test injection.
  final RecentsController? recentsController;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _CallControllerCallService implements CallService {
  const _CallControllerCallService(this.controller);
  final CallController controller;

  @override
  Future<String> placeCall(String phoneNumber) async {
    final result = await controller.placeCall(phoneNumber);
    return result.message;
  }
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  late final DialerController _dialerController;
  late final CallController _callController;
  bool _ownsCallController = false;

  StreamSubscription<String>? _dialIntentSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    if (widget.callController != null) {
      _callController = widget.callController!;
    } else {
      _callController = CallController();
      _ownsCallController = true;
    }

    _dialerController = DialerController(
      callService:
          widget.callService ?? _CallControllerCallService(_callController),
    );

    _listenForDialIntents();
  }

  void _listenForDialIntents() {
    DialerBridge.instance.getInitialDialNumber().then((number) {
      if (number != null && number.isNotEmpty && mounted) {
        _dialerController.setNumber(number);
        _onTabSelected(1);
      }
    });

    _dialIntentSubscription = DialerBridge.instance.onDialIntent.listen((
      number,
    ) {
      if (mounted) {
        _dialerController.setNumber(number);
        _onTabSelected(1);
      }
    });
  }

  @override
  void dispose() {
    _dialIntentSubscription?.cancel();
    _dialerController.dispose();
    if (_ownsCallController) {
      _callController.dispose();
    }
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _callController,
      builder: (context, _) {
        final call = _callController.primaryCall;

        Widget currentView;

        // If an incoming call is ringing, display full-screen IncomingCallScreen
        if (call != null && call.state.isIncoming) {
          currentView = KeyedSubtree(
            key: const ValueKey('incomingCallView'),
            child: IncomingCallScreen(
              session: call,
              controller: _callController,
            ),
          );
        } else if (call != null &&
            (call.state.isActive ||
                call.state.isConnecting ||
                call.state.isHolding ||
                call.state.isTerminal)) {
          // If a call is active, connecting, on hold, or terminating, display ActiveCallScreen
          currentView = KeyedSubtree(
            key: const ValueKey('activeCallView'),
            child: ActiveCallScreen(
              session: call,
              controller: _callController,
              onDismiss: () => _callController.refreshCallSnapshot(),
            ),
          );
        } else {
          // Default shell with persistent tab navigation
          currentView = KeyedSubtree(
            key: const ValueKey('mainShellView'),
            child: Scaffold(
              backgroundColor: GlassColors.background,
              extendBody: false,
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  RecentsScreen(
                    controller: widget.recentsController,
                    onSelectNumber: (number) {
                      _callController.placeCall(number);
                    },
                  ),
                  DialerScreen(
                    controller: _dialerController,
                    onNavigateToContacts: () => _onTabSelected(2),
                  ),
                  ContactsScreen(
                    controller: widget.contactsController,
                    onSelectNumber: (number) {
                      _callController.placeCall(number);
                    },
                  ),
                ],
              ),
              bottomNavigationBar: GlassBottomNavigation(
                currentIndex: _currentIndex,
                onTap: _onTabSelected,
              ),
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: currentView,
        );
      },
    );
  }
}
