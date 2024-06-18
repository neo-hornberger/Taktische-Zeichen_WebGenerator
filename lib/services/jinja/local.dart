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
}

class AssetLoader extends Loader {
  final Map<String, String> _templates = {};

  Future<bool> preload(AssetBundle bundle) async {
    for (var template in [
      'base.j2t',
      //
      'boot.j2t',
      'einheit.j2t',
      'fahrzeug.j2t',
      'führungsstelle.j2t',
      'gebäude.j2t',
      'person.j2t',
      'stelle.j2t',
    ]) {
      _templates['templates/$template'] =
          await bundle.loadString('assets/Taktische-Zeichen/templates/$template');
    }
    for (var font in [
      'fonts.j2',
      //
      'bundessans.css.j2',
    ]) {
      _templates['./fonts/$font'] = await bundle.loadString('assets/Taktische-Zeichen/fonts/$font');
    }

    return true;
  }

  @override
  String getSource(String path) {
    if (!_templates.containsKey(path)) {
      throw TemplateNotFound(name: path);
    }

    return _templates[path]!;
  }

  @override
  List<String> listTemplates() => _templates.keys.toList();

  @override
  Template load(Environment environment, String path, {Map<String, Object?>? globals}) {
    return environment.fromString(
      getSource(path),
      path: path,
      globals: globals,
    );
  }
}
