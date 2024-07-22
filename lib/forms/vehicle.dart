import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../models/symbol.dart';
import 'symbol.dart';

class VehicleForm extends SymbolForm {
  const VehicleForm({super.key, super.onChanged});

  @override
  List<Widget> buildFields(BuildContext context) => [
      FormBuilderDropdown<VehicleType>(
        name: 'vehicleType',
        decoration: const InputDecoration(labelText: 'Vehicle type'),
        items: VehicleType.values
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.repr),
                ))
            .toList(),
      ),
      FormBuilderTextField(
        name: 'type',
        decoration: const InputDecoration(labelText: 'Type'),
      ),
    ];
}
