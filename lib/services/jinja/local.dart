import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jinja/jinja.dart';

import '../../models/theme.dart';
import '../jinja.dart';
import '../../models/building.dart';
import '../../models/command_post.dart';
import '../../models/person.dart';
import '../../models/post.dart';
import '../../models/symbol.dart';
import '../../models/unit.dart';
import '../../models/vehicle.dart';

final _env = Environment(
  loader: AssetLoader(),
);

class JinjaLocal extends JinjaService {
  @override
  Future<bool> preloadTemplates(BuildContext context) async =>
      await (_env.loader as AssetLoader).preload(DefaultAssetBundle.of(context));

  @override
  Future<String> buildSymbol(Symbol symbol, SymbolColors theme) async {
    Template template;
    if (symbol is Unit) {
      template = _env.getTemplate('templates/einheit.j2t');
    } else if (symbol case Vehicle v) {
      if (v.vehicleType == VehicleType.boot) {
        template = _env.getTemplate('templates/boot.j2t');
      } else {
        template = _env.getTemplate('templates/fahrzeug.j2t');
      }
    } else if (symbol is CommandPost) {
      template = _env.getTemplate('templates/führungsstelle.j2t');
    } else if (symbol is Building) {
      template = _env.getTemplate('templates/gebäude.j2t');
    } else if (symbol is Person) {
      template = _env.getTemplate('templates/person.j2t');
    } else if (symbol is Post) {
      template = _env.getTemplate('templates/stelle.j2t');
    } else {
      throw Exception('Unknown symbol type');
    }

    return template.render();
  }

  @override
  Future<Iterable<String>> get librarySymbols async => (_env.loader as AssetLoader).getSymbols();

  @override
  Future<String> buildLibrarySymbol(String symbol) async => _env.getTemplate(symbol).render();
}

class AssetLoader extends Loader {
  static final RegExp templateRegex = RegExp(r'assets/Taktische-Zeichen/templates/(.+\.j2t)$');
  static final RegExp fontsRegex = RegExp(r'assets/Taktische-Zeichen/fonts/(.+\.j2)$');
  static final RegExp symbolsRegex = RegExp(r'assets/Taktische-Zeichen/symbols/(.+\.j2)$');

  final Map<String, String> _templates = {};
  final Map<String, ByteData?> _symbols = {};

  Future<bool> preload(AssetBundle bundle) async {
    final Iterable<String> assets = await bundle
        .loadString('AssetManifest.json')
        .then(json.decode)
        .then((assets) => assets.keys);

    _filterAssets(assets, templateRegex).forEach((template) async {
      _templates['templates/$template'] =
          await bundle.loadString('assets/Taktische-Zeichen/templates/$template');
    });
    _filterAssets(assets, fontsRegex).forEach((font) async {
      _templates['./fonts/$font'] = await bundle.loadString('assets/Taktische-Zeichen/fonts/$font');
    });

    _filterAssets(assets, symbolsRegex).forEach((symbol) async {
      _symbols[symbol] = await bundle.load('assets/Taktische-Zeichen/symbols/$symbol');
    });

    return true;
  }

  @override
  String getSource(String path) {
    if (path.startsWith('symbols/')) {
      path = path.substring(8);

      if (_symbols.containsKey(path)) {
        return _decode(_symbols[path]!);
      }
    } else if (_templates.containsKey(path)) {
      return _templates[path]!;
    }

    throw TemplateNotFound(name: path);
  }

  @override
  List<String> listTemplates() => [
        ..._templates.keys,
        ..._symbols.keys,
      ];

  @override
  Template load(Environment environment, String path, {Map<String, Object?>? globals}) {
    return environment.fromString(
      getSource(path),
      path: path,
      globals: globals,
    );
  }

  Iterable<String> getSymbols() => _symbols.keys;

  String _decode(ByteData data) => utf8.decode(Uint8List.sublistView(data));
}

Iterable<String> _filterAssets(Iterable<String> assets, RegExp regex) sync* {
  for (final asset in assets) {
    final match = regex.matchAsPrefix(asset);
    if (match != null) {
      yield match.group(1)!;
    }
  }
}
