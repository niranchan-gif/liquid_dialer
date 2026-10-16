import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/liquid_theme.dart';

/// Modal bottom sheet styled as a water-on-dark-glass liquid surface.
class LiquidBottomSheet extends StatelessWidget {
  const LiquidBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.maxHeightFraction = 0.85,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final double maxHeightFraction;

  /// Helper to display a [LiquidBottomSheet].
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    List<Widget>? actions,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x99000000),
      builder: (ctx) => LiquidBottomSheet(
        title: title,
        actions: actions,
        child: builder(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const sheetRadius = BorderRadius.vertical(top: Radius.circular(28.0));
    final maxHeight = MediaQuery.of(context).size.height * maxHeightFraction;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: sheetRadius,
          boxShadow: [
            BoxShadow(
              color: Color(0x77000000),
              blurRadius: 24.0,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: sheetRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: sheetRadius,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1C1C1C), Color(0xFF0C0C0C)],
                ),
                border: const Border(
                  top: BorderSide(color: Color(0x45FFFFFF), width: 1.0),
                  left: BorderSide(color: Color(0x18FFFFFF), width: 1.0),
                  right: BorderSide(color: Color(0x18FFFFFF), width: 1.0),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top drag handle shaped like an elongated liquid water bead
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                        width: 44.0,
                        height: 4.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0x30FFFFFF),
                              Color(0x60FFFFFF),
                              Color(0x30FFFFFF),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title!,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: LiquidColors.textPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                            if (actions != null) Row(children: actions!),
                          ],
                        ),
                      ),

                    Flexible(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
