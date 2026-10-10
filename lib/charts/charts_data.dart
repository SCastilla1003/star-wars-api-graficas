import 'dart:math';

import '../models/planet.dart';
import '../theme/planet_biome.dart';

/// Logaritmo base 10 (dart:math solo expone log natural).
double log10(num value) => log(value) / ln10;

/// Par etiqueta-valor usado por la mayoría de gráficas categóricas.
class NameValue {
  final String label;
  final double value;

  const NameValue(this.label, this.value);
}

/// Punto de dispersión/burbuja con etiqueta.
class ScatterPt {
  final String label;
  final double x;
  final double y;
  final double size;

  const ScatterPt({
    required this.label,
    required this.x,
    required this.y,
    this.size = 0,
  });
}

/// Estadísticos de caja (box plot / barras de error / dumbbell).
class BoxStats {
  final String label;
  final double min;
  final double q1;
  final double median;
  final double q3;
  final double max;
  final double mean;
  final double std;

  const BoxStats({
    required this.label,
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
    required this.mean,
    required this.std,
  });
}

/// Vela OHLC: open/close mapean a q1/q3 del diámetro por bioma,
/// high/low a max/min (todo derivado de datos reales de SWAPI).
class OhlcBar {
  final String label;
  final double open;
  final double high;
  final double low;
  final double close;

  const OhlcBar({
    required this.label,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

/// Banda inferior/superior con valor central (rango, ± desviación).
class BandStat {
  final String label;
  final double center;
  final double lower;
  final double upper;

  const BandStat({
    required this.label,
    required this.center,
    required this.lower,
    required this.upper,
  });
}

/// Flujo Sankey entre dos categorías (clima → terreno).
class FlowLink {
  final String from;
  final String to;
  final double value;

  const FlowLink({required this.from, required this.to, required this.value});
}

/// Nodo jerárquico (treemap / sunburst).
class TreeNodeData {
  final String label;
  final double value;
  final List<TreeNodeData> children;

  const TreeNodeData({
    required this.label,
    required this.value,
    this.children = const [],
  });
}

/// Grupo de puntos para strip plot.
class StripGroup {
  final String label;
  final List<double> values;

  const StripGroup({required this.label, required this.values});
}

/// Todos los datasets que alimentan las 252 gráficas, derivados
/// EXCLUSIVAMENTE de los planetas reales de SWAPI (60 en total).
/// Los campos "unknown" se filtran en cada dataset.
class ChartsData {
  final List<Planet> planets;
  final Planet focus;

  // Secuencia fija: 10 planetas con diámetro válido, de mayor a menor.
  final List<String> seqLabels;
  final List<double> seqDiameter;
  final List<double> seqPopulation;
  final List<double> seqPopulationLog;
  final List<double> seqWater;
  final List<double> seqRotation;
  final List<double> seqOrbital;
  final double diameterAvg;

  // Rankings categóricos.
  final List<NameValue> topDiameter;
  final List<NameValue> topPopulation;
  final List<NameValue> climateCounts;
  final List<NameValue> terrainCounts;
  final List<NameValue> biomeCounts;
  final List<NameValue> terrainWaterAvg;

  // Agrupaciones por bioma.
  final List<String> biomeLabels;
  final List<double> biomeCountValues;
  final List<double> biomeWaterAvg;
  final List<BoxStats> biomeDiameterBox;
  final List<OhlcBar> biomeOhlc;
  final List<BandStat> biomeDiameterRange;
  final List<BandStat> biomeWaterBand;

  // Matriz clima × terreno y apilados por clima/bioma.
  final List<String> matrixRows;
  final List<String> matrixCols;
  final List<List<double>> matrixValues;
  final List<String> stackClimates;
  final List<String> stackBiomes;
  final List<List<double>> stackValues;

  // Flujos y jerarquías.
  final List<FlowLink> flows;
  final List<TreeNodeData> hierarchyTerrain;
  final List<TreeNodeData> hierarchyClimate;

  // Dispersión y regresión (población en log10 para abarcar órdenes).
  final List<ScatterPt> scatterDiameterPopulation;
  final List<ScatterPt> scatterRotationOrbital;
  final List<ScatterPt> scatterBubble;
  final double regSlope;
  final double regIntercept;

  // Correlaciones de Pearson entre campos numéricos.
  final List<String> corrLabels;
  final List<List<double>> corrMatrix;

  // Histograma: diámetros crudos para agrupar en bins.
  final List<double> diameterAll;

  // Serie de agua rica/pobre por bioma (áreas apiladas).
  final List<double> waterRich;
  final List<double> waterPoor;

  // Divergentes: diámetro menos promedio (±).
  final List<NameValue> divergingDiameter;

  // Promedio acumulado del agua (combo columna + línea).
  final List<double> waterCumAvg;

  // Cuadrícula tipo calendario: cada planeta una celda, intensidad 0-100.
  final List<NameValue> calendarCells;

  // Gantt: tarea = planeta, duración = periodo orbital (días).
  final List<NameValue> ganttTasks;

  // Gauge / bullet del planeta en foco.
  final double gaugeValue;
  final String gaugeMetric;
  final double bulletValue;
  final double bulletTarget;
  final double bulletMax;
  final List<double> bulletRanges;

  // Radar.
  final List<String> radarTitles;
  final List<double> radarFocus;
  final List<double> radarAvg;
  final List<String> multiRadarLabels;
  final List<List<double>> multiRadar;

  // Strip plot por bioma.
  final List<StripGroup> stripGroups;

  // Pirámide: izquierda = conteo, derecha = agua % (por terreno top 6).
  final List<NameValue> pyramidLeft;
  final List<NameValue> pyramidRight;

  // Anotaciones sobre la secuencia de diámetros.
  final int annotatedMaxIndex;
  final int annotatedMinIndex;

  // Dona con KPI.
  final int totalPlanets;

  const ChartsData({
    required this.planets,
    required this.focus,
    required this.seqLabels,
    required this.seqDiameter,
    required this.seqPopulation,
    required this.seqPopulationLog,
    required this.seqWater,
    required this.seqRotation,
    required this.seqOrbital,
    required this.diameterAvg,
    required this.topDiameter,
    required this.topPopulation,
    required this.climateCounts,
    required this.terrainCounts,
    required this.biomeCounts,
    required this.terrainWaterAvg,
    required this.biomeLabels,
    required this.biomeCountValues,
    required this.biomeWaterAvg,
    required this.biomeDiameterBox,
    required this.biomeOhlc,
    required this.biomeDiameterRange,
    required this.biomeWaterBand,
    required this.matrixRows,
    required this.matrixCols,
    required this.matrixValues,
    required this.stackClimates,
    required this.stackBiomes,
    required this.stackValues,
    required this.flows,
    required this.hierarchyTerrain,
    required this.hierarchyClimate,
    required this.scatterDiameterPopulation,
    required this.scatterRotationOrbital,
    required this.scatterBubble,
    required this.regSlope,
    required this.regIntercept,
    required this.corrLabels,
    required this.corrMatrix,
    required this.diameterAll,
    required this.waterRich,
    required this.waterPoor,
    required this.divergingDiameter,
    required this.waterCumAvg,
    required this.calendarCells,
    required this.ganttTasks,
    required this.gaugeValue,
    required this.gaugeMetric,
    required this.bulletValue,
    required this.bulletTarget,
    required this.bulletMax,
    required this.bulletRanges,
    required this.radarTitles,
    required this.radarFocus,
    required this.radarAvg,
    required this.multiRadarLabels,
    required this.multiRadar,
    required this.stripGroups,
    required this.pyramidLeft,
    required this.pyramidRight,
    required this.annotatedMaxIndex,
    required this.annotatedMinIndex,
    required this.totalPlanets,
  });

  factory ChartsData.build(List<Planet> planets, {Planet? focus}) {
    final focusPlanet = focus ?? planets.first;

    double? gravityValue(String raw) {
      final head = raw.split(' ').first.trim();
      return double.tryParse(head);
    }

    double avg(List<double> v) => v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;

    final withDiameter = planets.where((p) => p.diameterValue != null).toList()
      ..sort((a, b) => b.diameterValue!.compareTo(a.diameterValue!));
    final withPop = planets.where((p) => p.populationValue != null).toList()
      ..sort((a, b) => b.populationValue!.compareTo(a.populationValue!));
    final withWater = planets.where((p) => p.surfaceWaterValue != null).toList();
    final diameters = withDiameter.map((p) => p.diameterValue!).toList();
    final diameterAvg = avg(diameters);

    // Secuencia fija de 10 planetas por diámetro.
    final seq = withDiameter.take(10).toList();

    // Conteos por categoría (top N + "Otros").
    List<NameValue> countBy(List<String> Function(Planet) pick, {int top = 6}) {
      final counts = <String, int>{};
      for (final p in planets) {
        for (final key in pick(p)) {
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }
      final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final head = entries.take(top).toList();
      final rest = entries.skip(top).fold<int>(0, (s, e) => s + e.value);
      final result = head.map((e) => NameValue(e.key, e.value.toDouble())).toList();
      if (rest > 0) result.add(NameValue('Otros', rest.toDouble()));
      return result;
    }

    final climateCounts = countBy((p) => p.climateList);
    final terrainCounts = countBy((p) => p.terrainList);
    final biomeCounts = countBy((p) => [styleFor(p).label]);

    final topTerrains = terrainCounts.where((e) => e.label != 'Otros').toList();
    final terrainWaterAvg = <NameValue>[];
    for (final t in topTerrains) {
      final members = withWater.where((p) => p.terrainList.contains(t.label)).toList();
      if (members.isEmpty) continue;
      terrainWaterAvg.add(
        NameValue(t.label, avg(members.map((p) => p.surfaceWaterValue!).toList())),
      );
    }

    // Biomas con sus miembros.
    const biomeOrder = [
      PlanetBiome.desert,
      PlanetBiome.ice,
      PlanetBiome.ocean,
      PlanetBiome.swamp,
      PlanetBiome.forest,
      PlanetBiome.volcanic,
      PlanetBiome.rocky,
      PlanetBiome.temperate,
      PlanetBiome.gasGiant,
      PlanetBiome.unknown,
    ];
    final biomeLabels = <String>[];
    final biomeMembers = <String, List<Planet>>{};
    for (final b in biomeOrder) {
      final members = planets.where((p) => biomeFor(p) == b).toList();
      if (members.isEmpty) continue;
      biomeLabels.add(planetBiomeStyles[b]!.label);
      biomeMembers[planetBiomeStyles[b]!.label] = members;
    }

    BoxStats boxFor(String label, List<double> values) {
      final v = values.toList()..sort();
      if (v.isEmpty) {
        return BoxStats(
          label: label,
          min: 0,
          q1: 0,
          median: 0,
          q3: 0,
          max: 0,
          mean: 0,
          std: 0,
        );
      }
      double quantile(double q) {
        final pos = q * (v.length - 1);
        final lo = pos.floor();
        final hi = pos.ceil();
        if (lo == hi) return v[lo];
        return v[lo] + (v[hi] - v[lo]) * (pos - lo);
      }

      final mean = avg(v);
      final variance = avg(v.map((x) => (x - mean) * (x - mean)).toList());
      return BoxStats(
        label: label,
        min: v.first,
        q1: quantile(0.25),
        median: quantile(0.5),
        q3: quantile(0.75),
        max: v.last,
        mean: mean,
        std: sqrt(variance),
      );
    }

    final biomeCountValues = <double>[];
    final biomeWaterAvg = <double>[];
    final biomeDiameterBox = <BoxStats>[];
    final biomeOhlc = <OhlcBar>[];
    final biomeDiameterRange = <BandStat>[];
    final biomeWaterBand = <BandStat>[];
    final waterRich = <double>[];
    final waterPoor = <double>[];
    final stripGroups = <StripGroup>[];

    for (final label in biomeLabels) {
      final members = biomeMembers[label]!;
      biomeCountValues.add(members.length.toDouble());

      final waterValues = members
          .where((p) => p.surfaceWaterValue != null)
          .map((p) => p.surfaceWaterValue!)
          .toList();
      biomeWaterAvg.add(waterValues.isEmpty ? 0 : avg(waterValues));

      final dValues = members
          .where((p) => p.diameterValue != null)
          .map((p) => p.diameterValue!)
          .toList();
      final stats = boxFor(label, dValues);
      biomeDiameterBox.add(stats);
      biomeOhlc.add(OhlcBar(
        label: label,
        open: stats.q1,
        close: stats.q3,
        high: stats.max,
        low: stats.min,
      ));
      biomeDiameterRange.add(BandStat(
        label: label,
        center: stats.mean,
        lower: stats.min,
        upper: stats.max,
      ));

      final wStats = boxFor(label, waterValues);
      biomeWaterBand.add(BandStat(
        label: label,
        center: wStats.mean,
        lower: max(0, wStats.mean - wStats.std),
        upper: min(100, wStats.mean + wStats.std),
      ));

      waterRich.add(members.where((p) => (p.surfaceWaterValue ?? 0) > 50).length.toDouble());
      waterPoor.add(members.where((p) => (p.surfaceWaterValue ?? 999) <= 50).length.toDouble());
      stripGroups.add(StripGroup(label: label, values: dValues));
    }

    // Matriz clima × terreno (top 6 filas / top 6 columnas).
    final rows =
        climateCounts.where((e) => e.label != 'Otros').take(6).map((e) => e.label).toList();
    final cols =
        terrainCounts.where((e) => e.label != 'Otros').take(6).map((e) => e.label).toList();
    final matrixValues = <List<double>>[];
    for (final r in rows) {
      final line = <double>[];
      for (final c in cols) {
        final n = planets
            .where((p) => p.climateList.contains(r) && p.terrainList.contains(c))
            .length;
        line.add(n.toDouble());
      }
      matrixValues.add(line);
    }

    // Apilados: climas (categorías) × biomas (series).
    final stackClimates = rows;
    final stackBiomes = biomeLabels;
    final stackValues = <List<double>>[];
    for (final c in stackClimates) {
      final line = <double>[];
      for (final b in stackBiomes) {
        final n = planets
            .where((p) => p.climateList.contains(c) && styleFor(p).label == b)
            .length;
        line.add(n.toDouble());
      }
      stackValues.add(line);
    }

    // Flujos Sankey: clima → terreno (pares reales, top 14 por volumen).
    final linkCounts = <String, int>{};
    for (final p in planets) {
      for (final c in p.climateList) {
        for (final t in p.terrainList) {
          final key = '$c|$t';
          linkCounts[key] = (linkCounts[key] ?? 0) + 1;
        }
      }
    }
    final topLinks = linkCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final flows = topLinks.take(14).map((e) {
      final parts = e.key.split('|');
      return FlowLink(from: parts[0], to: parts[1], value: e.value.toDouble());
    }).toList();

    // Jerarquías (terreno→clima y clima→terreno) para treemap/sunburst.
    List<TreeNodeData> buildHierarchy(
      List<NameValue> outer,
      List<NameValue> inner,
      bool Function(Planet p, String outerKey, String innerKey) match,
    ) {
      return outer.where((o) => o.label != 'Otros').take(5).map((o) {
        final children = <TreeNodeData>[];
        for (final i in inner.take(4)) {
          final n = planets.where((p) => match(p, o.label, i.label)).length;
          if (n > 0) children.add(TreeNodeData(label: i.label, value: n.toDouble()));
        }
        final total = planets.where((p) => match(p, o.label, '')).length.toDouble();
        return TreeNodeData(label: o.label, value: total, children: children);
      }).toList();
    }

    final hierarchyTerrain = buildHierarchy(
      terrainCounts,
      climateCounts,
      (p, t, c) => p.terrainList.contains(t) && (c.isEmpty || p.climateList.contains(c)),
    );
    final hierarchyClimate = buildHierarchy(
      climateCounts,
      terrainCounts,
      (p, c, t) => p.climateList.contains(c) && (t.isEmpty || p.terrainList.contains(t)),
    );

    // Dispersión y burbujas.
    final scatterDiameterPopulation = <ScatterPt>[];
    final scatterBubble = <ScatterPt>[];
    for (final p in planets) {
      final d = p.diameterValue;
      final pop = p.populationValue;
      if (d == null || pop == null || pop <= 0) continue;
      scatterDiameterPopulation.add(ScatterPt(
        label: p.name,
        x: d,
        y: pop,
        size: p.surfaceWaterValue ?? 20,
      ));
      scatterBubble.add(ScatterPt(
        label: p.name,
        x: log10(d),
        y: log10(pop),
        size: (p.surfaceWaterValue ?? 20).clamp(1, 100).toDouble(),
      ));
    }

    final scatterRotationOrbital = <ScatterPt>[];
    for (final p in planets) {
      final r = p.rotationValue;
      final o = p.orbitalValue;
      if (r == null || o == null) continue;
      scatterRotationOrbital.add(ScatterPt(label: p.name, x: r, y: o));
    }

    // Regresión lineal: diámetro → log10(población).
    double slope = 0, intercept = 0;
    if (scatterDiameterPopulation.length >= 2) {
      final xs = scatterDiameterPopulation.map((p) => p.x).toList();
      final ys = scatterDiameterPopulation.map((p) => log10(p.y)).toList();
      final mx = avg(xs);
      final my = avg(ys);
      double cov = 0, varx = 0;
      for (var i = 0; i < xs.length; i++) {
        cov += (xs[i] - mx) * (ys[i] - my);
        varx += (xs[i] - mx) * (xs[i] - mx);
      }
      slope = varx == 0 ? 0 : cov / varx;
      intercept = my - slope * mx;
    }

    // Correlaciones de Pearson entre campos numéricos.
    final corrLabels = ['Diámetro', 'Población', 'Rotación', 'Órbita', 'Agua', 'Gravedad'];
    List<double?> col(int idx) {
      switch (idx) {
        case 0:
          return planets.map((p) => p.diameterValue).toList();
        case 1:
          return planets.map((p) => p.populationValue).toList();
        case 2:
          return planets.map((p) => p.rotationValue).toList();
        case 3:
          return planets.map((p) => p.orbitalValue).toList();
        case 4:
          return planets.map((p) => p.surfaceWaterValue).toList();
        default:
          return planets.map((p) => gravityValue(p.gravity)).toList();
      }
    }

    double pearson(List<double?> a, List<double?> b) {
      final xs = <double>[];
      final ys = <double>[];
      for (var i = 0; i < a.length; i++) {
        final x = a[i];
        final y = b[i];
        if (x == null || y == null) continue;
        xs.add(x);
        ys.add(y);
      }
      if (xs.length < 3) return 0;
      final mx = avg(xs);
      final my = avg(ys);
      double cov = 0, vx = 0, vy = 0;
      for (var i = 0; i < xs.length; i++) {
        cov += (xs[i] - mx) * (ys[i] - my);
        vx += (xs[i] - mx) * (xs[i] - mx);
        vy += (ys[i] - my) * (ys[i] - my);
      }
      if (vx == 0 || vy == 0) return 0;
      return cov / sqrt(vx * vy);
    }

    final corrMatrix = <List<double>>[];
    for (var i = 0; i < corrLabels.length; i++) {
      final row = <double>[];
      for (var j = 0; j < corrLabels.length; j++) {
        row.add(pearson(col(i), col(j)));
      }
      corrMatrix.add(row);
    }

    // Divergentes: diámetro menos el promedio (±).
    final divergingDiameter = withDiameter
        .take(9)
        .map((p) => NameValue(p.name, p.diameterValue! - diameterAvg))
        .toList();

    // Promedio acumulado del agua sobre la secuencia.
    double running = 0;
    final waterCumAvg = <double>[];
    for (var i = 0; i < seq.length; i++) {
      running += seq[i].surfaceWaterValue ?? 0;
      waterCumAvg.add(running / (i + 1));
    }

    // Cuadrícula calendario: intensidad 0-100 según diámetro.
    final maxDiam = diameters.isEmpty ? 1.0 : diameters.first;
    final calendarCells = withDiameter
        .map((p) => NameValue(p.name, (p.diameterValue! / maxDiam * 100).clamp(0, 100)))
        .toList();

    // Gantt: duración = periodo orbital, ordenado de mayor a menor.
    final ganttTasks = planets
        .where((p) => p.orbitalValue != null)
        .map((p) => NameValue(p.name, p.orbitalValue!))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Gauge y bullet del planeta en foco (0-100 para el medidor).
    double gaugeValue;
    String gaugeMetric;
    final focusWater = focusPlanet.surfaceWaterValue;
    if (focusWater != null) {
      gaugeValue = focusWater.clamp(0, 100).toDouble();
      gaugeMetric = 'Agua superficial de ${focusPlanet.name}';
    } else {
      final rank = planets
          .where((p) => (p.diameterValue ?? 0) <= (focusPlanet.diameterValue ?? 0))
          .length;
      gaugeValue = planets.isEmpty ? 0 : rank / planets.length * 100;
      gaugeMetric = 'Percentil de diámetro de ${focusPlanet.name}';
    }

    final bulletValue = focusPlanet.diameterValue ?? 0;
    final bulletTarget = diameterAvg;
    final bulletMax = diameters.isEmpty ? 1.0 : diameters.first;
    final bulletRanges = [bulletMax * 0.25, bulletMax * 0.5, bulletMax];

    // Radar: 6 ejes normalizados 0-100 frente al promedio (50).
    const radarTitles = [
      'Población',
      'Traslación',
      'Gravedad',
      'Agua',
      'Rotación',
      'Recursos',
    ];
    double norm(double? v, double avgValue) {
      if (v == null || avgValue <= 0) return 0;
      return (v / avgValue * 50).clamp(0, 100).toDouble();
    }

    double avgOf(List<double?> values) {
      final valid = values.whereType<double>().toList();
      return valid.isEmpty ? 0 : valid.reduce((a, b) => a + b) / valid.length;
    }

    List<double> profile(Planet p) => [
          norm(p.populationValue, avgOf(planets.map((x) => x.populationValue).toList())),
          norm(p.orbitalValue, avgOf(planets.map((x) => x.orbitalValue).toList())),
          50.0,
          norm(p.surfaceWaterValue, avgOf(planets.map((x) => x.surfaceWaterValue).toList())),
          norm(p.rotationValue, avgOf(planets.map((x) => x.rotationValue).toList())),
          norm(p.diameterValue, avgOf(planets.map((x) => x.diameterValue).toList())),
        ];

    final others = planets.where((p) => p.id != focusPlanet.id).take(2).toList();
    final multiRadarLabels = [focusPlanet.name, ...others.map((p) => p.name)];
    final multiRadar = [profile(focusPlanet), ...others.map(profile)];

    // Pirámide: conteo vs agua promedio por terreno.
    final pyramidLeft = topTerrains.take(6).map((t) => NameValue(t.label, t.value)).toList();
    final pyramidRight = terrainWaterAvg.take(pyramidLeft.length).toList();

    // Índices de anotación (máx/mín de la secuencia de diámetros).
    var maxIdx = 0;
    var minIdx = 0;
    for (var i = 1; i < seq.length; i++) {
      if (seq[i].diameterValue! > seq[maxIdx].diameterValue!) maxIdx = i;
      if (seq[i].diameterValue! < seq[minIdx].diameterValue!) minIdx = i;
    }

    return ChartsData(
      planets: planets,
      focus: focusPlanet,
      seqLabels: seq.map((p) => p.name).toList(),
      seqDiameter: seq.map((p) => p.diameterValue!).toList(),
      seqPopulation: seq.map((p) => p.populationValue ?? 0).toList(),
      seqPopulationLog: seq
          .map((p) {
            final v = p.populationValue;
            if (v == null || v <= 0) return 0.0;
            return log10(v);
          })
          .toList(),
      seqWater: seq.map((p) => p.surfaceWaterValue ?? 0).toList(),
      seqRotation: seq.map((p) => p.rotationValue ?? 0).toList(),
      seqOrbital: seq.map((p) => p.orbitalValue ?? 0).toList(),
      diameterAvg: diameterAvg,
      topDiameter: withDiameter.take(8).map((p) => NameValue(p.name, p.diameterValue!)).toList(),
      topPopulation: withPop.take(10).map((p) => NameValue(p.name, p.populationValue!)).toList(),
      climateCounts: climateCounts,
      terrainCounts: terrainCounts,
      biomeCounts: biomeCounts,
      terrainWaterAvg: terrainWaterAvg,
      biomeLabels: biomeLabels,
      biomeCountValues: biomeCountValues,
      biomeWaterAvg: biomeWaterAvg,
      biomeDiameterBox: biomeDiameterBox,
      biomeOhlc: biomeOhlc,
      biomeDiameterRange: biomeDiameterRange,
      biomeWaterBand: biomeWaterBand,
      matrixRows: rows,
      matrixCols: cols,
      matrixValues: matrixValues,
      stackClimates: stackClimates,
      stackBiomes: stackBiomes,
      stackValues: stackValues,
      flows: flows,
      hierarchyTerrain: hierarchyTerrain,
      hierarchyClimate: hierarchyClimate,
      scatterDiameterPopulation: scatterDiameterPopulation,
      scatterRotationOrbital: scatterRotationOrbital,
      scatterBubble: scatterBubble,
      regSlope: slope,
      regIntercept: intercept,
      corrLabels: corrLabels,
      corrMatrix: corrMatrix,
      diameterAll: diameters,
      waterRich: waterRich,
      waterPoor: waterPoor,
      divergingDiameter: divergingDiameter,
      waterCumAvg: waterCumAvg,
      calendarCells: calendarCells,
      ganttTasks: ganttTasks,
      gaugeValue: gaugeValue,
      gaugeMetric: gaugeMetric,
      bulletValue: bulletValue,
      bulletTarget: bulletTarget,
      bulletMax: bulletMax,
      bulletRanges: bulletRanges,
      radarTitles: radarTitles,
      radarFocus: profile(focusPlanet),
      radarAvg: const [50.0, 50.0, 50.0, 50.0, 50.0, 50.0],
      multiRadarLabels: multiRadarLabels,
      multiRadar: multiRadar,
      stripGroups: stripGroups,
      pyramidLeft: pyramidLeft,
      pyramidRight: pyramidRight,
      annotatedMaxIndex: maxIdx,
      annotatedMinIndex: minIdx,
      totalPlanets: planets.length,
    );
  }

  /// Normaliza una serie a 0-100 (útil al comparar magnitudes distintas
  /// en los mismos ejes).
  static List<double> normalize(List<double> values) {
    if (values.isEmpty) return const [];
    final maxV = values.reduce((a, b) => a > b ? a : b);
    if (maxV == 0) return values;
    return values.map((v) => v / maxV * 100).toList();
  }

  /// Agrupa valores en [bins] contenedores de igual ancho.
  static List<NameValue> histogramBins(List<double> values, int bins) {
    if (values.isEmpty) return const [];
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    if (minV == maxV) return [NameValue('${minV.toInt()}', values.length.toDouble())];
    final width = (maxV - minV) / bins;
    final counts = List<double>.filled(bins, 0);
    for (final v in values) {
      var idx = ((v - minV) / width).floor();
      if (idx >= bins) idx = bins - 1;
      counts[idx] += 1;
    }
    return List.generate(bins, (i) {
      final start = minV + width * i;
      return NameValue(_compact(start), counts[i]);
    });
  }

  static String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }
}
