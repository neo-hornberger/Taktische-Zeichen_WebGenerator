import 'package:flutter/material.dart';

class Settings {
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  final ValueNotifier<bool> jinjaServerEnabled = ValueNotifier(true);
  final ValueNotifier<String> jinjaServerUrl = ValueNotifier(const String.fromEnvironment(
    'JINJA_URL',
    defaultValue: 'http://localhost:9000/',
  ));

  void dispose() {
    themeMode.dispose();
    jinjaServerEnabled.dispose();
    jinjaServerUrl.dispose();
  }
}
