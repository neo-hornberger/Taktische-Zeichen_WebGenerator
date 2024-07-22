import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';

import 'symbol.dart';

class HazardForm extends SymbolForm {
  const HazardForm({super.key, super.onChanged});

  @override
  List<Widget> buildFields(BuildContext context) => [
        FormBuilderColorPickerField(
          name: 'color',
          decoration: const InputDecoration(labelText: 'Color'),
        ),
        FormBuilderCheckbox(
          name: 'isAcute',
          title: const Text('Is Acute?'),
        ),
        FormBuilderCheckbox(
          name: 'isPresumed',
          title: const Text('Is Presumed?'),
        ),
      ];
}
