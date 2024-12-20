import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

void saveFile(BuildContext context, {String? name, Uint8List? bytes, String? mimeType}) async {
  final theme = Theme.of(context);
  final scaffoldMsgr = ScaffoldMessenger.of(context);

  SnackBar snackBar;
  try {
    final file = await FileSaver.instance.saveFile(
      name: name ?? 'symbol.svg',
      bytes: bytes,
      mimeType: MimeType.custom,
      customMimeType: mimeType ?? 'image/svg+xml',
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

  scaffoldMsgr.showSnackBar(snackBar);
}
