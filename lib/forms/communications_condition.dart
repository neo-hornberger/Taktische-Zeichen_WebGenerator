import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../models/symbol.dart';
import 'symbol.dart';

class CommunicationsConditionForm extends SymbolForm {
  const CommunicationsConditionForm({super.key, super.onChanged});

  @override
  List<Widget> buildFields(BuildContext context) => [
      FormBuilderDropdown<CommunicationsMediumType>(
        name: 'mediumType',
        decoration: const InputDecoration(labelText: 'Medium type'),
        items: CommunicationsMediumType.values
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.repr),
                ))
            .toList(),
      ),
      FormBuilderTextField(
        name: 'medium',
        decoration: const InputDecoration(labelText: 'Medium'),
      ),
    ];
}
