import 'package:flutter/material.dart';

import '../models/building.dart';
import '../models/command_post.dart';
import '../models/person.dart';
import '../models/post.dart';
import '../models/symbol.dart';
import '../models/theme.dart';
import '../models/unit.dart';
import '../models/vehicle.dart';

abstract class JinjaService {
  Future<bool> preloadTemplates(BuildContext context);
  Future<String> buildSymbol(Symbol symbol, SymbolColors theme);
  Future<Iterable<String>> get librarySymbols;
  Future<String> buildLibrarySymbol(String symbol);
}

Map<String, dynamic> extractOptions(Symbol symbol) {
  final options = <String, dynamic>{};

  options['title'] = symbol.title;
  options['name'] = symbol.name;
  options['organisation'] = symbol.organisation;

  if (symbol is Unit) {
    options['is_leading'] = symbol.isLeading;
    options['is_logistics'] = symbol.isLogistics;
    options['unit_size'] = symbol.unitSize?.repr;
    options['type'] = symbol.type;
    options['subtext'] = symbol.subtext;
  } else if (symbol is Vehicle) {
    options['vehicle_type'] = symbol.vehicleType?.repr;
    options['type'] = symbol.type;
  } else if (symbol is CommandPost) {
    options['unit_size'] = symbol.unitSize?.repr;
  } else if (symbol is Building) {
    // no additional options
  } else if (symbol is Person) {
    options['is_leader'] = symbol.isLeader;
    options['is_specialist'] = symbol.isSpecialist;
    options['unit_size'] = symbol.unitSize?.repr;
    options['type'] = symbol.type;
    options['subtext'] = symbol.subtext;
  } else if (symbol is Post) {
    options['is_leading'] = symbol.isLeading;
    options['is_logistics'] = symbol.isLogistics;
    options['is_stationary'] = symbol.isStationary;
    options['subtext'] = symbol.subtext;
  } else {
    throw Exception('Unknown symbol type');
  }
  return options;
}
