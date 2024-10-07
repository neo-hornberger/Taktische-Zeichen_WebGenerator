import 'package:flutter/material.dart';

import '../models/symbol.dart';
import '../models/theme.dart';

abstract class JinjaService {
  Future<bool> preloadTemplates(BuildContext context);
  Future<String> buildSymbol(Symbol symbol, SymbolColorScheme scheme);
  Future<Iterable<String>> get librarySymbols;
  Future<String> buildLibrarySymbol(String symbol);
}

Map<String, dynamic> extractOptions(Symbol symbol) {
  final options = <String, dynamic>{};

  options['title'] = symbol.title;
  options['name'] = symbol.name;
  options['organisation'] = symbol.organisation;

  switch (symbol) {
    case Unit():
      options['is_leading'] = symbol.isLeading;
      options['is_logistics'] = symbol.isLogistics;
      options['unit_size'] = symbol.unitSize?.repr;
      options['type'] = symbol.type;
      options['subtext'] = symbol.subtext;
    case Vehicle():
      options['vehicle_type'] = symbol.vehicleType?.repr;
      options['type'] = symbol.type;
    case CommandPost():
      options['unit_size'] = symbol.unitSize?.repr;
    case Building():
      break;
    case Hazard():
      options['color'] = symbol.color?.toCSS();
      options['is_acute'] = symbol.isAcute;
      options['is_presumed'] = symbol.isPresumed;
    case Device():
      options['type'] = symbol.type;
      options['subtext'] = symbol.subtext;
    case Person():
      options['is_leader'] = symbol.isLeader;
      options['is_specialist'] = symbol.isSpecialist;
      options['unit_size'] = symbol.unitSize?.repr;
      options['type'] = symbol.type;
      options['subtext'] = symbol.subtext;
    case Post():
      options['is_leading'] = symbol.isLeading;
      options['is_logistics'] = symbol.isLogistics;
      options['is_stationary'] = symbol.isStationary;
      options['subtext'] = symbol.subtext;
    case CommunicationsCondition():
      options['medium_type'] = symbol.mediumType?.repr;
      options['medium'] = symbol.medium;
  }

  return options;
}
