import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taktische_zeichen/models/library_symbol.dart';
import 'package:taktische_zeichen/pages/library_page.dart';

import '../services/jinja.dart';

const double searchBoxPadding = 8.0;

class IdentifierPage extends StatefulWidget {
  const IdentifierPage({super.key, required this.jinja});

  final JinjaService jinja;

  @override
  State<IdentifierPage> createState() => _IdentifierPageState();
}

class _IdentifierPageState extends State<IdentifierPage> {
  final GlobalKey<State<SearchBar>> _searchBarKey = GlobalKey();

  Iterable<String> _availableKeywords = [];
  Iterable<String> _filteredKeywords = [];

  final Set<String> _filters = {};

  bool _showFilterRow = true;

  late TextEditingController _searchBarController;
  late FocusNode _searchFocusNode;

  OverlayEntry? _filterMenu;

  Future<bool> _preloadTemplates(BuildContext context) async {
    final result = await widget.jinja.preloadTemplates(context);

    if (result) {
      final keywords = (await widget.jinja.symbolKeywords).toList();
      keywords.sort();

      setState(() => _availableKeywords = keywords);
    }

    return result;
  }

  void _openFilterMenu(String value) {
    _filteredKeywords =
        _availableKeywords.where((keyword) => keyword.toLowerCase().contains(value.toLowerCase()));

    if (_filterMenu != null) {
      _closeFilterMenu();
    }

    final renderObject = _searchBarKey.currentContext!.findRenderObject()!;
    final translation = renderObject.getTransformTo(null).getTranslation();
    final top = translation.y + renderObject.semanticBounds.height + 8;

    _filterMenu = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: translation.x,
          top: top,
          width: renderObject.semanticBounds.width,
          child: LimitedBox(
            maxHeight: MediaQuery.of(context).size.height - top - 8,
            child: Material(
              elevation: 8.0,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16.0),
              clipBehavior: Clip.antiAlias,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final keyword in _filteredKeywords)
                    ListTile(
                      title: Text(keyword),
                      onTap: () {
                        setState(() => _filters.add(keyword));

                        _closeFilterMenu();
                        _searchBarController.clear();
                        _searchFocusNode.requestFocus();
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_filterMenu!);
  }

  void _closeFilterMenu() {
    _filterMenu?.remove();
    _filterMenu?.dispose();
    _filterMenu = null;
  }

  @override
  void initState() {
    super.initState();

    _searchBarController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        print('Focus lost');
        //_closeFilterMenu();
      }
    });
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    _searchFocusNode.dispose();
    _closeFilterMenu();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(searchBoxPadding),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      key: _searchBarKey,
                      controller: _searchBarController,
                      focusNode: _searchFocusNode,
                      leading: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: searchBoxPadding),
                        child: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        value = value.trim();

                        if (value.isNotEmpty) {
                          _openFilterMenu(value);
                        }
                      },
                      onSubmitted: (value) {
                        value = value.trim();

                        if (_availableKeywords.contains(value)) {
                          setState(() => _filters.add(value));
                        }

                        _searchBarController.clear();
                        _searchFocusNode.requestFocus();
                      },
                    ),
                  ),
                  const SizedBox(width: searchBoxPadding),
                  IconButton(
                    icon: const Icon(Icons.filter_alt_off),
                    tooltip: 'Clear all filters',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      elevation: 6.0,
                    ),
                    constraints: const BoxConstraints(minWidth: 56.0, minHeight: 56.0),
                    onPressed: () {
                      setState(() => _filters.clear());
                      _searchFocusNode.requestFocus();
                    },
                  ),
                  const SizedBox(width: searchBoxPadding),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: _showFilterRow ? 'Hide filters' : 'Show filters',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      elevation: 6.0,
                    ),
                    constraints: const BoxConstraints(minWidth: 56.0, minHeight: 56.0),
                    onPressed: () {
                      setState(() => _showFilterRow = !_showFilterRow);
                      _searchFocusNode.requestFocus();
                    },
                  ),
                ],
              ),
              const SizedBox(height: searchBoxPadding),
              if (_showFilterRow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final filter in _filters)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: searchBoxPadding / 2),
                        child: Chip(
                          label: Text(filter),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                          onDeleted: () {
                            setState(() => _filters.remove(filter));
                            _searchFocusNode.requestFocus();
                          },
                        ),
                      ),
                  ],
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
                  return _error(context, 'Failed to load keywords');
                }

                return AsyncBuilder(
                  future: widget.jinja.getKeywordFilteredSymbols(_filters),
                  waiting: (context) => const Center(child: CircularProgressIndicator()),
                  builder: (context, data) {
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
                          itemCount: data!.length,
                          itemBuilder: (context, index) {
                            final symbol = LibrarySymbol.parse(data.elementAt(index));

                            return Card(
                              shape: cardBorder,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    AsyncBuilder(
                                      future: widget.jinja.buildLibrarySymbol(symbol.path),
                                      waiting: (context) => Container(
                                        padding: EdgeInsets.all(size / 4),
                                        width: size * 0.8,
                                        height: size * 0.8,
                                        child: const CircularProgressIndicator(),
                                      ),
                                      builder: (context, symbol) {
                                        return SizedBox(
                                          width: size * 0.8,
                                          height: size * 0.8,
                                          child: SvgPicture.string(symbol!),
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
                            );
                          },
                        ),
                      ],
                    );
                  },
                  error: (context, error, stackTrace) => _error(context, 'Failed to load symbols'),
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
