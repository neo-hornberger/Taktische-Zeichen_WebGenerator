import 'package:flutter/foundation.dart';

class Settings {
  final ValueNotifier<Brightness> brightness = ValueNotifier(Brightness.dark);

  final ValueNotifier<bool> jinjaServerEnabled = ValueNotifier(true);
  final ValueNotifier<String> jinjaServerUrl = ValueNotifier(const String.fromEnvironment(
    'JINJA_URL',
    defaultValue: 'http://localhost:9000/',
  ));
}
