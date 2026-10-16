import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:permission_handler/permission_handler.dart' show Permission;

/// Normalized permission statuses to isolate platform libraries from app controllers.
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted;

  bool get isGranted => this == AppPermissionStatus.granted;
  bool get isPermanentlyDenied => this == AppPermissionStatus.permanentlyDenied;
  bool get isDenied => this == AppPermissionStatus.denied;
}

/// Identifiers for capabilities managed by the dialer application.
enum DialerCapability {
  defaultDialer,
  callPhone,
  contacts,
  callLog,
  notifications,
}

/// Abstract permission service interface allowing mock injection for testing.
abstract class PhonePermissionsService {
  Future<AppPermissionStatus> checkContactsPermission();
  Future<AppPermissionStatus> requestContactsPermission();

  Future<AppPermissionStatus> checkCallLogPermission();
  Future<AppPermissionStatus> requestCallLogPermission();

  Future<AppPermissionStatus> checkCallPhonePermission();
  Future<AppPermissionStatus> requestCallPhonePermission();

  Future<AppPermissionStatus> checkNotificationPermission();
  Future<AppPermissionStatus> requestNotificationPermission();

  Future<bool> openAppSettings();
}

/// Default implementation utilizing permission_handler for real device checks.
class DevicePhonePermissionsService implements PhonePermissionsService {
  const DevicePhonePermissionsService();

  @override
  Future<AppPermissionStatus> checkContactsPermission() async {
    final status = await Permission.contacts.status;
    return _mapStatus(status);
  }

  @override
  Future<AppPermissionStatus> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return _mapStatus(status);
  }

  @override
  Future<AppPermissionStatus> checkCallLogPermission() async {
    final status = await Permission.phone.status;
    return _mapStatus(status);
  }

  @override
  Future<AppPermissionStatus> requestCallLogPermission() async {
    final status = await Permission.phone.request();
    return _mapStatus(status);
  }

  @override
  Future<AppPermissionStatus> checkCallPhonePermission() async {
    final status = await Permission.phone.status;
    return _mapStatus(status);
  }

  @override
  Future<AppPermissionStatus> requestCallPhonePermission() async {
    final status = await Permission.phone.request();
    return _mapStatus(status);
  }

  @override
  Future<AppPermissionStatus> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return _mapStatus(status);
  }

  @override
  Future<AppPermissionStatus> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return _mapStatus(status);
  }

  @override
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }

  AppPermissionStatus _mapStatus(ph.PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return AppPermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    } else if (status.isRestricted) {
      return AppPermissionStatus.restricted;
    } else {
      return AppPermissionStatus.denied;
    }
  }
}
