import 'package:flutter/material.dart';

import '../core/design/design.dart';
import 'router.dart';

/// Root of the Talyer app. Wires the design-system light/dark themes and
/// follows the OS theme by default.
class TalyerApp extends StatelessWidget {
  const TalyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Talyer',
      debugShowCheckedModeBanner: false,
      theme: TalyerTheme.light,
      darkTheme: TalyerTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
