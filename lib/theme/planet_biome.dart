import 'package:flutter/material.dart';

import '../models/planet.dart';

/// Categoría visual de un planeta, derivada de su clima/terreno.
/// No es un dato de SWAPI: es una clasificación propia para poder
/// darle una identidad visual distinta a cada tipo de planeta.
enum PlanetBiome { desert, ice, ocean, swamp, forest, volcanic, rocky, temperate, gasGiant, unknown }

class PlanetBiomeStyle {
  final String label;
  final Color primary;
  final Color secondary;
  final IconData icon;

  const PlanetBiomeStyle({
    required this.label,
    required this.primary,
    required this.secondary,
    required this.icon,
  });

  List<Color> get gradient => [primary, secondary];
}

const Map<PlanetBiome, PlanetBiomeStyle> planetBiomeStyles = {
  PlanetBiome.desert: PlanetBiomeStyle(
    label: 'Desértico',
    primary: Color(0xFFC97C3D),
    secondary: Color(0xFFEFC27A),
    icon: Icons.wb_sunny_outlined,
  ),
  PlanetBiome.ice: PlanetBiomeStyle(
    label: 'Helado',
    primary: Color(0xFF4E9CB5),
    secondary: Color(0xFFBFE6EE),
    icon: Icons.ac_unit,
  ),
  PlanetBiome.ocean: PlanetBiomeStyle(
    label: 'Oceánico',
    primary: Color(0xFF1F6F8B),
    secondary: Color(0xFF69C7BE),
    icon: Icons.water_outlined,
  ),
  PlanetBiome.swamp: PlanetBiomeStyle(
    label: 'Pantanoso',
    primary: Color(0xFF5C6B3B),
    secondary: Color(0xFF8C9E5A),
    icon: Icons.grass,
  ),
  PlanetBiome.forest: PlanetBiomeStyle(
    label: 'Boscoso',
    primary: Color(0xFF3F7A45),
    secondary: Color(0xFF9BC97A),
    icon: Icons.park_outlined,
  ),
  PlanetBiome.volcanic: PlanetBiomeStyle(
    label: 'Volcánico',
    primary: Color(0xFFB8412D),
    secondary: Color(0xFFE8823F),
    icon: Icons.local_fire_department_outlined,
  ),
  PlanetBiome.rocky: PlanetBiomeStyle(
    label: 'Rocoso',
    primary: Color(0xFF8C7A66),
    secondary: Color(0xFFD3C1A5),
    icon: Icons.terrain,
  ),
  PlanetBiome.temperate: PlanetBiomeStyle(
    label: 'Templado',
    primary: Color(0xFF7C9A4C),
    secondary: Color(0xFFE0D06E),
    icon: Icons.eco_outlined,
  ),
  PlanetBiome.gasGiant: PlanetBiomeStyle(
    label: 'Gigante gaseoso',
    primary: Color(0xFFB5793D),
    secondary: Color(0xFFE9CFA0),
    icon: Icons.blur_circular,
  ),
  PlanetBiome.unknown: PlanetBiomeStyle(
    label: 'Desconocido',
    primary: Color(0xFF5C6BC0),
    secondary: Color(0xFFB3BEEA),
    icon: Icons.public,
  ),
};

/// Clasifica un planeta según palabras clave de su clima/terreno
/// (ambos campos vienen en inglés desde SWAPI). El orden de los
/// checks importa: un planeta puede tener varias palabras y la
/// primera coincidencia gana.
PlanetBiome biomeFor(Planet planet) {
  final text = '${planet.climate} ${planet.terrain}'.toLowerCase();

  bool has(List<String> keywords) => keywords.any(text.contains);

  if (has(['gas giant'])) return PlanetBiome.gasGiant;
  if (has(['volcan', 'lava', 'superheated'])) return PlanetBiome.volcanic;
  if (has(['froz', 'ice', 'frigid', 'arctic', 'tundra', 'snow'])) return PlanetBiome.ice;
  if (has(['swamp', 'bog', 'murky', 'toxic'])) return PlanetBiome.swamp;
  if (has(['ocean', 'water', 'humid', 'moist', 'lakes', 'wet'])) return PlanetBiome.ocean;
  if (has(['forest', 'jungle', 'rainforest', 'grasslands', 'grassy'])) return PlanetBiome.forest;
  if (has(['arid', 'desert', 'dry', 'barren'])) return PlanetBiome.desert;
  if (has(['rock', 'mountain', 'canyon', 'cave'])) return PlanetBiome.rocky;
  if (has(['temperate', 'tropical', 'mild'])) return PlanetBiome.temperate;
  return PlanetBiome.unknown;
}

/// SWAPI trae bastantes planetas con clima/terreno "unknown". En vez
/// de mostrarlos siempre con la misma esfera lisa, se les asigna un
/// terreno de apariencia al azar (pero fijo por planeta, usando su
/// id como semilla) solo para la ilustración — la etiqueta y el color
/// del resto de la pantalla siguen diciendo "Desconocido".
const _fallbackVisualBiomes = [
  PlanetBiome.desert,
  PlanetBiome.rocky,
  PlanetBiome.ocean,
  PlanetBiome.forest,
  PlanetBiome.ice,
  PlanetBiome.volcanic,
  PlanetBiome.gasGiant,
  PlanetBiome.temperate,
];

PlanetBiome visualBiomeFor(Planet planet) {
  final biome = biomeFor(planet);
  if (biome != PlanetBiome.unknown) return biome;
  return _fallbackVisualBiomes[planet.id % _fallbackVisualBiomes.length];
}

/// Un planeta oceánico con montañas/bosques/desierto mezclados en su
/// terreno se dibuja con continentes visibles sobre el agua.
bool hasLandFeatures(Planet planet) {
  final text = planet.terrain.toLowerCase();
  return ['mountain', 'forest', 'jungle', 'desert', 'grasslands', 'rock', 'hill', 'plain', 'canyon']
      .any(text.contains);
}

/// Un planeta de tierra (bosque, templado, pantano) con clima húmedo
/// o terreno de lagos/océano se dibuja con manchas de agua visibles.
bool hasWaterFeatures(Planet planet) {
  final text = '${planet.climate} ${planet.terrain}'.toLowerCase();
  return ['ocean', 'lake', 'sea', 'swamp', 'humid', 'moist'].any(text.contains);
}

PlanetBiomeStyle styleFor(Planet planet) => planetBiomeStyles[biomeFor(planet)]!;