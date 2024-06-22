import 'symbol.dart';

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
