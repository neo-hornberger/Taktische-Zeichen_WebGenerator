import 'package:flutter/foundation.dart';

abstract class Symbol {
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
