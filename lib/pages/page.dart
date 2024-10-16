import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dialogs/save_dialog.dart';
import '../main.dart';
import '../services/jinja.dart';
import '../services/jinja/local.dart';
import '../services/jinja/server.dart';
import 'editor_page.dart';
import 'library_page.dart';
import 'settings_page.dart';

final Uri repositoryUrl =
    Uri.parse('https://github.com/neo-hornberger/Taktische-Zeichen_WebGenerator');
final Uri libraryUrl = Uri.parse('https://github.com/neo-hornberger/Taktische-Zeichen');

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<EditorPageState> _editorKey = GlobalKey();

  late JinjaService _jinja;
  String? _packageVersion;
  Page _currentPage = Page.editor;

  set _jinjaServer(String url) => setState(() => _jinja = JinjaServer(url));

  void _changeBrightness() {
    final brightness = context.findAncestorStateOfType<ApplicationState>()!.settings.brightness;
    brightness.value = brightness.value == Brightness.dark ? Brightness.light : Brightness.dark;
  }

  IconData get _brightnessIcon =>
      context.findAncestorStateOfType<ApplicationState>()!.settings.brightness.value ==
              Brightness.dark
          ? Icons.light_mode
          : Icons.dark_mode;

  @override
  void initState() {
    super.initState();

    final state = context.findAncestorStateOfType<ApplicationState>()!;

    bool useJinjaServer = state.settings.jinjaServerEnabled.value;
    if (useJinjaServer) {
      _jinjaServer = state.settings.jinjaServerUrl.value;
    } else {
      setState(() => _jinja = JinjaLocal());
    }

    state.settings.jinjaServerEnabled.addListener(() {
      if (state.settings.jinjaServerEnabled.value) {
        _jinjaServer = state.settings.jinjaServerUrl.value;
      } else {
        setState(() => _jinja = JinjaLocal());
      }
    });
    state.settings.jinjaServerUrl
        .addListener(() => _jinjaServer = state.settings.jinjaServerUrl.value);

    PackageInfo.fromPlatform().then((info) => setState(() => _packageVersion = info.version));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _changeBrightness,
            icon: Icon(_brightnessIcon),
          ),
          IconButton(
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: widget.title,
              applicationVersion: _packageVersion ?? 'unknown',
              applicationLegalese: 'by Neo Hornberger',
              children: [
                const SizedBox(height: 16),
                Text.rich(TextSpan(
                  children: [
                    const WidgetSpan(child: Icon(Icons.code)),
                    const WidgetSpan(child: SizedBox(width: 10)),
                    TextSpan(
                      text: repositoryUrl.toString(),
                      style: const TextStyle(decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () => launchUrl(repositoryUrl),
                    ),
                  ],
                )),
                Text.rich(TextSpan(
                  children: [
                    const WidgetSpan(child: Icon(Icons.photo_library_outlined)),
                    const WidgetSpan(child: SizedBox(width: 10)),
                    TextSpan(
                      text: libraryUrl.toString(),
                      style: const TextStyle(decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () => launchUrl(libraryUrl),
                    ),
                  ],
                )),
              ],
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            ...Page.values.map((page) => ListTile(
                  title: Text(page.title),
                  leading: Icon(page.icon),
                  selected: _currentPage == page,
                  onTap: () {
                    setState(() {
                      _currentPage = page;
                    });
                    Navigator.pop(context);
                  },
                )),
            const Divider(),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings),
              onTap: _openSettings,
            ),
          ],
        ),
      ),
      body: _page(),
      floatingActionButton: _fab(),
    );
  }

  Widget _page() => switch (_currentPage) {
        Page.editor => EditorPage(
            key: _editorKey,
            jinja: _jinja,
          ),
        Page.library => LibraryPage(
            jinja: _jinja,
          ),
      };

  FloatingActionButton? _fab() => switch (_currentPage) {
        Page.editor => FloatingActionButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => SaveDialog.fromSymbol(
                symbol: _editorKey.currentState!.symbol,
                bytes: Uint8List.fromList(_editorKey.currentState!.source!),
              ),
            ),
            tooltip: 'Save',
            child: const Icon(Icons.save),
          ),
        Page.library => null,
      };

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }
}

enum Page {
  editor('Editor', Icons.draw_outlined),
  library('Library', Icons.photo_library_outlined);

  const Page(this.title, this.icon);

  final String title;
  final IconData icon;
}
