import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../models/symbol.dart';
import 'symbol.dart';

class CommandPostForm extends SymbolForm {
  const CommandPostForm({super.key, super.onChanged});

  @override
  List<Widget> buildFields(BuildContext context) => [
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
    ];
}
