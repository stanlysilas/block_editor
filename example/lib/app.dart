import 'package:flutter/material.dart';

import 'shell/shell_scaffold.dart';
import 'theme/app_theme.dart';

/// The root widget of the block_editor example application.
///
/// Owns the [ThemeMode] notifier and wires both light and dark [ThemeData]
/// instances into [MaterialApp]. The theme toggle is forwarded to
/// [ShellScaffold] which surfaces it in the editor top bar.
class App extends StatefulWidget {
  /// Creates an [App].
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'block_editor demo',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: ShellScaffold(themeMode: _themeMode, onToggleTheme: _toggleTheme),
    );
  }
}
