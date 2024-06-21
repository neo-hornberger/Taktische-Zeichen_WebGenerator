import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/jinja.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, required this.jinja});

  final JinjaService jinja;

  @override
  State<LibraryPage> createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  late List<String> _templates;

  Future<bool> _preloadTemplates(BuildContext context) async {
    final result = await widget.jinja.preloadTemplates(context);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: SearchBar(
            leading: const Icon(Icons.search),
            onChanged: (value) => print(value),
          ),
        ),
        Expanded(
          child: InitBuilder.arg(
            getter: widget.jinja.preloadTemplates,
            arg: context,
            builder: (context, future) {
              return AsyncBuilder(
                future: future,
                waiting: (context) => const Center(child: CircularProgressIndicator()),
                builder: (context, data) {
                  if (data == false) {
                    return _error(context, 'Failed to load templates');
                  }

                  const int crossAxisCount = 5;
                  final double size = MediaQuery.of(context).size.width / crossAxisCount;

                  return AsyncBuilder(
                    future: widget.jinja.librarySymbols,
                    waiting: (context) => const Center(child: CircularProgressIndicator()),
                    builder: (context, symbols) => CustomScrollView(
                      slivers: [
                        SliverGrid.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: symbols!.length,
                          itemBuilder: (context, index) => Card(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  AsyncBuilder(
                                    future:
                                        widget.jinja.buildLibrarySymbol(symbols.elementAt(index)),
                                    waiting: (context) => Container(
                                      padding: EdgeInsets.all(size / 4),
                                      width: size * 0.8,
                                      height: size * 0.8,
                                      child: const CircularProgressIndicator(),
                                    ),
                                    builder: (context, symbol) => SvgPicture.string(
                                      symbol!,
                                      width: size * 0.8,
                                      height: size * 0.8,
                                    ),
                                    error: (context, error, stackTrace) =>
                                        _error(context, 'Failed to load symbol', size / 2),
                                  ),
                                  Text(symbols.elementAt(index)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                error: (context, error, stackTrace) => _error(context, 'Failed to load library'),
              );
            },
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
              color: Theme.of(context).colorScheme.errorContainer,
            ),
            Text(message),
          ],
        ),
      );
}
