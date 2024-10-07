import 'package:flutter/material.dart';

enum SymbolTheme {
  DEFAULT('default', {
    'default': SymbolColorScheme(name: 'Default'),
    'bundeswehr': SymbolColorScheme(
      name: 'Bundeswehr',
      primary: Color(0xff996633),
      secondary: Color(0xffffffff),
      stroke: Color(0xff000000),
    ),
    'feuerwehr': SymbolColorScheme(
      name: 'Feuerwehr',
      primary: Color(0xffff0000),
      secondary: Color(0xffffffff),
      stroke: Color(0xff000000),
    ),
    'fuehrung': SymbolColorScheme(
      name: 'Führung',
      primary: Color(0xffffff00),
      secondary: Color(0xff000000),
      stroke: Color(0xff000000),
    ),
    'katastrophenschutz': SymbolColorScheme(
      name: 'Katastrophenschutz',
      primary: Color(0xffdf6711),
      secondary: Color(0xffffffff),
      stroke: Color(0xff000000),
    ),
    'polizei': SymbolColorScheme(
      name: 'Polizei',
      primary: Color(0xff13a538),
      secondary: Color(0xffffffff),
      stroke: Color(0xff000000),
    ),
    'thw': SymbolColorScheme(
      name: 'THW',
      primary: Color(0xff003399),
      secondary: Color(0xffffffff),
      stroke: Color(0xff000000),
    ),
  });

  const SymbolTheme(this.name, this.schemes);

  final String name;
  final Map<String, SymbolColorScheme> schemes;

  SymbolColorScheme get default_ => schemes['default']!;
  SymbolColorScheme get bundeswehr => schemes['bundeswehr']!;
  SymbolColorScheme get feuerwehr => schemes['feuerwehr']!;
  SymbolColorScheme get fuehrung => schemes['fuehrung']!;
  SymbolColorScheme get katastrophenschutz => schemes['katastrophenschutz']!;
  SymbolColorScheme get polizei => schemes['polizei']!;
  SymbolColorScheme get thw => schemes['thw']!;
}

class SymbolColorScheme {
  const SymbolColorScheme({
    required this.name,
    this.primary = const Color(0xffffffff),
    this.secondary = const Color(0xff000000),
    this.stroke = const Color(0xff000000),
  });

  final String name;
  final Color primary;
  final Color secondary;
  final Color stroke;

  toJson() => {
        'colorPrimary': primary.toCSS(),
        'colorSecondary': secondary.toCSS(),
        'colorStroke': stroke.toCSS(),
      };
}

extension ColorCSS on Color {
  String toCSS() =>
      '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
}
