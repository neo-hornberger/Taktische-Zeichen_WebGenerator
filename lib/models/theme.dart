import 'package:flutter/material.dart';

class SymbolColors {
  SymbolColors({
    this.primary = const Color(0xffffffff),
    this.secondary = const Color(0xff000000),
    this.stroke = const Color(0xff000000),
  });

  Color primary;
  Color secondary;
  Color stroke;

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
