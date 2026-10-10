/// Modelo de un planeta según la respuesta de SWAPI
/// (https://swapi.dev/api/planets/{id}/).
class Planet {
  final String name;
  final String rotationPeriod;
  final String orbitalPeriod;
  final String diameter;
  final String climate;
  final String gravity;
  final String terrain;
  final String surfaceWater;
  final String population;
  final List<String> residents;
  final List<String> films;
  final String url;

  const Planet({
    required this.name,
    required this.rotationPeriod,
    required this.orbitalPeriod,
    required this.diameter,
    required this.climate,
    required this.gravity,
    required this.terrain,
    required this.surfaceWater,
    required this.population,
    required this.residents,
    required this.films,
    required this.url,
  });

  /// SWAPI no expone un id numérico directo: se extrae de la url
  /// (ej. "https://swapi.dev/api/planets/1/" -> 1).
  int get id {
    final segments =
        url.split('/').where((s) => s.trim().isNotEmpty).toList();
    return int.tryParse(segments.last) ?? 0;
  }

  /// climate viene como "arid, temperate" -> lista de chips.
  List<String> get climateList => _splitField(climate);

  /// terrain viene como "desert, mountains" -> lista de chips.
  List<String> get terrainList => _splitField(terrain);

  List<String> _splitField(String raw) {
    if (raw.trim().isEmpty || raw.toLowerCase() == 'unknown') return [];
    return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  /// Helpers numéricos para la vista de estadísticas (radar chart).
  /// Devuelven null cuando el dato es "unknown" o no es numérico.
  double? get populationValue => _toDouble(population);
  double? get rotationValue => _toDouble(rotationPeriod);
  double? get orbitalValue => _toDouble(orbitalPeriod);
  double? get diameterValue => _toDouble(diameter);
  double? get surfaceWaterValue => _toDouble(surfaceWater);

  double? _toDouble(String raw) {
    if (raw.trim().isEmpty || raw.toLowerCase() == 'unknown') return null;
    return double.tryParse(raw);
  }

  factory Planet.fromJson(Map<String, dynamic> json) {
    return Planet(
      name: json['name'] as String? ?? 'unknown',
      rotationPeriod: json['rotation_period'] as String? ?? 'unknown',
      orbitalPeriod: json['orbital_period'] as String? ?? 'unknown',
      diameter: json['diameter'] as String? ?? 'unknown',
      climate: json['climate'] as String? ?? 'unknown',
      gravity: json['gravity'] as String? ?? 'unknown',
      terrain: json['terrain'] as String? ?? 'unknown',
      surfaceWater: json['surface_water'] as String? ?? 'unknown',
      population: json['population'] as String? ?? 'unknown',
      residents: List<String>.from(json['residents'] as List? ?? const []),
      films: List<String>.from(json['films'] as List? ?? const []),
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rotation_period': rotationPeriod,
      'orbital_period': orbitalPeriod,
      'diameter': diameter,
      'climate': climate,
      'gravity': gravity,
      'terrain': terrain,
      'surface_water': surfaceWater,
      'population': population,
      'residents': residents,
      'films': films,
      'url': url,
    };
  }
}
