import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/planet.dart';
import '../repositories/planet_repository.dart';
import '../services/swapi_exception.dart';
import '../theme/planet_biome.dart';
import 'planet_charts_tab.dart';
import '../widgets/rotating_planet.dart';

class PlanetDetailScreen extends StatefulWidget {
  final int planetId;

  const PlanetDetailScreen({super.key, required this.planetId});

  @override
  State<PlanetDetailScreen> createState() => _PlanetDetailScreenState();
}

class _PlanetDetailScreenState extends State<PlanetDetailScreen> {
  final PlanetRepository _repository = PlanetRepository();

  Planet? _planet;
  Map<String, double>? _averages;
  List<Planet>? _allPlanets;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final planet = await _repository.getPlanetById(widget.planetId);
      final planets = await _repository.getAllPlanets();
      final averages = await _repository.getAverages();
      if (!mounted) return;
      setState(() {
        _planet = planet;
        _allPlanets = planets;
        _averages = averages;
      });
    } on SwapiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }
    if (_planet == null || _averages == null || _allPlanets == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final planet = _planet!;
    final style = styleFor(planet);
    final brightness = Theme.of(context).brightness;

    // Cada planeta hereda el esquema de color de su propio bioma:
    // esto es lo que hace que la pantalla "se vea distinta" según
    // sea desértico, helado, oceánico, etc.
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: style.primary,
        brightness: brightness,
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Column(
            children: [
              _PlanetHeader(
                planet: planet,
                style: style,
                isFavorite: _isFavorite,
                onBack: () => Navigator.of(context).pop(),
                onToggleFavorite: () => setState(() => _isFavorite = !_isFavorite),
              ),
              const SizedBox(height: 10),
              ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.info_outline), text: 'información'),
                    Tab(icon: Icon(Icons.bar_chart), text: 'estadísticas'),
                    Tab(icon: Icon(Icons.auto_graph), text: 'gráficas'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _InfoTab(planet: planet, style: style),
                    _StatsTab(planet: planet, averages: _averages!, style: style),
                    PlanetChartsTab(planets: _allPlanets!, focus: planet),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado con degradado propio del bioma y el planeta como
/// pieza central: gira con el dedo/mouse y flota suavemente.
class _PlanetHeader extends StatelessWidget {
  final Planet planet;
  final PlanetBiomeStyle style;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;

  const _PlanetHeader({
    required this.planet,
    required this.style,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        gradient: LinearGradient(
          colors: [
            Color.lerp(style.primary, Colors.black, 0.35)!,
            Color.lerp(style.primary, Colors.black, 0.6)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(style.primary, Colors.black, 0.4)!.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 290,
          child: Stack(
            children: [
              const Positioned.fill(child: _Starfield()),
              Positioned(
                left: 4,
                top: 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: Colors.white,
                  ),
                  onPressed: onToggleFavorite,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotatingPlanet(planet: planet, size: 132),
                  const SizedBox(height: 16),
                  Text(
                    planet.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      style.label,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Arrastra para girarlo',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Puntitos decorativos fijos detrás del planeta, para reforzar la
/// sensación de "flotando en el espacio".
class _Starfield extends StatelessWidget {
  const _Starfield();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarfieldPainter());
  }
}

class _StarfieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(99);
    for (var i = 0; i < 28; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.6 + random.nextDouble() * 1.4;
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.15 + random.nextDouble() * 0.35);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => false;
}

class _InfoTab extends StatelessWidget {
  final Planet planet;
  final PlanetBiomeStyle style;

  const _InfoTab({required this.planet, required this.style});

  @override
  Widget build(BuildContext context) {
    final tags = [...planet.climateList, ...planet.terrainList];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map((t) => Chip(
                    label: Text(t),
                    avatar: Icon(style.icon, size: 16, color: style.primary),
                    backgroundColor: style.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    labelStyle: TextStyle(color: Color.lerp(style.primary, Colors.black, 0.35)),
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _StatCard(icon: Icons.groups, label: 'Población', value: planet.population, style: style),
            _StatCard(icon: Icons.straighten, label: 'Diámetro (km)', value: planet.diameter, style: style),
            _StatCard(icon: Icons.rotate_right, label: 'Rotación (h)', value: planet.rotationPeriod, style: style),
            _StatCard(icon: Icons.public, label: 'Traslación', value: planet.orbitalPeriod, style: style),
            _StatCard(icon: Icons.water_drop, label: 'Agua superficial', value: '${planet.surfaceWater}%', style: style),
            _StatCard(icon: Icons.language, label: 'Gravedad', value: planet.gravity, style: style),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final PlanetBiomeStyle style;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: style.primary.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: style.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: style.primary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: Color.lerp(style.primary, Colors.black, 0.2)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelSmall),
                  Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Radar chart planeta vs promedio, normalizado 0-100 para que
/// magnitudes muy distintas (población vs horas de rotación) sean
/// comparables visualmente.
class _StatsTab extends StatelessWidget {
  final Planet planet;
  final Map<String, double> averages;
  final PlanetBiomeStyle style;

  const _StatsTab({required this.planet, required this.averages, required this.style});

  static const _titles = ['Población', 'Traslación', 'Gravedad', 'Agua', 'Rotación', 'Recursos'];

  double _normalize(double? value, double average) {
    if (value == null || average <= 0) return 0;
    final ratio = value / average * 50;
    return ratio.clamp(0, 100).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final planetEntries = [
      _normalize(planet.populationValue, averages['population']!),
      _normalize(planet.orbitalValue, averages['orbital']!),
      50.0, // gravedad no es puramente numérica en SWAPI ("1 standard")
      _normalize(planet.surfaceWaterValue, averages['surfaceWater']!),
      _normalize(planet.rotationValue, averages['rotation']!),
      _normalize(planet.diameterValue, averages['diameter']!),
    ];
    const averageEntries = [50.0, 50.0, 50.0, 50.0, 50.0, 50.0];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 4,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                radarBorderData: BorderSide(color: style.primary.withValues(alpha: 0.3)),
                gridBorderData: BorderSide(color: style.primary.withValues(alpha: 0.2)),
                getTitle: (index, angle) => RadarChartTitle(text: _titles[index]),
                dataSets: [
                  RadarDataSet(
                    borderColor: style.primary,
                    fillColor: style.primary.withValues(alpha: 0.25),
                    entryRadius: 2,
                    dataEntries: planetEntries.map((v) => RadarEntry(value: v)).toList(),
                  ),
                  RadarDataSet(
                    borderColor: Colors.grey,
                    fillColor: Colors.grey.withValues(alpha: 0.12),
                    entryRadius: 2,
                    dataEntries: averageEntries.map((v) => RadarEntry(value: v)).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: style.primary, label: planet.name),
              const SizedBox(width: 16),
              const _Legend(color: Colors.grey, label: 'Promedio'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}