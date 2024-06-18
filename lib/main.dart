import 'package:flutter/material.dart';

import 'pages/page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taktische Zeichen WebGenerator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003399),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'Taktische Zeichen WebGenerator'),
    );
  }
}
