import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/theme/glass_styles.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure edge-to-edge transparent system bars with light icons for AMOLED background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GlassColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const LiquidDialerApp());
}
