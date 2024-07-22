import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../models/symbol.dart';
import 'symbol.dart';

class PersonForm extends SymbolForm {
  const PersonForm({super.key, super.onChanged});

  @override
  List<Widget> buildFields(BuildContext context) => [
      FormBuilderCheckbox(
        name: 'isLeader',
        title: const Text('Is Leader?'),
      ),
      FormBuilderCheckbox(
        name: 'isSpecialist',
        title: const Text('Is Specialist?'),
      ),
      FormBuilderDropdown<UnitSize>(
        name: 'unitSize',
        decoration: const InputDecoration(labelText: 'Unit size'),
        items: UnitSize.values
            .map((size) => DropdownMenuItem(
                  value: size,
                  child: Text(size.repr),
                ))
            .toList(),
      ),
      FormBuilderTextField(
        name: 'type',
        decoration: const InputDecoration(labelText: 'Type'),
      ),
      FormBuilderTextField(
        name: 'subtext',
        decoration: const InputDecoration(labelText: 'Subtext'),
      ),
    ];
}
