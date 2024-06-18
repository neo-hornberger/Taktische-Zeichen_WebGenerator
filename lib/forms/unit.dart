import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../models/unit.dart';
import 'symbol.dart';

class UnitForm extends SymbolForm {
  const UnitForm({super.key, super.onChanged});

  @override
  List<Widget> buildFields(BuildContext context) => [
      FormBuilderCheckbox(
        name: 'isLeading',
        title: const Text('Is Leading?'),
      ),
      FormBuilderCheckbox(
        name: 'isLogistics',
        title: const Text('Is Logistics?'),
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
