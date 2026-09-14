import 'package:flutter/material.dart';
import 'package:volume_controller_example/home_page.dart';
import 'package:volume_controller_example/theme/app_theme.dart';

class VolumeExampleApp extends StatefulWidget {
  const VolumeExampleApp({super.key});

  @override
  State<VolumeExampleApp> createState() => _VolumeExampleAppState();
}

class _VolumeExampleAppState extends State<VolumeExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volume Controller',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(buildLightScheme()),
      darkTheme: buildAppTheme(buildDarkScheme()),
      themeMode: _themeMode,
      home: HomePage(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }

  void _toggleTheme() {
    final platformDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    final isDark = _themeMode == ThemeMode.system
        ? platformDark
        : _themeMode == ThemeMode.dark;
    setState(() {
      _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }
}
