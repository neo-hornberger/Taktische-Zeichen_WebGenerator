import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/theme.dart';
import '../jinja.dart';
import '../../models/symbol.dart';

class JinjaServer extends JinjaService {
  JinjaServer() {
    String url = const String.fromEnvironment(
      'JINJA_URL',
      defaultValue: 'http://localhost:9000/',
    );

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

    return (json.decode(resp.body) as Iterable).whereType<String>();
  }

  @override
  Future<String> buildSymbol(Symbol symbol, SymbolColors theme) async {
    String template = switch(symbol) {
      Unit() => 'unit',
      Vehicle(vehicleType: VehicleType.boot) => 'boat',
      Vehicle() => 'vehicle',
      CommandPost() => 'command_post',
      Building() => 'building',
      Hazard() => 'hazard',
      Device() => 'device',
      Person() => 'person',
      Post() => 'post',
    };

    final params = {
      ...extractOptions(symbol),
      'template': template,
      'theme': json.encode(theme),
    }
        .entries
        .where((entry) => entry.value != null)
        .map((entry) =>
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value.toString())}')
        .join('&');
    final resp = await http.get(_baseUrl.resolve('build?$params'));

    if (resp.statusCode != 200) {
      throw resp.body;
    }
    return utf8.decode(resp.bodyBytes);
  }

  @override
  Future<String> buildLibrarySymbol(String symbol) async {
    final resp = await http.get(_baseUrl.resolve('library?symbol=${Uri.encodeQueryComponent(symbol)}'));

    if (resp.statusCode != 200) {
      throw resp.body;
    }

    return utf8.decode(resp.bodyBytes);
  }
}
