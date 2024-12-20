import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/theme.dart';
import '../jinja.dart';
import '../../models/symbol.dart';

class JinjaServer extends JinjaService {
  JinjaServer(String url) {
    if (!url.endsWith('/')) {
      url += '/';
    }

    _baseUrl = Uri.parse(url);
  }

  late Uri _baseUrl;

  @override
  Future<bool> preloadTemplates(BuildContext context) async {
    final resp = await http.head(_baseUrl.resolve('status'));

    return resp.statusCode == 200;
  }

  @override
  Future<Iterable<String>> get librarySymbols async {
    final resp = await http.get(_baseUrl.resolve('library'));

    if (resp.statusCode != 200) {
      throw resp.body;
    }

    return (json.decode(resp.body)['symbols'] as Iterable).whereType<String>();
  }

  @override
  Future<Iterable<String>> get libraryThemes async {
    final resp = await http.get(_baseUrl.resolve('library'));

    if (resp.statusCode != 200) {
      throw resp.body;
    }

    return (json.decode(resp.body)['themes'] as Iterable).whereType<String>();
  }

  @override
  Future<String> buildSymbol(Symbol symbol, SymbolColorScheme scheme, [RenderType renderType = RenderType.svg]) async {
    String template = switch (symbol) {
      Unit() => 'unit',
      Vehicle(vehicleType: VehicleType.boot) => 'boat',
      Vehicle() => 'vehicle',
      CommandPost() => 'command_post',
      Building() => 'building',
      Hazard() => 'hazard',
      Device() => 'device',
      Person() => 'person',
      Post() => 'post',
      CommunicationsCondition() => 'communications_condition',
    };

    final params = urlParameters({
      ...extractOptions(symbol),
      'template': template,
      'scheme': json.encode(scheme),
      'render_type': renderType.name,
    });
    final resp = await http.get(_baseUrl.resolve('build?$params'));

    if (resp.statusCode != 200) {
      throw resp.body;
    }
    return utf8.decode(resp.bodyBytes);
  }

  @override
  Future<String> buildLibrarySymbol(String symbol, [String? theme, RenderType renderType = RenderType.svg]) async {
    final params = urlParameters({
      'symbol': symbol,
      'theme': theme,
      'render_type': renderType.name,
    });
    final resp = await http.get(_baseUrl.resolve('library?$params'));

    if (resp.statusCode != 200) {
      throw resp.body;
    }

    return utf8.decode(resp.bodyBytes);
  }

  @override
  Future<Iterable<String>> get symbolKeywords async {
    final resp = await http.get(_baseUrl.resolve('keywords'));

    if (resp.statusCode != 200) {
      throw resp.body;
    }

    return (json.decode(resp.body) as Iterable).whereType<String>();
  }

  @override
  Future<Iterable<String>> getKeywordFilteredSymbols(Iterable<String> keywords) async {
    final params = urlParameters({
      'filter': keywords,
    });
    final resp = await http.get(_baseUrl.resolve('identify?$params'));

    if (resp.statusCode != 200) {
      throw resp.body;
    }

    return (json.decode(resp.body) as Iterable).whereType<String>();
  }

  @override
  Future<Uint8List> convertToImage(Uint8List svg, RenderType renderType) async {
    final params = urlParameters({
      'render_type': renderType.name,
    });
    final resp = await http.post(
      _baseUrl.resolve('convert?$params'),
      body: svg,
      headers: {
        'Content-Type': 'image/svg+xml',
      },
    );

    if (resp.statusCode != 200) {
      throw resp.body;
    }

    return resp.bodyBytes;
  }
}

String urlParameters(Map<String, dynamic> params) {
  return params.entries
      .where((entry) => entry.value != null)
      .expand((entry) {
        if (entry.value is Iterable) {
          return (entry.value as Iterable).map((e) => '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(e.toString())}');
        }
        
        return ['${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value.toString())}'];
      })
      .join('&');
}
