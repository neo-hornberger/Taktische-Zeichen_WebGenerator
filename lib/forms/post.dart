import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'symbol.dart';

class PostForm extends SymbolForm {
  const PostForm({super.key, super.onChanged});

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
      FormBuilderCheckbox(
        name: 'isStationary',
        title: const Text('Is Stationary?'),
      ),
      FormBuilderTextField(
        name: 'subtext',
        decoration: const InputDecoration(labelText: 'Subtext'),
      ),
    ];
}
