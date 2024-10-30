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

  @override
  void initState() {
    super.initState();

    settings.themeMode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    settings.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003399),
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003399),
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true
      ),
      themeMode: settings.themeMode.value,
      home: const MainPage(title: title),
    );
  }
}
