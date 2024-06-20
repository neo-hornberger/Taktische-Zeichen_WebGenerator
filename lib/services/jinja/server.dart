import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/theme.dart';
import '../jinja.dart';
import '../../models/building.dart';
import '../../models/command_post.dart';
import '../../models/person.dart';
import '../../models/post.dart';
import '../../models/unit.dart';
import '../../models/vehicle.dart';
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
  Future<String> buildSymbol(Symbol symbol, SymbolColors theme) async {
    String template;
    if (symbol is Unit) {
      template = 'unit';
    } else if (symbol is Vehicle) {
      if (symbol.vehicleType == VehicleType.boot) {
        template = 'boat';
      } else {
        template = 'vehicle';
      }
    } else if (symbol is CommandPost) {
      template = 'command_post';
    } else if (symbol is Building) {
      template = 'building';
    } else if (symbol is Person) {
      template = 'person';
    } else if (symbol is Post) {
      template = 'post';
    } else {
      throw Exception('Unknown symbol type');
    }

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
    return resp.body;
  }
}
