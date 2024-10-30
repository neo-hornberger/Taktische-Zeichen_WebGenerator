import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.findAncestorStateOfType<ApplicationState>()!.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('General'),
            tiles: [
              SettingsTile(
                title: const Text('Theme Mode'),
                leading: const Icon(Icons.color_lens),
                value: Text(_themeModeToString(settings.themeMode.value)),
                onPressed: (context) => _listDialog(
                  context,
                  title: 'Theme Mode',
                  items: ThemeMode.values,
                  value: settings.themeMode.value,
                  onChanged: (value) => setState(() => settings.themeMode.value = value ?? ThemeMode.system),
                  itemToString: _themeModeToString,
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Jinja Server'),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Enabled'),
                leading: const Icon(Icons.dns),
                initialValue: settings.jinjaServerEnabled.value,
                onToggle: (value) => setState(() => settings.jinjaServerEnabled.value = value),
                enabled: false,
              ),
              SettingsTile(
                title: const Text('URL'),
                leading: const Icon(Icons.link),
                value: Text(settings.jinjaServerUrl.value),
                onPressed: (context) => _textInputDialog(
                  context,
                  title: 'URL',
                  value: settings.jinjaServerUrl.value,
                  onSave: (value) => setState(() => settings.jinjaServerUrl.value = value),
                ),
                enabled: settings.jinjaServerEnabled.value,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _textInputDialog(
    BuildContext context, {
    required String title,
    required String value,
    void Function(String)? onChanged,
    void Function(String)? onSave,
  }) {
    final controller = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          onChanged: onChanged,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSave?.call(controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _listDialog<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required T value,
    void Function(T?)? onChanged,
    String Function(T)? itemToString,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            return RadioListTile(
              title: Text(itemToString?.call(item) ?? item.toString()),
              value: item,
              groupValue: value,
              onChanged: (value) {
                Navigator.pop(context);
                onChanged?.call(value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Auto';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
