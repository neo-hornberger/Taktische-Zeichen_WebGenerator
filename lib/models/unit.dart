import 'symbol.dart';

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
