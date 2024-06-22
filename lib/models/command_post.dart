import 'symbol.dart';
import 'unit.dart';

class CommandPost extends Symbol {
  UnitSize? unitSize;

  @override
  Symbol copy() => CommandPost()
    ..basecopyFrom(this)
    ..unitSize = unitSize;
}
