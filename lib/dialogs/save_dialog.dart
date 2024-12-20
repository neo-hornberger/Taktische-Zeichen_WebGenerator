import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/library_symbol.dart';
import '../models/symbol.dart';
import '../services/file_saver.dart';
import '../services/jinja.dart';

class SaveDialog extends StatefulWidget {
  const SaveDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.bytes,
    required this.jinja,
  });

  final String title;
  final String? subtitle;
  final Uint8List bytes;

  final JinjaService jinja;

  @override
  State<SaveDialog> createState() => _SaveDialogState();

  SaveDialog.fromLibrarySymbol({
    super.key,
    required LibrarySymbol symbol,
    required this.bytes,
    required this.jinja,
  })  : title = symbol.name,
        subtitle = symbol.category;

  factory SaveDialog.fromSymbol({
    Key? key,
    required Symbol symbol,
    required Uint8List bytes,
    required JinjaService jinja,
  }) {
    String title = 'symbol';

    if (symbol.title != null && symbol.title!.isNotEmpty) {
      title = symbol.title!;
    } else if (symbol.name != null && symbol.name!.isNotEmpty) {
      title = symbol.name!;
    }

    return SaveDialog(
      key: key,
      title: title,
      subtitle: null,
      bytes: bytes,
      jinja: jinja,
    );
  }
}

class _SaveDialogState extends State<SaveDialog> {
  RenderType _renderType = RenderType.svg;
  int _renderSize = sizes[1];

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.subtitle != null) Text(widget.subtitle!),
          const SizedBox(height: 8),
          SizedBox(
            width: windowSize.shortestSide / 2,
            height: windowSize.shortestSide / 2,
            child: SvgPicture.memory(widget.bytes),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Format:'),
              const SizedBox(width: 8),
              DropdownButton(
                items: RenderType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        ))
                    .toList(),
                value: _renderType,
                onChanged: (type) => setState(() => _renderType = type!),
              ),
              if (_renderType != RenderType.svg) ...[
                const SizedBox(width: 16),
                const Text('Size:'),
                const SizedBox(width: 8),
                DropdownButton(
                  items: sizes
                      .map((size) => DropdownMenuItem(
                            value: size,
                            child: Text('${size}px'),
                          ))
                      .toList(),
                  value: _renderSize,
                  onChanged: (size) => setState(() => _renderSize = size!),
                ),
              ],
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () async {
            Uint8List bytes = widget.bytes;
            if (_renderType != RenderType.svg) {
              bytes = await widget.jinja.convertToImage(widget.bytes, _renderType);
            }

            saveFile(
              context,
              name: '${widget.title.replaceAll(RegExp(r'\s'), '_')}.${_renderType.fileExtension}',
              bytes: bytes,
              mimeType: _renderType.mimeType,
            );
          },
          icon: const Icon(Icons.save_alt),
          label: const Text('Save'),
        ),
      ],
    );
  }
}

const List<int> sizes = [256, 512, 1024, 2048];
