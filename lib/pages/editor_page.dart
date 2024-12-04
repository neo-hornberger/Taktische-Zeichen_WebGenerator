import 'dart:convert';
import 'dart:typed_data';

import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../forms/building.dart';
import '../forms/command_post.dart';
import '../forms/communications_condition.dart';
import '../forms/device.dart';
import '../forms/hazard.dart';
import '../forms/person.dart';
import '../forms/post.dart';
import '../forms/symbol.dart';
import '../forms/unit.dart';
import '../forms/vehicle.dart';
import '../models/theme.dart';
import '../models/symbol.dart';
import '../services/jinja.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key, required this.jinja});

  final JinjaService jinja;

  @override
  State<EditorPage> createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  final _symbolTheme = SymbolTheme.DEFAULT;
  final _symbols = <String, Symbol>{
    'Einheit': Unit(),
    'Person': Person(),
    'Fahrzeug': Vehicle(),
    'Stelle': Post(),
    'Führungsstelle': CommandPost(),
    'Gebäude': Building(),
    'Gerät': Device(),
    'Gefahr': Hazard(),
    'Fernmeldewesen Bedingung': CommunicationsCondition(),
  };

  late Map<String, SymbolColorScheme> _symbolSchemes;
  late SymbolColorScheme _symbolScheme;
  late Symbol _symbol;

  Uint8List? _source;

  Symbol get symbol => _symbol.copy();
  Uint8List? get source => _source?.asUnmodifiableView();

  set symbolColor(SymbolColorScheme value) => setState(() => _symbolScheme = value);
  set symbol(Symbol value) => setState(() => _symbol = value);

  @override
  void initState() {
    super.initState();
    _symbolSchemes = _symbolTheme.schemes;
    _symbolScheme = _symbolTheme.default_;
    _symbol = _symbols.values.first;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: InitBuilder.arg(
              getter: widget.jinja.preloadTemplates,
              arg: context,
              builder: (context, future) => AsyncBuilder(
                future: future,
                waiting: (context) => const CircularProgressIndicator(),
                builder: (context, data) {
                  if (data == false) {
                    return _error(context, 'Failed to load templates');
                  }

                  return AsyncBuilder(
                    future: widget.jinja.buildSymbol(_symbol, _symbolScheme),
                    waiting: (context) => const CircularProgressIndicator(),
                    builder: (context, data) => SvgPicture.memory(
                      _source = utf8.encode(data!),
                      width: MediaQuery.of(context).size.shortestSide / 2.0,
                      height: MediaQuery.of(context).size.shortestSide / 2.0,
                    ),
                    error: (context, error, stackTrace) => _error(context, error.toString()),
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: double.infinity,
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<SymbolColorScheme>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Scheme',
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        symbolColor = value;
                      }
                    },
                    value: _symbolScheme,
                    items: _symbolSchemes.values
                        .map((scheme) => DropdownMenuItem(
                              value: scheme,
                              child: Row(
                                children: [
                                  SvgPicture.string('''
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                                      <circle cx="10" cy="10" r="10" fill="${scheme.stroke.toCSS()}"/>
                                      <circle cx="10" cy="10" r="8" fill="${scheme.secondary.toCSS()}"/>
                                      <circle cx="10" cy="10" r="6" fill="${scheme.primary.toCSS()}"/>
                                    </svg>
                                  '''),
                                  const SizedBox(width: 8),
                                  Text(scheme.name),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  DropdownButtonFormField<Symbol>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Symbol type',
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        symbol = value;
                      }
                    },
                    value: _symbol,
                    items: _symbols.entries
                        .map((entry) => DropdownMenuItem(
                              value: entry.value,
                              child: Text(entry.key),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _symbolForm(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  OnChanged _fieldsChanged([OnChanged? onChanged]) => (fields) => setState(() {
        _symbol.title = fields['title'];
        _symbol.name = fields['name'];
        _symbol.organisation = fields['organisation'];
        if (onChanged != null) {
          onChanged(fields);
        }
      });

  SymbolForm _symbolForm() => switch (_symbol) {
        (Unit u) => UnitForm(onChanged: _fieldsChanged((fields) {
            u.isLeading = fields['isLeading'];
            u.isLogistics = fields['isLogistics'];
            u.unitSize = fields['unitSize'];
            u.type = fields['type'];
            u.subtext = fields['subtext'];
          })),
        (Vehicle v) => VehicleForm(onChanged: _fieldsChanged((fields) {
            v.vehicleType = fields['vehicleType'];
            v.type = fields['type'];
          })),
        (CommandPost cp) => CommandPostForm(onChanged: _fieldsChanged((fields) {
            cp.unitSize = fields['unitSize'];
          })),
        (Building _) => BuildingForm(onChanged: _fieldsChanged()),
        (Hazard h) => HazardForm(onChanged: _fieldsChanged((fields) {
            h.color = fields['color'];
            h.isAcute = fields['isAcute'];
            h.isPresumed = fields['isPresumed'];
          })),
        (Device d) => DeviceForm(onChanged: _fieldsChanged((fields) {
            d.type = fields['type'];
            d.subtext = fields['subtext'];
          })),
        (Person p) => PersonForm(onChanged: _fieldsChanged((fields) {
            p.isLeader = fields['isLeader'];
            p.isSpecialist = fields['isSpecialist'];
            p.unitSize = fields['unitSize'];
            p.type = fields['type'];
            p.subtext = fields['subtext'];
          })),
        (Post p) => PostForm(onChanged: _fieldsChanged((fields) {
            p.isLeading = fields['isLeading'];
            p.isLogistics = fields['isLogistics'];
            p.isStationary = fields['isStationary'];
            p.subtext = fields['subtext'];
          })),
        (CommunicationsCondition cc) =>
          CommunicationsConditionForm(onChanged: _fieldsChanged((fields) {
            cc.mediumType = fields['mediumType'];
            cc.medium = fields['medium'];
          })),
      };

  Widget _error(BuildContext context, String message) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: MediaQuery.of(context).size.shortestSide / 2.0,
            color: Theme.of(context).colorScheme.error,
          ),
          Text(message),
        ],
      );
}
