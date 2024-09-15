import 'package:flutter/material.dart';

sealed class Symbol {
  String? title;
  String? name;
  String? organisation;

  Symbol copy();

  @protected
  void basecopyFrom(Symbol symbol) {
    title = symbol.title;
    name = symbol.name;
    organisation = symbol.organisation;
  }
}

class Unit extends Symbol {
  bool? isLeading;
  bool? isLogistics;
  UnitSize? unitSize;
  String? type;
  String? subtext;

  @override
  Symbol copy() => Unit()
    ..basecopyFrom(this)
    ..isLeading = isLeading
    ..isLogistics = isLogistics
    ..unitSize = unitSize
    ..type = type
    ..subtext = subtext;
}

enum UnitSize {
  trupp('Trupp'),
  staffel('Staffel'),
  gruppe('Gruppe'),
  zugtrupp('Zugtrupp'),
  zug('Zug'),
  bereitschaft('Verband'),
  abteilung('Verband 2'),
  grossverband('Verband 3');

  const UnitSize(this.repr);

  final String repr;
}

class Vehicle extends Symbol {
  VehicleType? vehicleType;
  String? type;

  @override
  Symbol copy() => Vehicle()
    ..basecopyFrom(this)
    ..vehicleType = vehicleType
    ..type = type;
}

enum VehicleType {
  kraftfahrzeug('Kfz'),
  kraftfahrzeug_gelaende('Kfz, gl'),
  wechselladerfahrzeug('WLF'),
  abrollbehaelter('AB'),
  anhaenger('Anh'),
  schienenfahrzeug('Schiene'),
  kettenfahrzeug('Kette'),

  boot('Boot');

  const VehicleType(this.repr);

  final String repr;
}

class CommandPost extends Symbol {
  UnitSize? unitSize;

  @override
  Symbol copy() => CommandPost()
    ..basecopyFrom(this)
    ..unitSize = unitSize;
}

class Building extends Symbol {
  @override
  Symbol copy() => Building()..basecopyFrom(this);
}

class Hazard extends Symbol {
  Color? color;
  bool? isAcute;
  bool? isPresumed;

  @override
  Symbol copy() => Hazard()
    ..basecopyFrom(this)
    ..color = color
    ..isAcute = isAcute
    ..isPresumed = isPresumed;
}

class Device extends Symbol {
  String? type;
  String? subtext;

  @override
  Symbol copy() => Device()
    ..basecopyFrom(this)
    ..type = type
    ..subtext = subtext;
}

class Person extends Symbol {
  bool? isLeader;
  bool? isSpecialist;
  UnitSize? unitSize;
  String? type;
  String? subtext;

  @override
  Symbol copy() => Person()
    ..basecopyFrom(this)
    ..isLeader = isLeader
    ..isSpecialist = isSpecialist
    ..unitSize = unitSize
    ..type = type
    ..subtext = subtext;
}

class Post extends Symbol {
  bool? isLeading;
  bool? isLogistics;
  bool? isStationary;
  String? subtext;

  @override
  Symbol copy() => Post()
    ..basecopyFrom(this)
    ..isLeading = isLeading
    ..isLogistics = isLogistics
    ..isStationary = isStationary
    ..subtext = subtext;
}

class CommunicationsCondition extends Symbol {
  String? medium;
  CommunicationsMediumType? mediumType;

  @override
  Symbol copy() => CommunicationsCondition()
    ..basecopyFrom(this)
    ..medium = medium
    ..mediumType = mediumType;
}

enum CommunicationsMediumType {
  bild('Bild'),
  bildfunk('Bild, Funk'),
  daten('Daten'),
  datenfunk('Daten, Funk'),
  datenfernsprech('Daten, Fernsprech'),
  digitaler_sprechfunk('Sprechfunk, digital'),
  fernschreiben('Fernschreiben'),
  fernschreibfunk('Fernschreiben, Funk'),
  fernsprechen('Fernsprechen'),
  sprechfunk('Fernsprechen, Funk'),
  festbild('Festbild'),
  festbildfunk('Festbild, Funk'),
  relaisfunk('Relaisfunk'),
  tasten('Tasten'),
  tasten_funk('Tasten, Funk');

  const CommunicationsMediumType(this.repr);

  final String repr;
}
