import 'symbol.dart';

class Unit extends Symbol {
  bool? isLeading;
  bool? isLogistics;
  UnitSize? unitSize;
  String? type;
  String? subtext;
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
