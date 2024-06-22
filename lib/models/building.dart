import 'symbol.dart';

class Building extends Symbol {
  @override
  Symbol copy() => Building()..basecopyFrom(this);
}
