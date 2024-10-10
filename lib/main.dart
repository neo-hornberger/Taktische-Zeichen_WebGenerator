import 'package:flutter/material.dart';

import 'models/settings.dart';
import 'pages/page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Application());
}

const String title = 'Taktische Zeichen WebGenerator';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => ApplicationState();
}

class ApplicationState extends State<Application> {
  final Settings settings = Settings();

  Brightness _brightness = Brightness.dark;

  Brightness get brightness => _brightness;
  set brightness(Brightness value) => setState(() => _brightness = value);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003399),
          brightness: _brightness,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(title: title),
    );
  }
}
