import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tokens.dart';

const _seed = Color(0xFF1F6F6A);

ColorScheme buildLightScheme() {
  return ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  ).copyWith(
    surface: const Color(0xFFF7F5F1),
    onSurface: const Color(0xFF1C1C1A),
    onSurfaceVariant: const Color(0xFF4E5554),
    outlineVariant: const Color(0xFFD9D6CF),
    primary: const Color(0xFF1F6F6A),
    onPrimary: const Color(0xFFF4FBF9),
  );
}

ColorScheme buildDarkScheme() {
  return ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  ).copyWith(
    surface: const Color(0xFF141516),
    onSurface: const Color(0xFFE6E3DC),
    onSurfaceVariant: const Color(0xFFB0B7B5),
    outlineVariant: const Color(0xFF3A3F3E),
    primary: const Color(0xFF7EC9C2),
    onPrimary: const Color(0xFF0A2F2D),
  );
}

TextTheme buildTextTheme(ColorScheme scheme) {
  return TextTheme(
    displayMedium: const TextStyle(
      fontSize: 52,
      height: 1.15,
      letterSpacing: -1.0,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    headlineMedium: const TextStyle(
      fontSize: 26,
      height: 1.2,
      letterSpacing: -0.3,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: const TextStyle(
      fontSize: 20,
      height: 1.2,
      letterSpacing: -0.2,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
    bodySmall: const TextStyle(
      fontSize: 12,
      height: 1.4,
      letterSpacing: 0.1,
    ),
    labelLarge: const TextStyle(
      fontSize: 14,
      height: 1.25,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w600,
    ),
  ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
}

ThemeData buildAppTheme(ColorScheme scheme) {
  final text = buildTextTheme(scheme);
  final ios = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: text,
    brightness: scheme.brightness,
    scaffoldBackgroundColor: scheme.surface,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: ios ? 0.1 : 0.5,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
      systemOverlayStyle: scheme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.card,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Insets.xl),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radii.md)),
        ),
        textStyle: WidgetStatePropertyAll(text.labelLarge),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Insets.xl),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radii.md)),
        ),
        textStyle: WidgetStatePropertyAll(text.labelLarge),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        textStyle: WidgetStatePropertyAll(text.labelLarge),
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: Insets.sm,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      shape: const RoundedRectangleBorder(borderRadius: Radii.card),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        foregroundColor: WidgetStatePropertyAll(scheme.onSurface),
      ),
    ),
  );
}
