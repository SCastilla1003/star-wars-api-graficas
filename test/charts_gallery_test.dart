import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:starwars/charts/chart_catalog.dart';
import 'package:starwars/charts/charts_data.dart';
import 'package:starwars/charts/community_gallery.dart';
import 'package:starwars/charts/drafter_gallery.dart';
import 'package:starwars/charts/fl_gallery.dart';
import 'package:starwars/charts/graphic_gallery.dart';
import 'package:starwars/models/planet.dart';
import 'package:starwars/screens/planet_charts_tab.dart';

Planet _planet(
  int id,
  String name, {
  String rotation = '23',
  String orbital = '304',
  String diameter = '10000',
  String climate = 'temperate',
  String terrain = 'grassland',
  String water = '40',
  String population = '200000',
}) {
  return Planet(
    name: name,
    rotationPeriod: rotation,
    orbitalPeriod: orbital,
    diameter: diameter,
    climate: climate,
    gravity: '1 standard',
    terrain: terrain,
    surfaceWater: water,
    population: population,
    residents: const [],
    films: const [],
    url: 'https://swapi.dev/api/planets/$id/',
  );
}

List<Planet> _fixtures() => [
      _planet(1, 'Tatooine',
          rotation: '23', orbital: '304', diameter: '10465',
          climate: 'arid', terrain: 'desert', water: '1', population: '200000'),
      _planet(2, 'Alderaan',
          rotation: '24', orbital: '364', diameter: '12500',
          climate: 'temperate', terrain: 'grassland, mountains',
          water: '40', population: '2000000000'),
      _planet(3, 'Hoth',
          rotation: '23', orbital: '549', diameter: '7200',
          climate: 'frozen', terrain: 'tundra, ice cave',
          water: '100', population: 'unknown'),
      _planet(4, 'Dagobah',
          rotation: '23', orbital: '341', diameter: '8900',
          climate: 'moist', terrain: 'swamp, jungles',
          water: '8', population: 'unknown'),
      _planet(5, 'Endor',
          rotation: '18', orbital: '402', diameter: '4900',
          climate: 'temperate', terrain: 'forest, mountains',
          water: '8', population: '30000000'),
      _planet(6, 'Naboo',
          rotation: '18', orbital: '312', diameter: 'unknown',
          climate: 'temperate', terrain: 'jungles, cities, lakes',
          water: '12', population: '4500000000'),
      _planet(7, 'Coruscant',
          rotation: '24', orbital: '368', diameter: '12240',
          climate: 'temperate', terrain: 'cityscape, mountains',
          water: 'unknown', population: '1000000000000'),
      _planet(8, 'Kamino',
          rotation: '19', orbital: '463', diameter: '19720',
          climate: 'temperate', terrain: 'ocean',
          water: '100', population: '1000000000'),
    ];

void main() {
  final data = ChartsData.build(_fixtures());

  test('el catálogo tiene 63 ids únicos (31 básicas + 32 avanzadas)', () {
    expect(kChartCatalog, hasLength(kChartsPerLibrary));
    expect(kChartCatalog.map((c) => c.id).toSet(), hasLength(kChartsPerLibrary));
    expect(chartsForLevel(ChartLevel.basica), hasLength(31));
    expect(chartsForLevel(ChartLevel.avanzada), hasLength(32));
    expect(kTotalCharts, 252);
    for (final c in kChartCatalog) {
      expect(c.name, isNotEmpty, reason: 'nombre vacío en ${c.id}');
      expect(c.description, isNotEmpty, reason: 'descripción vacía en ${c.id}');
    }
  });

  test('ChartsData.build cubre los 63 ids con datos del foco', () {
    expect(data.planets, hasLength(8));
    expect(data.totalPlanets, 8);
    expect(data.focus.name, 'Tatooine');
  });

  final builders = <String, Widget Function(String, ChartsData)>{
    'fl_chart': buildFlChart,
    'graphic': buildGraphicChart,
    'community': buildCommunityChart,
    'drafter': buildDrafterChart,
  };

  for (final entry in builders.entries) {
    for (final spec in kChartCatalog) {
      testWidgets('${entry.key}/${spec.id}', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 640,
                height: 420,
                child: entry.value(spec.id, data),
              ),
            ),
          ),
        ));
        // Descarta el árbol para forzar dentro del test cualquier error
        // de layout pendiente de la gráfica.
        await tester.pumpWidget(const SizedBox());
        await tester.pump();

        final failures = <Object>[];
        Object? e;
        while ((e = tester.takeException()) != null) {
          failures.add(e!);
        }
        expect(failures, isEmpty,
            reason: '${entry.key}/${spec.id} falló: $failures');
      });
    }
  }

  testWidgets('la pestaña navega entre gráficas sin desbordar',
      (tester) async {
    final planets = _fixtures();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          height: 480,
          child: PlanetChartsTab(planets: planets, focus: planets.first),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Estado inicial: primera gráfica del catálogo completo.
    expect(find.text('1 de 63'), findsOneWidget);
    expect(find.text('Líneas simples'), findsWidgets);

    // Cambia de librería y avanza a la siguiente gráfica.
    await tester.tap(find.text('graphic'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('2 de 63'), findsOneWidget);
    expect(find.text('Líneas múltiples'), findsWidgets);

    // El filtro por nivel recorta la navegación.
    await tester.tap(find.textContaining('Avanzadas ('));
    await tester.pumpAndSettle();
    expect(find.text('1 de 32'), findsOneWidget);

    Object? e;
    final failures = <Object>[];
    while ((e = tester.takeException()) != null) {
      failures.add(e!);
    }
    expect(failures, isEmpty, reason: '$failures');
  });
}
