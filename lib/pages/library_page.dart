import 'dart:convert';
import 'dart:typed_data';

import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../dialogs/save_dialog.dart';
import '../models/library_symbol.dart';
import '../services/jinja.dart';

const double searchBoxPadding = 8.0;
final ShapeBorder cardBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, required this.jinja});

  final JinjaService jinja;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  Iterable<String> _symbols = [];
  Iterable<String> _themes = [];

  Iterable<String> _filteredSymbols = [];
  String? _theme;

  Future<bool> _preloadTemplates(BuildContext context) async {
    final result = await widget.jinja.preloadTemplates(context);

    if (result) {
      final symbols = await widget.jinja.librarySymbols;
      final themes = await widget.jinja.libraryThemes;

      setState(() {
        _symbols = symbols;
        _themes = themes;
        _filteredSymbols = symbols;
      });
    }

    return result;
  }

  void _filterSymbols(String query) {
    final words = query.trim().toLowerCase().split(' ');

    setState(() {
      _filteredSymbols = _symbols
          .where((element) => words.every((query) => element.toLowerCase().contains(query)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(searchBoxPadding),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: searchBoxPadding),
                    child: Icon(Icons.search),
                  ),
                  trailing: [
                    Text(
                      '${_filteredSymbols.length} / ${_symbols.length}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: searchBoxPadding),
                  ],
                  onChanged: _filterSymbols,
                ),
              ),
              const SizedBox(width: searchBoxPadding),
              IconButton(
                icon: const Icon(Icons.palette),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  shadowColor: Theme.of(context).colorScheme.shadow,
                  elevation: 6.0,
                ),
                constraints: const BoxConstraints(minWidth: 56.0, minHeight: 56.0),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Select theme'),
                    contentPadding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 24.0),
                    children: _themes.map((theme) {
                      return SimpleDialogOption(
                        onPressed: () {
                          setState(() => _theme = theme);
                          Navigator.pop(context);
                        },
                        child: Text(
                          theme,
                          style: TextStyle(
                            inherit: true,
                            color: theme == _theme ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: InitBuilder.arg(
            getter: _preloadTemplates,
            arg: context,
            builder: (context, future) => AsyncBuilder(
              future: future,
              waiting: (context) => const Center(child: CircularProgressIndicator()),
              builder: (context, data) {
                if (data == false) {
                  return _error(context, 'Failed to load library');
                }

                final Size windowSize = MediaQuery.of(context).size;
                final int crossAxisCount = windowSize.width ~/ 175;
                final double size = windowSize.width / crossAxisCount;

                return CustomScrollView(
                  slivers: [
                    SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _filteredSymbols.length,
                      itemBuilder: (context, index) {
                        final symbol = LibrarySymbol.parse(_filteredSymbols.elementAt(index));
                        Uint8List bytes = Uint8List(0);

                        return Card(
                          shape: cardBorder,
                          child: InkWell(
                            customBorder: cardBorder,
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => SaveDialog.fromLibrarySymbol(
                                symbol: symbol,
                                bytes: bytes,
                                jinja: widget.jinja,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  AsyncBuilder(
                                    future: widget.jinja.buildLibrarySymbol(symbol.path, _theme),
                                    waiting: (context) => Container(
                                      padding: EdgeInsets.all(size / 4),
                                      width: size * 0.8,
                                      height: size * 0.8,
                                      child: const CircularProgressIndicator(),
                                    ),
                                    builder: (context, symbol) {
                                      bytes = utf8.encode(symbol!);

                                      return SizedBox(
                                        width: size * 0.8,
                                        height: size * 0.8,
                                        child: SvgPicture.string(symbol),
                                      );
                                    },
                                    error: (context, error, stackTrace) =>
                                        _error(context, 'Failed to load symbol', size / 2),
                                  ),
                                  Text(
                                    symbol.category,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  Text(
                                    symbol.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _error(BuildContext context, String message, [double? size]) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: size ?? MediaQuery.of(context).size.shortestSide / 2.0,
              color: Theme.of(context).colorScheme.error,
            ),
            Text(message),
          ],
        ),
      );
}
