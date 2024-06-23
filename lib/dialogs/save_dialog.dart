import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/library_symbol.dart';
import '../models/symbol.dart';
import '../services/file_saver.dart';

class SaveDialog extends StatelessWidget {
  const SaveDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.bytes,
  });

  final String title;
  final String? subtitle;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) Text(subtitle!),
          const SizedBox(height: 8),
          SizedBox(
            width: windowSize.shortestSide / 2,
            height: windowSize.shortestSide / 2,
            child: SvgPicture.memory(bytes),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () => saveFile(
            context,
            name: '${title.replaceAll(RegExp(r'\s'), '_')}.svg',
            bytes: bytes,
          ),
          icon: const Icon(Icons.save_alt),
          label: const Text('Save'),
        ),
      ],
    );
  }

  SaveDialog.fromLibrarySymbol({
    super.key,
    required LibrarySymbol symbol,
    required this.bytes,
  })  : title = symbol.name,
        subtitle = symbol.category;

  factory SaveDialog.fromSymbol({
    Key? key,
    required Symbol symbol,
    required Uint8List bytes,
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
    );
  }
}
