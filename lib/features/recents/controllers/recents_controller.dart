import 'package:flutter/foundation.dart';

import '../../../core/permissions/phone_permissions_service.dart';
import '../models/call_history_item.dart';
import '../services/call_history_service.dart';

/// State controller managing call-log retrieval, permission state, and UI feedback.
class RecentsController extends ChangeNotifier {
  RecentsController({
    PhonePermissionsService? permissionsService,
    CallHistoryService? callHistoryService,
  }) : _permissionsService =
           permissionsService ?? const DevicePhonePermissionsService(),
       _callHistoryService =
           callHistoryService ?? const DeviceCallHistoryService();

  final PhonePermissionsService _permissionsService;
  final CallHistoryService _callHistoryService;

  bool _isLoading = false;
  String? _errorMessage;
  AppPermissionStatus _permissionStatus = AppPermissionStatus.denied;
  bool _hasCheckedPermission = false;
  List<CallHistoryItem> _callHistory = [];

  // Public state getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppPermissionStatus get permissionStatus => _permissionStatus;
  bool get hasCheckedPermission => _hasCheckedPermission;
  bool get isPermissionGranted => _permissionStatus.isGranted;
  bool get isPermanentlyDenied => _permissionStatus.isPermanentlyDenied;
  List<CallHistoryItem> get callHistory => List.unmodifiable(_callHistory);
  bool get isEmpty =>
      _callHistory.isEmpty && !_isLoading && _permissionStatus.isGranted;

  /// Checks permission without prompting dialog if user hasn't asked.
  Future<void> initialize({bool requestPermission = false}) async {
    if (requestPermission) {
      await requestPermissionAndLoad();
    } else {
      _permissionStatus = await _permissionsService.checkCallLogPermission();
      _hasCheckedPermission = true;
      if (_permissionStatus.isGranted) {
        await loadCallHistory();
      } else {
        notifyListeners();
      }
    }
  }

  /// Explicitly requests call-log permission upon user tap.
  Future<void> requestPermissionAndLoad() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _permissionStatus = await _permissionsService.requestCallLogPermission();
      _hasCheckedPermission = true;

      if (_permissionStatus.isGranted) {
        await _fetchCallLog();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Permission request failed: $e';
      notifyListeners();
    }
  }

  /// Queries the call log if permission is granted.
  Future<void> loadCallHistory({bool forceReload = false}) async {
    if (_callHistory.isNotEmpty &&
        !forceReload &&
        _permissionStatus.isGranted) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _permissionStatus = await _permissionsService.checkCallLogPermission();
      _hasCheckedPermission = true;

      if (!_permissionStatus.isGranted) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _fetchCallLog();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unable to load call history: $e';
      notifyListeners();
    }
  }

  /// User-initiated refresh action.
  Future<void> refresh() async {
    await loadCallHistory(forceReload: true);
  }

  Future<void> _fetchCallLog() async {
    final history = await _callHistoryService.fetchCallHistory();
    history.sort();
    _callHistory = history;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Helper to direct the user to device application settings.
  Future<bool> openAppSettings() async {
    return await _permissionsService.openAppSettings();
  }
}
