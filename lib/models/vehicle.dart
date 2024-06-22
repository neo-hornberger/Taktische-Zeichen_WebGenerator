import 'symbol.dart';

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
