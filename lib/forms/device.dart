import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'symbol.dart';

class DeviceForm extends SymbolForm {
  const DeviceForm({super.key, super.onChanged});

  @override
  List<Widget> buildFields(BuildContext context) => [
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
