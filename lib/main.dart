import 'package:flutter/material.dart';

import 'screens/planets_list_screen.dart';

void main() {
  runApp(const SwapiPlanetsApp());
}

class SwapiPlanetsApp extends StatelessWidget {
  const SwapiPlanetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planetas SWAPI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const PlanetsListScreen(),
    );
  }
}
