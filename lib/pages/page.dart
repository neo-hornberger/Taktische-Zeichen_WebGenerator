import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import '../services/jinja.dart';
import '../services/jinja/local.dart';
import '../services/jinja/server.dart';
import 'editor_page.dart';
import 'library_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<EditorPageState> _editorKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();

  final JinjaService _jinja = JinjaServer();

  Page _currentPage = Page.editor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
            key: _galleryKey,
            jinja: _jinja,
          ),
      };

  FloatingActionButton? _fab() => switch (_currentPage) {
        Page.editor => FloatingActionButton(
            onPressed: () async {
              final theme = Theme.of(context);

              SnackBar snackBar;
              try {
                final file = await FileSaver.instance.saveFile(
                  name: 'symbol.svg',
                  bytes: _editorKey.currentState?.source,
                  mimeType: MimeType.custom,
                  customMimeType: 'image/svg+xml',
                );
                snackBar = SnackBar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  content: Text(
                    'Saved to $file',
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                  ),
                );
              } catch (e) {
                snackBar = SnackBar(
                  backgroundColor: theme.colorScheme.errorContainer,
                  content: Text(
                    e.toString(),
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                );
              }

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            tooltip: 'Save',
            child: const Icon(Icons.save),
          ),
        Page.library => null,
      };
}

enum Page {
  editor('Editor', Icons.draw_outlined),
  library('Library', Icons.photo_library_outlined);

  const Page(this.title, this.icon);

  final String title;
  final IconData icon;
}
