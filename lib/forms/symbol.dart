import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

abstract class SymbolForm extends StatefulWidget {
  const SymbolForm({super.key, this.onChanged});

  final OnChanged? onChanged;

  List<Widget> buildFields(BuildContext context);

  @override
  State<SymbolForm> createState() => SymbolFormState();
}

class SymbolFormState extends State<SymbolForm> {
  final _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _fbKey,
      onChanged: () {
        if (widget.onChanged != null) {
          widget.onChanged!(_fbKey.currentState!.instantValue);
        }
      },
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'title',
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          FormBuilderTextField(
            name: 'organisation',
            decoration: const InputDecoration(labelText: 'Organisation'),
          ),
          ...widget.buildFields(context),
        ],
      ),
    );
  }
}

typedef OnChanged = void Function(Map<String, dynamic>);
