import '../models/planet.dart';
import '../services/swapi_service.dart';

/// SWAPI solo soporta ?search= por nombre, no por clima/terreno.
/// Para la Vista 1 (búsqueda + filtros por chips) esta clase trae
/// TODOS los planetas una sola vez, los cachea en memoria, y expone
/// filtrado/búsqueda local sobre esa lista (son ~60 planetas: es
/// razonable traerlos completos en vez de paginar en la UI).
class PlanetRepository {
  final SwapiService _service;
  List<Planet>? _cache;

  PlanetRepository({SwapiService? service}) : _service = service ?? SwapiService();

  /// Devuelve los 60 planetas, usando caché salvo que se fuerce refresh.
  Future<List<Planet>> getAllPlanets({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;

    final planets = <Planet>[];
    var page = await _service.fetchPlanetsPage(page: 1);
    planets.addAll(page.results);

    while (page.next != null) {
      page = await _service.fetchPage(page.next!);
      planets.addAll(page.results);
    }

    _cache = planets;
    return planets;
  }

  Future<Planet> getPlanetById(int id) => _service.fetchPlanetById(id);

  /// Todos los valores de clima presentes en el dataset, para poblar
  /// los chips de filtro ("árido", "frío", "seco", "rocoso", "fértil"...).
  Future<List<String>> getAvailableClimates() async {
    final planets = await getAllPlanets();
    return _uniqueSorted(planets.expand((p) => p.climateList));
  }

  /// Todos los valores de terreno presentes en el dataset.
  Future<List<String>> getAvailableTerrains() async {
    final planets = await getAllPlanets();
    return _uniqueSorted(planets.expand((p) => p.terrainList));
  }

  /// Filtra localmente por texto (nombre), clima y terreno.
  /// Los filtros de clima/terreno son OR dentro del mismo grupo y
  /// AND entre grupos, y son case-insensitive.
  Future<List<Planet>> filterPlanets({
    String query = '',
    Set<String> climates = const {},
    Set<String> terrains = const {},
  }) async {
    final planets = await getAllPlanets();
    final normalizedQuery = query.trim().toLowerCase();
    final normalizedClimates = climates.map((c) => c.toLowerCase()).toSet();
    final normalizedTerrains = terrains.map((t) => t.toLowerCase()).toSet();

    return planets.where((planet) {
      final matchesQuery = normalizedQuery.isEmpty ||
          planet.name.toLowerCase().contains(normalizedQuery);

      final matchesClimate = normalizedClimates.isEmpty ||
          planet.climateList
              .map((c) => c.toLowerCase())
              .any(normalizedClimates.contains);

      final matchesTerrain = normalizedTerrains.isEmpty ||
          planet.terrainList
              .map((t) => t.toLowerCase())
              .any(normalizedTerrains.contains);

      return matchesQuery && matchesClimate && matchesTerrain;
    }).toList();
  }

  /// Promedios del dataset, para el radar "Promedio" de la Vista 2.2.
  Future<Map<String, double>> getAverages() async {
    final planets = await getAllPlanets();
    double avg(Iterable<double?> values) {
      final valid = values.whereType<double>().toList();
      if (valid.isEmpty) return 0;
      return valid.reduce((a, b) => a + b) / valid.length;
    }

    return {
      'population': avg(planets.map((p) => p.populationValue)),
      'rotation': avg(planets.map((p) => p.rotationValue)),
      'orbital': avg(planets.map((p) => p.orbitalValue)),
      'diameter': avg(planets.map((p) => p.diameterValue)),
      'surfaceWater': avg(planets.map((p) => p.surfaceWaterValue)),
    };
  }

  List<String> _uniqueSorted(Iterable<String> values) {
    final set = <String>{};
    for (final v in values) {
      set.add(v);
    }
    final list = set.toList()..sort();
    return list;
  }

  void dispose() => _service.dispose();
}
