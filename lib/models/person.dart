import 'symbol.dart';
import 'unit.dart';

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
