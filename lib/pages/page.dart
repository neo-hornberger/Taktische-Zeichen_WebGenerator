import 'dart:convert';
import 'dart:typed_data';

import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../forms/building.dart';
import '../forms/command_post.dart';
import '../forms/person.dart';
import '../forms/post.dart';
import '../forms/symbol.dart';
import '../forms/unit.dart';
import '../forms/vehicle.dart';
import '../models/building.dart';
import '../models/command_post.dart';
import '../models/person.dart';
import '../models/post.dart';
import '../models/theme.dart';
import '../models/unit.dart';
import '../models/symbol.dart';
import '../models/vehicle.dart';
import '../services/jinja.dart';
import '../services/jinja/server.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final JinjaService _jinja = JinjaServer();

  final _symbolColors = <String, SymbolColors>{
    'Default': SymbolColors(),
    'Bundeswehr': SymbolColors(
      primary: const Color(0xff996633),
      secondary: const Color(0xffffffff),
      stroke: const Color(0xff000000),
    ),
    'Feuerwehr': SymbolColors(
      primary: const Color(0xffff0000),
      secondary: const Color(0xffffffff),
      stroke: const Color(0xff000000),
    ),
    'Führung': SymbolColors(
      primary: const Color(0xffffff00),
      secondary: const Color(0xff000000),
      stroke: const Color(0xff000000),
    ),
    'Katastrophenschutz': SymbolColors(
      primary: const Color(0xffdf6711),
      secondary: const Color(0xffffffff),
      stroke: const Color(0xff000000),
    ),
    'Polizei': SymbolColors(
      primary: const Color(0xff13a538),
      secondary: const Color(0xffffffff),
      stroke: const Color(0xff000000),
    ),
    'THW': SymbolColors(
      primary: const Color(0xff003399),
      secondary: const Color(0xffffffff),
      stroke: const Color(0xff000000),
    ),
  };
  final _symbols = <String, Symbol>{
    'Einheit': Unit(),
    'Person': Person(),
    'Fahrzeug': Vehicle(),
    'Stelle': Post(),
    'Führungsstelle': CommandPost(),
    'Gebäude': Building(),
  };

  late SymbolColors _symbolColor;
  late Symbol _symbol;

  Uint8List? _source;

  @override
  void initState() {
    super.initState();
    _symbolColor = _symbolColors.values.first;
    _symbol = _symbols.values.first;
  }

  @override
  Widget build(BuildContext context) {
    final double symbolSize = MediaQuery.of(context).size.shortestSide / 2.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: InitBuilder.arg(
                getter: _jinja.preloadTemplates,
                arg: context,
                builder: (context, future) {
                  return AsyncBuilder(
                    future: future,
                    waiting: (context) => const CircularProgressIndicator(),
                    builder: (context, data) {
                      if (data == false) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              size: symbolSize,
                              color: Theme.of(context).colorScheme.errorContainer,
                            ),
                            const Text('Failed to load templates'),
                          ],
                        );
                      }

                      return AsyncBuilder(
                        future: _jinja.buildSymbol(_symbol, _symbolColor),
                        waiting: (context) => const CircularProgressIndicator(),
                        builder: (context, data) => SvgPicture.memory(
                          _source = utf8.encode(data!),
                          width: symbolSize,
                          height: symbolSize,
                        ),
                        error: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error,
                                size: symbolSize,
                                color: Theme.of(context).colorScheme.errorContainer,
                              ),
                              Text(error.toString()),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
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
                    DropdownButtonFormField<SymbolColors>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Theme',
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _symbolColor = value);
                        }
                      },
                      value: _symbolColor,
                      items: _symbolColors.entries
                          .map((entry) => DropdownMenuItem(
                                value: entry.value,
                                child: Row(
                                  children: [
                                    SvgPicture.string('''
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                                      <circle cx="10" cy="10" r="10" fill="${entry.value.stroke.toCSS()}"/>
                                      <circle cx="10" cy="10" r="8" fill="${entry.value.secondary.toCSS()}"/>
                                      <circle cx="10" cy="10" r="6" fill="${entry.value.primary.toCSS()}"/>
                                    </svg>
                                  '''),
                                    const SizedBox(width: 8),
                                    Text(entry.key),
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
                          setState(() => _symbol = value);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final theme = Theme.of(context);

          SnackBar snackBar;
          try {
            final file = await FileSaver.instance.saveFile(
              name: 'symbol.svg',
              bytes: _source!,
              mimeType: MimeType.custom,
              customMimeType: 'image/svg+xml',
            );
            snackBar = SnackBar(
              backgroundColor: theme.colorScheme.primaryContainer,
              content: Text(
                'Saved to $file',
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            );
          } catch (e) {
            snackBar = SnackBar(
              backgroundColor: theme.colorScheme.errorContainer,
              content: Text(
                e.toString(),
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        tooltip: 'Save',
        child: const Icon(Icons.save),
      ),
    );
  }

  OnChanged _fieldsChanged([OnChanged? onChanged]) => (fields) {
        print(fields);
        setState(() {
          _symbol.title = fields['title'];
          _symbol.name = fields['name'];
          _symbol.organisation = fields['organisation'];
          if (onChanged != null) {
            onChanged(fields);
          }
        });
      };

  SymbolForm _symbolForm() {
    if (_symbol case Unit u) {
      return UnitForm(onChanged: _fieldsChanged((fields) {
        u.isLeading = fields['isLeading'];
        u.isLogistics = fields['isLogistics'];
        u.unitSize = fields['unitSize'];
        u.type = fields['type'];
        u.subtext = fields['subtext'];
      }));
    }
    if (_symbol case Person p) {
      return PersonForm(onChanged: _fieldsChanged((fields) {
        p.isLeader = fields['isLeader'];
        p.isSpecialist = fields['isSpecialist'];
        p.unitSize = fields['unitSize'];
        p.type = fields['type'];
        p.subtext = fields['subtext'];
      }));
    }
    if (_symbol case Vehicle v) {
      return VehicleForm(onChanged: _fieldsChanged((fields) {
        v.vehicleType = fields['vehicleType'];
        v.type = fields['type'];
      }));
    }
    if (_symbol case Post p) {
      return PostForm(onChanged: _fieldsChanged((fields) {
        p.isLeading = fields['isLeading'];
        p.isLogistics = fields['isLogistics'];
        p.isStationary = fields['isStationary'];
        p.subtext = fields['subtext'];
      }));
    }
    if (_symbol case CommandPost cp) {
      return CommandPostForm(onChanged: _fieldsChanged((fields) {
        cp.unitSize = fields['unitSize'];
      }));
    }
    if (_symbol case Building b) {
      return BuildingForm(onChanged: _fieldsChanged());
    }
    throw Exception('Unknown symbol type');
  }
}
