/// Supported audio routes for in-call playback.
enum AudioRoute {
  earpiece,
  speaker,
  wiredHeadset,
  bluetooth;

  static AudioRoute fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'speaker':
        return AudioRoute.speaker;
      case 'bluetooth':
        return AudioRoute.bluetooth;
      case 'wiredheadset':
        return AudioRoute.wiredHeadset;
      case 'earpiece':
      default:
        return AudioRoute.earpiece;
    }
  }

  String get displayName {
    switch (this) {
      case AudioRoute.speaker:
        return 'Speaker';
      case AudioRoute.bluetooth:
        return 'Bluetooth Device';
      case AudioRoute.wiredHeadset:
        return 'Wired Headset';
      case AudioRoute.earpiece:
        return 'Phone Earpiece';
    }
  }
}

/// Represents the snapshot of current audio output routing and microphone mute status.
class AudioRouteState {
  const AudioRouteState({
    this.currentRoute = AudioRoute.earpiece,
    this.isMuted = false,
    this.supportedRoutes = const [AudioRoute.earpiece, AudioRoute.speaker],
  });

  final AudioRoute currentRoute;
  final bool isMuted;
  final List<AudioRoute> supportedRoutes;

  factory AudioRouteState.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const AudioRouteState();
    final currentStr = map['currentRoute'] as String?;
    final muted = map['isMuted'] as bool? ?? false;
    final routesList = map['supportedRoutes'] as List<dynamic>?;

    final routes = routesList != null
        ? routesList.map((r) => AudioRoute.fromString(r.toString())).toList()
        : [AudioRoute.earpiece, AudioRoute.speaker];

    return AudioRouteState(
      currentRoute: AudioRoute.fromString(currentStr),
      isMuted: muted,
      supportedRoutes: routes,
    );
  }

  bool get isSpeakerOn => currentRoute == AudioRoute.speaker;
  bool get hasBluetooth => supportedRoutes.contains(AudioRoute.bluetooth);
}
