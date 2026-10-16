# Liquid Dialer — Premium AMOLED Liquid Glass Dialer

A state-of-the-art Android dialer application built with **Flutter** and native **Kotlin Android Telecom APIs**, purpose-crafted for **Android 16** and modern AMOLED devices (optimized for OnePlus Nord 4).

Features a sophisticated **true AMOLED black (#000000)** and layered **graphite grey** visual architecture, organic **water-drop liquid glass motion**, **live on-device contact matching**, and a complete production-hardened **Android Telecom calling subsystem**.

---

## Key Highlights

### 1. AMOLED Black & Graphite Monochrome Design
- **True AMOLED Black (`#000000`):** Maximizes power efficiency on OLED/AMOLED displays with pure pixel turn-off.
- **Layered Graphite Geometry:** Deep graphite surfaces (`#090909`, `#101010`, `#141414`, `#181818`) with delicate silver-grey specular borders (`0x22FFFFFF`).
- **Crisp Typography:** Soft white `#F5F5F5` primary text and muted grey `#929292` secondary letters.
- **Cool Silver Highlights:** Restrained silver accents (`#E2E8F0`, `#CBD5E1`) without neon glows or distracting colorful gradients.

### 2. Fluid Water-Drop Liquid Glass System
- **Organic Squircle Keys:** Replaces outdated circular buttons with refined rounded-squircle surfaces (`BorderRadius.circular(21.0)`).
- **Meniscus Specular Glare:** Top-edge curved reflective highlight simulates light glancing off the convex surface of a water droplet.
- **Dynamic Water-Drop Ripple:** Press interactions trigger a custom radial liquid wave (`_WaterDropRipplePainter`) expanding outward from touch coordinates with soft silver refraction.
- **60+ FPS Performance:** Lightweight blur shaders (8.0 sigma) and optimized custom painting avoid continuous repainting and preserve battery life.

### 3. Live Device Contact Matching
- **Instant Search:** Evaluates device contacts as digits are entered through the keypad or incoming dial intents.
- **Smart Normalization:** Normalizes international country codes (`+91`, `+1`, etc.), trunk prefixes (`0`), hyphens, and whitespace.
- **Multi-Match Suggestion Strip:** Displays matching contact name and number prominently above keypad, with a compact horizontal suggestion chip strip when multiple contacts match.
- **100% Local Privacy:** All contact querying and matching operates strictly in-memory on the local device without network transmission.

### 4. Native Android Telecom Integration
- **Default Phone Role:** Supports Android 16 default dialer role management via `TelecomManager.ACTION_CHANGE_DEFAULT_DIALER`.
- **`LiquidInCallService`:** Native Kotlin Telecom in-call service managing active calls, hold states, DTMF touch-tones, audio route switching, and incoming call notifications.
- **Incoming & Active Call Screens:** Full-screen incoming call responder and active in-call console with DTMF dialpad, mute toggle, speakerphone, and call timer.
- **DialerBridge:** Bidirectional Platform Channel bridging Flutter Dart controllers with native Android Telecom services.

---

## Architecture & Code Structure

```
lib/
├── app.dart                                # Primary shell, persistent tab navigation & call orchestrator
├── core/
│   ├── permissions/                        # Device permission abstractions (Contacts, Phone, Call Log)
│   ├── platform/                           # Native Telecom bridge (DialerBridge)
│   ├── privacy/                            # Privacy audit logger & data sanitizer
│   └── theme/                              # GlassColors, AppTheme, GlassDecorations
├── features/
│   ├── calls/                              # Incoming/Active call screens, DTMF controls, call state controller
│   ├── contacts/                           # Device contacts repository, models, and PhoneNumberMatcher
│   ├── dialer/                             # DialerController, DialerKeypad, PhoneNumberDisplay, DialerScreen
│   ├── favorites/                          # Local favorites store and quick-dial management
│   ├── privacy/                            # Privacy Center & permission transparency UI
│   ├── recents/                            # Call log history & details
│   └── settings/                           # Default dialer role toggle, diagnostic checks, about dialog
└── shared/
    └── widgets/                            # GlassKey, GlassIconButton, GlassBottomNavigation, GlassCard
```

---

## Getting Started

### Prerequisites
- **Flutter SDK:** $\ge$ 3.19.0
- **Android SDK:** API 34+ (Targeting Android 16 / API 36)
- **Java / Gradle:** JDK 17+

### Installation & Run
```bash
# Clone the repository
git clone https://github.com/niranchan-gif/liquid_dialer.git
cd liquid_dialer

# Fetch Flutter dependencies
flutter pub get

# Run tests
flutter test

# Run debug on connected Android device
flutter run
```

### Build APK
```bash
flutter build apk --debug
```

---

## Verification & Quality Assurance

- **Code Formatting:** 100% compliant with `dart format .`
- **Static Analysis:** Clean `flutter analyze` with 0 warnings and 0 errors.
- **Test Suite:** **82 / 82** automated tests passing (`flutter test`):
  - International number normalization and contact matching tests.
  - Keypad squircle layout, key gestures, and long-press clear.
  - Fluid ripple animation and lifecycle disposal.
  - Native Telecom calling state machines, DTMF audio, and permissions.
