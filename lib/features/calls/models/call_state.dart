/// Represents the lifecycle states of a cellular telephone call in Android Telecom.
enum CallState {
  incoming,
  dialing,
  connecting,
  active,
  holding,
  disconnected,
  disconnecting,
  unknown;

  static CallState fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'incoming':
        return CallState.incoming;
      case 'dialing':
        return CallState.dialing;
      case 'connecting':
        return CallState.connecting;
      case 'active':
        return CallState.active;
      case 'holding':
        return CallState.holding;
      case 'disconnected':
        return CallState.disconnected;
      case 'disconnecting':
        return CallState.disconnecting;
      default:
        return CallState.unknown;
    }
  }

  bool get isTerminal => this == CallState.disconnected;
  bool get isIncoming => this == CallState.incoming;
  bool get isActive => this == CallState.active;
  bool get isConnecting =>
      this == CallState.dialing || this == CallState.connecting;
  bool get isHolding => this == CallState.holding;
}

/// Represents the directional orientation of a call.
enum CallDirection {
  incoming,
  outgoing;

  static CallDirection fromString(String? val) {
    if (val?.toLowerCase() == 'incoming') return CallDirection.incoming;
    return CallDirection.outgoing;
  }
}
