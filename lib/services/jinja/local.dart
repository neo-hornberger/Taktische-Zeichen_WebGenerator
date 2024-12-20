import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jinja/jinja.dart';

import '../../models/theme.dart';
import '../jinja.dart';
import '../../models/symbol.dart';

final _env = Environment(
  loader: AssetLoader(),
);

class JinjaLocal extends JinjaService {
  @override
  Future<bool> preloadTemplates(BuildContext context) async =>
      await (_env.loader as AssetLoader).preload(DefaultAssetBundle.of(context));

  @override
  Future<String> buildSymbol(Symbol symbol, SymbolColorScheme scheme, [RenderType renderType = RenderType.svg]) async {
    if (renderType != RenderType.svg) {
      throw UnimplementedError();
    }

    String template = switch (symbol) {
      Unit() => 'einheit',
      Vehicle(vehicleType: VehicleType.boot) => 'boot',
      Vehicle() => 'fahrzeug',
      CommandPost() => 'führungsstelle',
      Building() => 'gebäude',
      Hazard() => 'gefahr',
      Device() => 'gerät',
      Person() => 'person',
      Post() => 'stelle',
      CommunicationsCondition() => 'fernmeldewesen_bedingung',
    };

    return _env.getTemplate('templates/$template.j2t').render();
  }

  @override
  Future<Iterable<String>> get librarySymbols async => (_env.loader as AssetLoader).getSymbols();

  @override
  Future<Iterable<String>> get libraryThemes async => throw UnimplementedError();

  @override
  Future<String> buildLibrarySymbol(String symbol, [String? theme, RenderType renderType = RenderType.svg]) async {
    if (renderType != RenderType.svg) {
      throw UnimplementedError();
    }

    return _env.getTemplate(symbol).render();
  }

  @override
  Future<Iterable<String>> get symbolKeywords async => throw UnimplementedError();

  @override
  Future<Iterable<String>> getKeywordFilteredSymbols(Iterable<String> keywords) async => throw UnimplementedError();

  @override
  Future<Uint8List> convertToImage(Uint8List svg, RenderType renderType, int renderSize) async {
    if (renderType == RenderType.svg) {
      return svg;
    }

    throw UnimplementedError();
  }
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
