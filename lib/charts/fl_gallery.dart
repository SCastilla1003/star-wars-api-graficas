import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'charts_data.dart';

/// Galería de las 63 gráficas del catálogo renderizadas con fl_chart.
Widget buildFlChart(String id, ChartsData d) => _fl(id, d);

const _palette = [
  Color(0xFF6C63FF),
  Color(0xFFFF6584),
  Color(0xFF43E97B),
  Color(0xFFFFB74D),
  Color(0xFF4DD0E1),
  Color(0xFFBA68C8),
  Color(0xFFFFE082),
  Color(0xFF8D6E63),
  Color(0xFF78909C),
];

Color _c(int i) => _palette[i % _palette.length];

Color _fade(Color c, double opacity) => c.withAlpha((opacity * 255).round());

String _fmt(double v) {
  final a = v.abs();
  if (a >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
  if (a >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
  if (a >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}k';
  if (a == a.roundToDouble()) return v.round().toString();
  return v.toStringAsFixed(1);
}

FlGridData _grid() => FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) =>
          const FlLine(color: Color(0xFFE8EDF3), strokeWidth: 1),
    );

FlBorderData _border() => FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xFFDDE3EA)),
    );

AxisTitles _none() => AxisTitles(sideTitles: const SideTitles(showTitles: false));

AxisTitles _bottomLabels(List<String> labels, {double reserved = 38}) =>
    AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: reserved,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final i = value.round();
          if (i < 0 || i >= labels.length) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Transform.rotate(
              angle: -0.7,
              child: Text(
                labels[i],
                style: const TextStyle(fontSize: 9, color: Color(0xFF607D8B)),
              ),
            ),
          );
        },
      ),
    );

AxisTitles _leftValues({String Function(double)? fmt}) => AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 44,
        getTitlesWidget: (value, meta) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Text(
            fmt == null ? _fmt(value) : fmt(value),
            style: const TextStyle(fontSize: 9, color: Color(0xFF90A4AE)),
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );

FlTitlesData _titles({
  AxisTitles? bottom,
  AxisTitles? left,
}) =>
    FlTitlesData(
      show: true,
      leftTitles: left ?? _leftValues(),
      bottomTitles: bottom ?? _none(),
      rightTitles: _none(),
      topTitles: _none(),
    );

/// Rota una gráfica vertical 90° para obtener barras horizontales
/// (fl_chart no soporta barras horizontales de forma nativa). Usa un
/// cuadrado inscrito para que la caja rotada siempre quepa sin overflow.
Widget _rotated(Widget child) => LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final s = w < h ? w : h;
        return Center(
          child: SizedBox(
            width: s,
            height: s,
            child: Transform.rotate(
              angle: math.pi / 2,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
    );

/// Apila un BarChart con un LineChart alineado: con
/// BarChartAlignment.spaceAround los centros de los grupos caen exactamente
/// en (i + 0.5) / n, que es donde LineChart coloca los spots con
/// minX = -0.5 y maxX = n - 0.5.
Widget _comboStack({
  required List<BarChartGroupData> groups,
  required List<FlSpot> lineSpots,
  required FlTitlesData titles,
  double? maxY,
  double? minY,
  Color lineColor = const Color(0xFFD84315),
  bool showLine = true,
  bool showDots = false,
  bool lineOnTop = true,
  bool curved = false,
}) {
  final n = groups.length;
  final bar = BarChart(
    BarChartData(
      barGroups: groups,
      titlesData: titles,
      gridData: _grid(),
      borderData: _border(),
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      minY: minY,
    ),
  );
  final line = LineChart(
    LineChartData(
      minX: -0.5,
      maxX: n - 0.5,
      minY: minY ?? 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: lineSpots,
          color: lineColor,
          barWidth: 2.6,
          isCurved: curved,
          show: showLine,
          dotData: FlDotData(show: showDots),
        ),
      ],
      titlesData: titles,
      gridData: _grid(),
      borderData: _border(),
    ),
  );
  return Stack(
    children: lineOnTop
        ? [bar, Positioned.fill(child: line)]
        : [line, Positioned.fill(child: bar)],
  );
}

/// Construye una o varias series de línea a partir de valores.
Widget _lineChart({
  required List<List<double>> values,
  required List<String> bottomLabels,
  required List<String> legend,
  List<List<int>?>? dashes,
  List<bool>? curved,
  List<bool>? showDots,
  List<bool>? fill,
  double? minY,
  double? maxY,
  bool showAxes = true,
  ExtraLinesData? extra,
  String Function(double)? leftFmt,
  double? minX,
  double? maxX,
  List<List<FlSpot>>? customSpots,
}) {
  final series = customSpots ??
      [
        for (var s = 0; s < values.length; s++)
          [
            for (var i = 0; i < values[s].length; i++) FlSpot(i.toDouble(), values[s][i]),
          ],
      ];
  final colors = List.generate(series.length, (i) => _c(i));
  final bars = <LineChartBarData>[];
  for (var s = 0; s < series.length; s++) {
    final filled = fill != null && fill[s];
    bars.add(LineChartBarData(
      spots: series[s],
      color: colors[s],
      barWidth: 2.4,
      isCurved: curved != null && curved[s],
      dashArray: dashes == null ? null : dashes[s],
      dotData: FlDotData(show: showDots != null && showDots[s]),
      belowBarData: BarAreaData(
        show: filled,
        color: filled ? _fade(colors[s], 0.28) : null,
      ),
    ));
  }
  final chart = LineChart(
    LineChartData(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: bars,
      titlesData: showAxes
          ? _titles(bottom: _bottomLabels(bottomLabels), left: _leftValues(fmt: leftFmt))
          : FlTitlesData(
              show: false,
              leftTitles: _none(),
              bottomTitles: _none(),
              rightTitles: _none(),
              topTitles: _none(),
            ),
      gridData: showAxes ? _grid() : const FlGridData(show: false),
      borderData: showAxes
          ? _border()
          : FlBorderData(show: false, border: Border.all(color: Colors.transparent)),
      lineTouchData: LineTouchData(enabled: true),
      extraLinesData: extra,
    ),
  );
  if (legend.length != series.length || series.length < 2) return chart;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [Expanded(child: chart), _legendRow(legend)],
  );
}

Widget _flMissing(String id) => Center(child: Text('Sin implementar: $id'));

List<BarChartGroupData> _singleGroups(
  List<NameValue> items, {
  Color? color,
  double width = 20,
  double? fromY,
  double Function(NameValue)? valueOf,
}) =>
    [
      for (var i = 0; i < items.length; i++)
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: valueOf == null ? items[i].value : valueOf(items[i]),
            fromY: fromY ?? 0,
            width: width,
            color: color ?? _c(i),
          ),
        ]),
    ];

List<BarChartGroupData> _multiGroups(
  List<String> labels,
  List<List<double>> series, {
  double width = 14,
  double barsSpace = 3,
  double Function(double)? transform,
}) =>
    [
      for (var i = 0; i < labels.length; i++)
        BarChartGroupData(x: i, barsSpace: barsSpace, barRods: [
          for (var s = 0; s < series.length; s++)
            BarChartRodData(
              toY: transform == null ? series[s][i] : transform(series[s][i]),
              width: width,
              color: _c(s),
            ),
        ]),
    ];

List<BarChartGroupData> _stackedGroups(
  List<String> labels,
  List<List<double>> series, {
  double width = 26,
  bool percent = false,
}) =>
    [
      for (var i = 0; i < labels.length; i++)
        () {
          var acc = 0.0;
          final items = <BarChartRodStackItem>[];
          for (var s = 0; s < series.length; s++) {
            acc += series[s][i];
          }
          final total = acc;
          var run = 0.0;
          for (var s = 0; s < series.length; s++) {
            final v = series[s][i];
            if (v <= 0) continue;
            final hi = percent ? (total == 0 ? 0 : v / total * 100) : v;
            items.add(BarChartRodStackItem(run, run + hi, _c(s)));
            run += hi;
          }
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: run,
              width: width,
              color: _c(0),
              rodStackItems: items,
            ),
          ]);
        }(),
    ];

List<FlSpot> _stepSpots(List<double> values) => [
      for (var i = 0; i < values.length; i++) ...[
        FlSpot(i.toDouble(), values[i]),
        if (i < values.length - 1) FlSpot(i + 0.98, values[i]),
      ],
    ];

Widget _fl(String id, ChartsData d) {
  switch (id) {
    // ---------------------------------------------------------- básicas línea
    case 'line_simple':
      return _lineChart(
        values: [d.seqDiameter],
        bottomLabels: d.seqLabels,
        legend: const ['Diámetro'],
      );
    case 'line_multi':
      return _lineChart(
        values: [
          ChartsData.normalize(d.seqPopulation),
          d.seqWater,
          ChartsData.normalize(d.seqRotation),
        ],
        bottomLabels: d.seqLabels,
        legend: const ['Población', 'Agua', 'Rotación'],
        fill: const [false, false, false],
      );
    case 'line_markers':
      return _lineChart(
        values: [d.seqDiameter],
        bottomLabels: d.seqLabels,
        legend: const ['Diámetro'],
        showDots: const [true],
      );
    case 'line_dashed':
      return _lineChart(
        values: [d.seqDiameter],
        bottomLabels: d.seqLabels,
        legend: const ['Diámetro'],
        dashes: const [
          [6, 5],
        ],
      );
    case 'line_smooth':
      return _lineChart(
        values: [d.seqDiameter],
        bottomLabels: d.seqLabels,
        legend: const ['Diámetro'],
        curved: const [true],
      );
    case 'line_gradient':
      return _lineChart(
        values: [d.seqDiameter],
        bottomLabels: d.seqLabels,
        legend: const ['Diámetro'],
        fill: const [true],
        curved: const [true],
      );
    case 'step_line':
      return LineChart(
        LineChartData(
          minX: 0,
          maxX: d.seqLabels.length - 0.02,
          lineBarsData: [
            LineChartBarData(
              spots: _stepSpots(d.seqDiameter),
              color: _c(0),
              barWidth: 2.4,
              dotData: FlDotData(show: false),
            ),
          ],
          titlesData:
              _titles(bottom: _bottomLabels(d.seqLabels), left: _leftValues()),
          gridData: _grid(),
          borderData: _border(),
        ),
      );

    // --------------------------------------------------------- básicas barras
    case 'bar_vertical':
      return BarChart(
        BarChartData(
          barGroups: _singleGroups(d.topDiameter),
          titlesData:
              _titles(bottom: _bottomLabels(_namesOf(d.topDiameter))),
          gridData: _grid(),
          borderData: _border(),
          alignment: BarChartAlignment.spaceAround,
        ),
      );
    case 'bar_horizontal':
      return _rotated(
        BarChart(
          BarChartData(
            barGroups: _singleGroups(d.topPopulation),
            titlesData: _titles(
              bottom: _bottomLabels(_namesOf(d.topPopulation), reserved: 46),
              left: _leftValues(),
            ),
            gridData: _grid(),
            borderData: _border(),
            alignment: BarChartAlignment.spaceAround,
          ),
        ),
      );
    case 'bar_grouped':
      final means = [
        for (final b in d.biomeDiameterBox) b.mean,
      ];
      final maxMean = means.fold<double>(0, (a, b) => a > b ? a : b);
      return BarChart(
        BarChartData(
          barGroups: _multiGroups(d.biomeLabels, [
            [for (final m in means) maxMean == 0 ? 0.0 : m / maxMean * 100],
            d.biomeWaterAvg,
          ]),
          maxY: 100,
          titlesData: _titles(bottom: _bottomLabels(d.biomeLabels)),
          gridData: _grid(),
          borderData: _border(),
          alignment: BarChartAlignment.spaceAround,
        ),
      );
    case 'bar_stacked':
      final seriesByClimate = [
        for (var c = 0; c < d.stackClimates.length; c++)
          [
            for (var b = 0; b < d.stackBiomes.length; b++) d.stackValues[c][b],
          ],
      ];
      return BarChart(
        BarChartData(
          barGroups: _stackedGroups(d.stackBiomes, seriesByClimate),
          titlesData: _titles(bottom: _bottomLabels(d.stackBiomes)),
          gridData: _grid(),
          borderData: _border(),
          alignment: BarChartAlignment.spaceAround,
        ),
      );
    case 'bar_stacked_100': {
      final seriesByCol = [
        for (var c = 0; c < d.matrixCols.length; c++)
          [
            for (var r = 0; r < d.matrixRows.length; r++) d.matrixValues[r][c],
          ],
      ];
      return BarChart(
        BarChartData(
          barGroups:
              _stackedGroups(d.matrixRows, seriesByCol, percent: true),
          maxY: 100,
          titlesData: _titles(bottom: _bottomLabels(d.matrixRows)),
          gridData: _grid(),
          borderData: _border(),
          alignment: BarChartAlignment.spaceAround,
        ),
      );
    }
    case 'bar_diverging':
      return BarChart(
        BarChartData(
          barGroups: _singleGroups(
            d.divergingDiameter,
            color: _c(1),
            valueOf: (e) => e.value,
          ),
          minY: d.divergingDiameter
                  .map((e) => e.value)
                  .fold<double>(0, (a, b) => b < a ? b : a) *
              1.2,
          maxY: d.divergingDiameter
                  .map((e) => e.value)
                  .fold<double>(0, (a, b) => b > a ? b : a) *
              1.2,
          titlesData: _titles(
            bottom: _bottomLabels(_namesOf(d.divergingDiameter)),
          ),
          gridData: _grid(),
          borderData: _border(),
          alignment: BarChartAlignment.spaceAround,
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(y: 0, color: const Color(0xFF90A4AE), strokeWidth: 1.4),
          ]),
        ),
      );
    case 'combo_bar_line':
      return _comboStack(
        groups: _singleGroups(
          [
            for (var i = 0; i < d.seqLabels.length; i++)
              NameValue(d.seqLabels[i], d.seqDiameter[i]),
          ],
        ),
        lineSpots: [
          for (var i = 0; i < d.waterCumAvg.length; i++)
            FlSpot(i.toDouble(), d.waterCumAvg[i]),
        ],
        maxY: d.seqDiameter.fold<double>(0, (a, b) => a > b ? a : b) * 1.15,
        minY: 0,
        titles: _titles(bottom: _bottomLabels(d.seqLabels)),
        lineColor: _c(2),
        showDots: true,
      );

    // ------------------------------------------------------------ básicas área
    case 'area_simple':
      return _lineChart(
        values: [d.seqDiameter],
        bottomLabels: d.seqLabels,
        legend: const ['Diámetro'],
        fill: const [true],
      );
    case 'area_gradient':
      return _lineChart(
        values: [d.seqDiameter],
        bottomLabels: d.seqLabels,
        legend: const ['Diámetro'],
        fill: const [true],
        curved: const [true],
      );
    case 'area_stacked':
      return _lineChart(
        values: [d.waterRich, d.waterPoor],
        bottomLabels: d.biomeLabels,
        legend: const ['Agua > 50%', 'Agua <= 50%'],
        fill: const [true, true],
        showDots: const [true, true],
        leftFmt: (v) => _fmt(v),
      );
    case 'step_area':
      return LineChart(
        LineChartData(
          minX: 0,
          maxX: d.seqLabels.length - 0.02,
          lineBarsData: [
            LineChartBarData(
              spots: _stepSpots(d.seqDiameter),
              color: _c(0),
              barWidth: 2.2,
              belowBarData: BarAreaData(show: true, color: _fade(_c(0), 0.3)),
            ),
          ],
          titlesData:
              _titles(bottom: _bottomLabels(d.seqLabels), left: _leftValues()),
          gridData: _grid(),
          borderData: _border(),
        ),
      );

    // ---------------------------------------------------------- básicas tarta
    case 'pie_basic':
      return _pie(d.climateCounts, donut: false);
    case 'pie_percent':
      return _pie(d.climateCounts, donut: false, percentTitle: true);
    case 'donut_basic':
      return _pie(d.climateCounts, donut: true);
    case 'donut_kpi':
      return _pie(d.climateCounts, donut: true, kpi: '${d.totalPlanets}');
    case 'pie_exploded':
      return _pie(d.climateCounts, donut: false, explodeTop: true);
    case 'donut_multi_ring':
      return _multiRing(d);
    case 'polar_area':
      return _polar(d);

    // -------------------------------------------------------- básicas puntos
    case 'scatter_basic':
      return _scatter(
        pts: d.scatterDiameterPopulation,
        xLabel: 'Diámetro (km)',
        yLabel: 'Población',
      );
    case 'scatter_bubble':
      return _scatter(
        pts: d.scatterDiameterPopulation,
        xLabel: 'Diámetro (km)',
        yLabel: 'Población',
        bubble: true,
      );
    case 'bubble_log':
      return _scatter(
        pts: d.scatterBubble,
        xLabel: 'log10 diámetro',
        yLabel: 'log10 población',
        bubble: true,
        logSized: true,
      );
    case 'scatter_regression':
      return _regression(d);
    case 'strip_plot':
      return _strip(d);
    case 'correlation_matrix':
      return _matrixBars(
        labels: [
          for (var i = 0; i < d.corrLabels.length; i++)
            for (var j = i + 1; j < d.corrLabels.length; j++)
              '${d.corrLabels[i]}/${d.corrLabels[j]}',
        ],
        values: [
          for (var i = 0; i < d.corrLabels.length; i++)
            for (var j = i + 1; j < d.corrLabels.length; j++) d.corrMatrix[i][j],
        ],
      );

    // -------------------------------------------------------- básicas radar
    case 'radar_basic':
    case 'radar_circle':
    case 'radar_multi':
      return _radar(d, multi: id == 'radar_multi');

    // ----------------------------------------------------- básicas sparkline
    case 'spark_line':
      return _spark(values: d.seqPopulationLog, fill: false);
    case 'spark_area':
      return _spark(values: d.seqDiameter, fill: true);
    case 'spark_bar':
      return _spark(values: d.seqWater, bars: true);

    // -------------------------------------------------- básicas apiladas +
    case 'bar_stacked_total':
      final totalByBiome = <double>[];
      for (var b = 0; b < d.stackBiomes.length; b++) {
        var t = 0.0;
        for (var c = 0; c < d.stackClimates.length; c++) {
          t += d.stackValues[c][b];
        }
        totalByBiome.add(t);
      }
      final seriesByClimate = [
        for (var c = 0; c < d.stackClimates.length; c++)
          [
            for (var b = 0; b < d.stackBiomes.length; b++)
              d.stackValues[c][b],
          ],
      ];
      return _comboStack(
        groups: _stackedGroups(d.stackBiomes, seriesByClimate),
        lineSpots: [
          for (var i = 0; i < totalByBiome.length; i++)
            FlSpot(i.toDouble(), totalByBiome[i]),
        ],
        maxY: totalByBiome.fold<double>(0, (a, b) => a > b ? a : b) * 1.2,
        minY: 0,
        titles: _titles(bottom: _bottomLabels(d.stackBiomes)),
        lineColor: _c(1),
        showDots: true,
      );

    // ------------------------------------------------------- avanzadas puro
    case 'candlestick':
      return _candles(d, outline: false);
    case 'ohlc':
      return _candles(d, outline: true);
    case 'histogram':
      return _histogram(d);
    case 'box_plot':
      return _boxPlot(d);
    case 'waterfall':
      return _waterfall(d, percent: false);
    case 'waterfall_percent':
      return _waterfall(d, percent: true);

    case 'funnel':
      return _rotated(
        BarChart(
          BarChartData(
            barGroups: _singleGroups(d.climateCounts, color: _c(4)),
            titlesData: _titles(
              bottom: _bottomLabels(_namesOf(d.climateCounts), reserved: 46),
            ),
            gridData: _grid(),
            borderData: _border(),
            alignment: BarChartAlignment.spaceAround,
          ),
        ),
      );

    case 'pyramid':
      final n = d.pyramidLeft.length;
      return _rotated(
        BarChart(
          BarChartData(
            barGroups: [
              for (var i = 0; i < n; i++)
                BarChartGroupData(x: i, barsSpace: 3, barRods: [
                  BarChartRodData(
                    toY: d.pyramidLeft[i].value,
                    width: 14,
                    color: _c(0),
                  ),
                  BarChartRodData(
                    toY: -(i < d.pyramidRight.length
                        ? d.pyramidRight[i].value
                        : 0.0),
                    width: 14,
                    color: _c(4),
                  ),
                ]),
            ],
            titlesData: _titles(
              bottom: _bottomLabels(_namesOf(d.pyramidLeft), reserved: 46),
            ),
            gridData: _grid(),
            borderData: _border(),
            alignment: BarChartAlignment.spaceAround,
          ),
        ),
      );

    case 'treemap': {
      final terrains =
          d.terrainCounts.where((e) => e.label != 'Otros').take(5).toList();
      final climates =
          d.climateCounts.where((e) => e.label != 'Otros').take(4).toList();
      final series = [
        for (var c = 0; c < climates.length; c++)
          [
            for (var t = 0; t < terrains.length; t++)
              d.planets
                  .where((p) =>
                      p.terrainList.contains(terrains[t].label) &&
                      p.climateList.contains(climates[c].label))
                  .length
                  .toDouble(),
          ],
      ];
      return _rotated(
        BarChart(
          BarChartData(
            barGroups: _stackedGroups(
              [for (final t in terrains) t.label],
              series,
              width: 30,
            ),
            titlesData: _titles(
              bottom: _bottomLabels(
                [for (final t in terrains) t.label],
                reserved: 46,
              ),
            ),
            gridData: _grid(),
            borderData: _border(),
            alignment: BarChartAlignment.spaceAround,
          ),
        ),
      );
    }

    case 'sankey': {
      final froms = <String>[];
      for (final f in d.flows) {
        if (!froms.contains(f.from)) froms.add(f.from);
      }
      return _rotated(
        BarChart(
          BarChartData(
            barGroups: [
              for (var i = 0; i < froms.length; i++)
                BarChartGroupData(x: i, barsSpace: 1, barRods: [
                  () {
                    var run = 0.0;
                    final items = <BarChartRodStackItem>[];
                    var s = 0;
                    for (final flow in d.flows) {
                      if (flow.from != froms[i]) continue;
                      items.add(BarChartRodStackItem(
                          run, run + flow.value, _c(s)));
                      run += flow.value;
                      s++;
                    }
                    return BarChartRodData(
                      toY: run,
                      width: 30,
                      color: _c(0),
                      rodStackItems: items,
                    );
                  }(),
                ]),
            ],
            titlesData: _titles(
              bottom: _bottomLabels(froms, reserved: 46),
            ),
            gridData: _grid(),
            borderData: _border(),
            alignment: BarChartAlignment.spaceAround,
          ),
        ),
      );
    }

    case 'sunburst':
      return _sunburst(d);

    case 'gantt': {
      final tasks = d.ganttTasks.take(10).toList();
      return _rotated(
        BarChart(
          BarChartData(
            barGroups: _singleGroups(
              tasks,
              color: _c(4),
              width: 14,
              valueOf: (e) => e.value,
            ),
            titlesData: _titles(
              bottom: _bottomLabels(_namesOf(tasks), reserved: 46),
            ),
            gridData: _grid(),
            borderData: _border(),
            alignment: BarChartAlignment.spaceAround,
          ),
        ),
      );
    }

    case 'heatmap_matrix': {
      final cells = <NameValue>[];
      var maxV = 0.0;
      for (var r = 0; r < d.matrixRows.length; r++) {
        for (var c2 = 0; c2 < d.matrixCols.length; c2++) {
          final v = d.matrixValues[r][c2];
          if (v > maxV) maxV = v;
          cells.add(NameValue('${d.matrixRows[r].substring(0, math.min(3, d.matrixRows[r].length))}·${d.matrixCols[c2].substring(0, math.min(3, d.matrixCols[c2].length))}', v));
        }
      }
      return BarChart(
        BarChartData(
          barGroups: [
            for (var i = 0; i < cells.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: cells[i].value,
                  width: 16,
                  color: Color.lerp(const Color(0xFFE3F2FD),
                      const Color(0xFFD84315), maxV == 0 ? 0 : cells[i].value / maxV)!,
                ),
              ]),
          ],
          titlesData: _titles(
            bottom: _bottomLabels([for (final e in cells) e.label], reserved: 44),
          ),
          gridData: _grid(),
          borderData: _border(),
          alignment: BarChartAlignment.spaceBetween,
        ),
      );
    }

    case 'heatmap_calendar': {
      var maxV = 0.0;
      for (final e in d.calendarCells) {
        if (e.value > maxV) maxV = e.value;
      }
      return BarChart(
        BarChartData(
          barGroups: [
            for (var i = 0; i < d.calendarCells.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: d.calendarCells[i].value,
                  width: 12,
                  color: Color.lerp(const Color(0xFFE8F5E9),
                      const Color(0xFF1B5E20), maxV == 0 ? 0 : d.calendarCells[i].value / maxV)!,
                ),
              ]),
          ],
          titlesData: _titles(
            bottom: _bottomLabels(
              [for (final e in d.calendarCells) e.label],
              reserved: 44,
            ),
          ),
          gridData: _grid(),
          borderData: _border(),
          alignment: BarChartAlignment.spaceBetween,
        ),
      );
    }

    case 'range_area':
      return _lineChart(
        values: const [],
        customSpots: [
          [
            for (var i = 0; i < d.biomeDiameterRange.length; i++)
              FlSpot(i.toDouble(), d.biomeDiameterRange[i].lower),
          ],
          [
            for (var i = 0; i < d.biomeDiameterRange.length; i++)
              FlSpot(i.toDouble(), d.biomeDiameterRange[i].upper),
          ],
        ],
        bottomLabels: d.biomeLabels,
        legend: const ['Mín', 'Máx'],
        fill: const [true, false],
        dashes: const [
          null,
          [6, 5],
        ],
      );

    case 'range_column':
      return BarChart(
        BarChartData(
          barGroups: [
            for (var i = 0; i < d.biomeDiameterRange.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  fromY: d.biomeDiameterRange[i].lower,
                  toY: d.biomeDiameterRange[i].upper,
                  width: 20,
                  color: _c(i),
                ),
              ]),
          ],
          titlesData: _titles(bottom: _bottomLabels(d.biomeLabels)),
          gridData: _grid(),
          borderData: _border(),
          alignment: BarChartAlignment.spaceAround,
        ),
      );

    case 'line_band':
      return _lineChart(
        values: const [],
        customSpots: [
          [
            for (var i = 0; i < d.biomeWaterBand.length; i++)
              FlSpot(i.toDouble(), d.biomeWaterBand[i].center),
          ],
          [
            for (var i = 0; i < d.biomeWaterBand.length; i++)
              FlSpot(i.toDouble(), d.biomeWaterBand[i].upper),
          ],
          [
            for (var i = 0; i < d.biomeWaterBand.length; i++)
              FlSpot(i.toDouble(), d.biomeWaterBand[i].lower),
          ],
        ],
        bottomLabels: d.biomeLabels,
        legend: const ['Media', '+1σ', '-1σ'],
        dashes: const [
          null,
          [5, 4],
          [5, 4],
        ],
        showDots: const [true, false, false],
      );

    case 'stream_graph':
      return _lineChart(
        values: [d.biomeCountValues, d.biomeWaterAvg],
        bottomLabels: d.biomeLabels,
        legend: const ['Nº planetas', 'Agua media'],
        fill: const [true, true],
        curved: const [true, true],
      );

    case 'radial_bar':
      return _radialBar(d);
    case 'gauge':
      return _gauge(d);
    case 'bullet':
      return _bullet(d);

    case 'line_log':
      return _lineChart(
        values: [d.seqPopulationLog],
        bottomLabels: d.seqLabels,
        legend: const ['Población (log10)'],
        leftFmt: (v) => '1e${v.round()}',
        showDots: const [true],
      );

    case 'bar_error': {
      final groups = <BarChartGroupData>[];
      for (var i = 0; i < d.biomeDiameterBox.length; i++) {
        final b = d.biomeDiameterBox[i];
        groups.add(BarChartGroupData(x: i, barsSpace: 4, barRods: [
          BarChartRodData(
            fromY: math.max(0, b.mean - b.std),
            toY: b.mean + b.std,
            width: 16,
            color: _fade(_c(4), 0.45),
          ),
          BarChartRodData(
            toY: b.mean,
            width: 8,
            color: _c(4),
          ),
        ]));
      }
      return BarChart(
        BarChartData(
          barGroups: groups,
          titlesData: _titles(bottom: _bottomLabels(d.biomeLabels)),
          gridData: _grid(),
          borderData: _border(),
          alignment: BarChartAlignment.spaceAround,
        ),
      );
    }

    case 'dumbbell':
      return _rotated(
        BarChart(
          BarChartData(
            barGroups: [
              for (var i = 0; i < d.biomeDiameterRange.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    fromY: d.biomeDiameterRange[i].lower,
                    toY: d.biomeDiameterRange[i].upper,
                    width: 7,
                    color: _c(i),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ]),
            ],
            titlesData: _titles(
              bottom: _bottomLabels(d.biomeLabels, reserved: 46),
            ),
            gridData: _grid(),
            borderData: _border(),
            alignment: BarChartAlignment.spaceAround,
          ),
        ),
      );

    case 'line_annotations':
      return _lineChart(
        values: [d.seqDiameter],
        bottomLabels: d.seqLabels,
        legend: const ['Diámetro'],
        showDots: const [true],
        extra: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: d.seqDiameter[d.annotatedMaxIndex],
            color: const Color(0xFF2E7D32),
            strokeWidth: 1.6,
            dashArray: [4, 4],
            label: HorizontalLineLabel(
              show: true,
              labelResolver: (_) => 'Máx',
              style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
          HorizontalLine(
            y: d.seqDiameter[d.annotatedMinIndex],
            color: const Color(0xFFC62828),
            strokeWidth: 1.6,
            dashArray: [4, 4],
            label: HorizontalLineLabel(
              show: true,
              labelResolver: (_) => 'Mín',
              style: const TextStyle(
                  color: Color(0xFFC62828),
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      );
    default:
      return _flMissing(id);
  }
}

List<String> _namesOf(List<NameValue> items) => [for (final e in items) e.label];

List<String> _shortLabels(List<String> labels) => [
      for (final l in labels)
        l.split(',').first.split(' ').first.length > 11
            ? '${l.substring(0, 10)}…'
            : l.split(',').first.split(' ').first,
    ];

Widget _legendRow(List<String> labels) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < labels.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _c(i),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  labels[i],
                  style: const TextStyle(fontSize: 10, color: Color(0xFF607D8B)),
                ),
              ],
            ),
        ],
      ),
    );

Widget _pie(
  List<NameValue> items, {
  bool donut = false,
  bool percentTitle = false,
  String? kpi,
  bool explodeTop = false,
}) {
  final total = items.fold<double>(0, (s, e) => s + e.value);
  var maxV = 0.0;
  for (final e in items) {
    if (e.value > maxV) maxV = e.value;
  }
  final chart = PieChart(
    PieChartData(
      sectionsSpace: 3,
      centerSpaceRadius: donut ? 56 : 0,
      sections: [
        for (var i = 0; i < items.length; i++)
          PieChartSectionData(
            value: items[i].value,
            color: _c(i),
            title: percentTitle
                ? '${(items[i].value / total * 100).round()}%'
                : (donut ? '' : _shortLabels([items[i].label]).first),
            radius: (explodeTop && items[i].value == maxV) ? 96 : 80,
            showTitle: percentTitle || !donut,
            titleStyle: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            borderSide: (explodeTop && items[i].value == maxV)
                ? const BorderSide(color: Colors.white, width: 3)
                : null,
          ),
      ],
    ),
  );
  if (kpi == null) return chart;
  return Stack(
    alignment: Alignment.center,
    children: [
      chart,
      Text(
        kpi,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF37474F),
        ),
      ),
    ],
  );
}

Widget _multiRing(ChartsData d) {
  Widget ring(List<NameValue> items, double hole) => PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: hole,
          sections: [
            for (var i = 0; i < items.length; i++)
              PieChartSectionData(
                value: items[i].value,
                color: _c(i),
                showTitle: false,
              ),
          ],
        ),
      );

  return Stack(
    alignment: Alignment.center,
    children: [
      Positioned.fill(child: ring(d.climateCounts, 62)),
      FractionallySizedBox(
        widthFactor: 0.6,
        heightFactor: 0.6,
        child: ring(d.biomeCounts, 40),
      ),
    ],
  );
}

Widget _polar(ChartsData d) {
  final items = d.biomeCounts;
  var maxV = 0.0;
  for (final e in items) {
    if (e.value > maxV) maxV = e.value;
  }
  return PieChart(
    PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 18,
      sections: [
        for (var i = 0; i < items.length; i++)
          PieChartSectionData(
            value: items[i].value,
            color: _c(i),
            radius: 48 + (maxV == 0 ? 0 : items[i].value / maxV * 38),
            showTitle: true,
            title: _shortLabels([items[i].label]).first,
            titleStyle: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w700),
          ),
      ],
    ),
  );
}

Widget _spark({
  required List<double> values,
  bool fill = false,
  bool bars = false,
}) {
  const h = 64.0;
  final hide = FlTitlesData(
    show: false,
    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );
  if (bars) {
    return SizedBox(
      height: h,
      child: BarChart(
        BarChartData(
          barGroups: _singleGroups(
            [
              for (var i = 0; i < values.length; i++)
                NameValue('$i', values[i]),
            ],
            width: 12,
          ),
          titlesData: hide,
          gridData: const FlGridData(show: false),
          borderData:
              FlBorderData(show: false, border: Border.all(color: Colors.transparent)),
          alignment: BarChartAlignment.spaceAround,
        ),
      ),
    );
  }
  return SizedBox(
    height: h,
    child: LineChart(
      LineChartData(
        minX: 0,
        maxX: values.length - 1.0,
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            color: fill ? _c(2) : _c(0),
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: fill, color: _fade(_c(2), 0.3)),
          ),
        ],
        titlesData: hide,
        gridData: const FlGridData(show: false),
        borderData:
            FlBorderData(show: false, border: Border.all(color: Colors.transparent)),
      ),
    ),
  );
}

Widget _scatter({
  required List<ScatterPt> pts,
  required String xLabel,
  required String yLabel,
  bool bubble = false,
  bool logSized = false,
}) {
  if (pts.isEmpty) return const SizedBox.shrink();
  var minX = pts.first.x, maxX = pts.first.x, minY = pts.first.y, maxY = pts.first.y;
  for (final p in pts) {
    if (p.x < minX) minX = p.x;
    if (p.x > maxX) maxX = p.x;
    if (p.y < minY) minY = p.y;
    if (p.y > maxY) maxY = p.y;
  }
  final padX = (maxX - minX) * 0.06 + 1;
  final padY = (maxY - minY) * 0.06 + 1;
  return ScatterChart(
    ScatterChartData(
      minX: minX - padX,
      maxX: maxX + padX,
      minY: minY - padY,
      maxY: maxY + padY,
      scatterSpots: [
        for (final p in pts)
          ScatterSpot(
            p.x,
            p.y,
            dotPainter: FlDotCirclePainter(
              radius: bubble ? (3 + p.size / 9) : 5,
              color: _fade(_c(0), bubble ? 0.55 : 0.8),
              strokeWidth: bubble ? 1 : 0,
              strokeColor: _c(0),
            ),
          ),
      ],
      titlesData: _titles(
        bottom: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (v, _) => Text(
              _fmt(v),
              style: const TextStyle(fontSize: 9, color: Color(0xFF90A4AE)),
            ),
          ),
        ),
        left: _leftValues(),
      ),
      gridData: _grid(),
      borderData: _border(),
    ),
  );
}

Widget _regression(ChartsData d) {
  final pts = d.scatterDiameterPopulation;
  if (pts.length < 2) return const SizedBox.shrink();
  double ly(ScatterPt p) => p.y <= 0 ? 0 : math.log(p.y) / math.ln10;
  var minX = pts.first.x, maxX = pts.first.x;
  var minY = ly(pts.first), maxY = ly(pts.first);
  for (final p in pts) {
    if (p.x < minX) minX = p.x;
    if (p.x > maxX) maxX = p.x;
    final y = ly(p);
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
  }
  final padX = (maxX - minX) * 0.06 + 1;
  final padY = (maxY - minY) * 0.06 + 1;
  final x0 = minX - padX;
  final x1 = maxX + padX;
  double fit(double x) {
    final y = d.regSlope * x + d.regIntercept;
    if (y < minY - padY) return minY - padY;
    if (y > maxY + padY) return maxY + padY;
    return y;
  }

  return LineChart(
    LineChartData(
      minX: x0,
      maxX: x1,
      minY: minY - padY,
      maxY: maxY + padY,
      lineBarsData: [
        LineChartBarData(
          spots: [for (final p in pts) FlSpot(p.x, ly(p))],
          color: Colors.transparent,
          barWidth: 0,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, _, _, _) => FlDotCirclePainter(
              radius: 5,
              color: _fade(_c(0), 0.75),
              strokeWidth: 0,
            ),
          ),
        ),
        LineChartBarData(
          spots: [FlSpot(x0, fit(x0)), FlSpot(x1, fit(x1))],
          color: _c(1),
          barWidth: 2.4,
          dashArray: const [7, 5],
          dotData: const FlDotData(show: false),
        ),
      ],
      titlesData: _titles(
        bottom: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (v, _) => Text(
              _fmt(v),
              style: const TextStyle(fontSize: 9, color: Color(0xFF90A4AE)),
            ),
          ),
        ),
        left: _leftValues(),
      ),
      gridData: _grid(),
      borderData: _border(),
    ),
  );
}

Widget _strip(ChartsData d) {
  final groups = d.stripGroups;
  final spots = <ScatterSpot>[];
  for (var g = 0; g < groups.length; g++) {
    final values = groups[g].values;
    for (var i = 0; i < values.length; i++) {
      final jitter = (((i * 7 + g * 13) % 7) - 3) * 0.1;
      spots.add(ScatterSpot(
        g + jitter,
        values[i],
        dotPainter: FlDotCirclePainter(
          radius: 5,
          color: _fade(_c(g), 0.8),
          strokeWidth: 0,
        ),
      ));
    }
  }
  return ScatterChart(
    ScatterChartData(
      minX: -0.5,
      maxX: groups.length - 0.5,
      scatterSpots: spots,
      titlesData: _titles(bottom: _bottomLabels([for (final g in groups) g.label])),
      gridData: _grid(),
      borderData: _border(),
    ),
  );
}

Widget _matrixBars({required List<String> labels, required List<double> values}) =>
    BarChart(
      BarChartData(
        barGroups: [
          for (var i = 0; i < labels.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: values[i],
                width: 16,
                color: values[i] >= 0
                    ? Color.lerp(Colors.white, const Color(0xFF1565C0),
                        values[i].clamp(0, 1).toDouble())!
                    : Color.lerp(Colors.white, const Color(0xFFC62828),
                        (-values[i]).clamp(0, 1).toDouble())!,
              ),
            ]),
        ],
        minY: -1,
        maxY: 1,
        titlesData:
            _titles(bottom: _bottomLabels(_shortLabels(labels), reserved: 46)),
        gridData: _grid(),
        borderData: _border(),
        alignment: BarChartAlignment.spaceBetween,
      ),
    );

Widget _radar(ChartsData d, {bool multi = false}) {
  final datasets = multi ? d.multiRadar : [d.radarFocus, d.radarAvg];
  return RadarChart(
    RadarChartData(
      dataSets: [
        for (var s = 0; s < datasets.length; s++)
          RadarDataSet(
            dataEntries: [
              for (final v in datasets[s])
                RadarEntry(value: v.clamp(0, 100).toDouble()),
            ],
            fillColor: multi
                ? _fade(_c(s), 0.18)
                : (s == 0 ? _fade(_c(0), 0.3) : Colors.transparent),
            borderColor:
                multi ? _c(s) : (s == 0 ? _c(0) : const Color(0xFF90A4AE)),
            borderWidth: 2,
            entryRadius: 3,
          ),
      ],
      getTitle: (index, angle) => RadarChartTitle(text: d.radarTitles[index]),
      titlePositionPercentageOffset: 0.14,
      titleTextStyle: const TextStyle(
          fontSize: 10, color: Color(0xFF546E7A), fontWeight: FontWeight.w600),
      radarBorderData: const BorderSide(color: Color(0xFFB0BEC5), width: 2),
      gridBorderData: const BorderSide(color: Color(0xFFCFD8DC), width: 1),
    ),
  );
}

Widget _candles(ChartsData d, {required bool outline}) {
  final groups = <BarChartGroupData>[];
  for (var i = 0; i < d.biomeOhlc.length; i++) {
    final c = d.biomeOhlc[i];
    final up = c.close >= c.open;
    groups.add(BarChartGroupData(x: i, groupVertically: true, barRods: [
      BarChartRodData(
        fromY: c.low,
        toY: c.high,
        width: outline ? 3 : 4,
        color: const Color(0xFF78909C),
        borderRadius: BorderRadius.circular(2),
      ),
      BarChartRodData(
        fromY: math.min(c.open, c.close),
        toY: math.max(c.open, c.close),
        width: outline ? 10 : 17,
        color: outline
            ? Colors.transparent
            : (up ? const Color(0xFF43A047) : const Color(0xFFE53935)),
        borderRadius: BorderRadius.circular(2),
        borderSide: outline
            ? BorderSide(
                color: up ? const Color(0xFF43A047) : const Color(0xFFE53935),
                width: 2,
              )
            : BorderSide.none,
      ),
    ]));
  }
  return BarChart(
    BarChartData(
      barGroups: groups,
      titlesData: _titles(bottom: _bottomLabels(d.biomeLabels)),
      gridData: _grid(),
      borderData: _border(),
      alignment: BarChartAlignment.spaceAround,
    ),
  );
}

Widget _histogram(ChartsData d) {
  final bins = ChartsData.histogramBins(d.diameterAll, 6);
  return BarChart(
    BarChartData(
      barGroups: _singleGroups(bins, width: 30, color: _c(4)),
      titlesData: _titles(
        bottom: _bottomLabels([for (final b in bins) b.label], reserved: 34),
      ),
      gridData: _grid(),
      borderData: _border(),
      alignment: BarChartAlignment.spaceBetween,
    ),
  );
}

Widget _boxPlot(ChartsData d) {
  final groups = <BarChartGroupData>[];
  for (var i = 0; i < d.biomeDiameterBox.length; i++) {
    final b = d.biomeDiameterBox[i];
    final span = b.max - b.min;
    groups.add(BarChartGroupData(x: i, groupVertically: true, barRods: [
      BarChartRodData(
        fromY: b.min,
        toY: b.max,
        width: 4,
        color: const Color(0xFF90A4AE),
      ),
      BarChartRodData(
        fromY: b.q1,
        toY: b.q3,
        width: 17,
        color: _c(0),
        borderRadius: BorderRadius.circular(3),
      ),
      BarChartRodData(
        fromY: b.median - span * 0.015,
        toY: b.median + span * 0.015,
        width: 17,
        color: const Color(0xFF263238),
      ),
    ]));
  }
  return BarChart(
    BarChartData(
      barGroups: groups,
      titlesData: _titles(bottom: _bottomLabels(d.biomeLabels)),
      gridData: _grid(),
      borderData: _border(),
      alignment: BarChartAlignment.spaceAround,
    ),
  );
}

Widget _waterfall(ChartsData d, {required bool percent}) {
  final steps = d.terrainCounts.where((e) => e.label != 'Otros').take(6).toList();
  final sum = steps.fold<double>(0, (s, e) => s + e.value);
  final factor = percent && sum > 0 ? 100 / sum : 1.0;
  final groups = <BarChartGroupData>[];
  var run = 0.0;
  for (var i = 0; i < steps.length; i++) {
    final v = steps[i].value * factor;
    groups.add(BarChartGroupData(x: i, groupVertically: true, barRods: [
      BarChartRodData(
        fromY: run,
        toY: run + v,
        width: 22,
        color: _c(i),
        borderRadius: BorderRadius.circular(3),
      ),
    ]));
    run += v;
  }
  groups.add(BarChartGroupData(x: steps.length, groupVertically: true, barRods: [
    BarChartRodData(
      fromY: 0,
      toY: run,
      width: 22,
      color: const Color(0xFF37474F),
      borderRadius: BorderRadius.circular(3),
    ),
  ]));
  return BarChart(
    BarChartData(
      barGroups: groups,
      titlesData: _titles(
        bottom: _bottomLabels([
          ...[for (final s in steps) s.label],
          'Total',
        ], reserved: 44),
      ),
      gridData: _grid(),
      borderData: _border(),
      alignment: BarChartAlignment.spaceAround,
    ),
  );
}

/// Sunburst aproximado con dos tartas concéntricas: la exterior recorre
/// la jerarquía clima → terreno y la interior resume cada clima.
Widget _sunburst(ChartsData d) {
  final outerSections = <PieChartSectionData>[];
  final innerValues = <double>[];
  final innerLabels = <String>[];
  for (var p = 0; p < d.hierarchyClimate.length; p++) {
    final node = d.hierarchyClimate[p];
    var sum = 0.0;
    for (var j = 0; j < node.children.length; j++) {
      final child = node.children[j];
      sum += child.value;
      outerSections.add(PieChartSectionData(
        value: child.value,
        color: Color.lerp(_c(p), Colors.white, 0.15 * (j % 4))!,
        showTitle: false,
      ));
    }
    if (sum > 0) {
      innerValues.add(sum);
      innerLabels.add(_shortLabels([node.label]).first);
    }
  }
  if (outerSections.isEmpty || innerValues.isEmpty) {
    return _pie(d.climateCounts, donut: true);
  }
  return Stack(
    alignment: Alignment.center,
    children: [
      Positioned.fill(
        child: PieChart(
          PieChartData(sectionsSpace: 2, sections: outerSections),
        ),
      ),
      FractionallySizedBox(
        widthFactor: 0.56,
        heightFactor: 0.56,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 26,
            sections: [
              for (var i = 0; i < innerValues.length; i++)
                PieChartSectionData(
                  value: innerValues[i],
                  color: _c(i),
                  title: innerLabels[i],
                  showTitle: true,
                  titleStyle: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _radialBar(ChartsData d) {
  final items = d.biomeCounts;
  var maxV = 0.0;
  for (final e in items) {
    if (e.value > maxV) maxV = e.value;
  }
  return PieChart(
    PieChartData(
      sectionsSpace: 4,
      centerSpaceRadius: 54,
      sections: [
        for (var i = 0; i < items.length; i++)
          PieChartSectionData(
            value: items[i].value,
            color: _c(i),
            radius: 62 + (maxV == 0 ? 0 : items[i].value / maxV * 32),
            showTitle: false,
          ),
      ],
    ),
  );
}

Widget _gauge(ChartsData d) {
  final v = d.gaugeValue.clamp(0, 100).toDouble();
  return Stack(
    alignment: Alignment.center,
    children: [
      PieChart(
        PieChartData(
          sectionsSpace: 1,
          centerSpaceRadius: 64,
          sections: [
            PieChartSectionData(
              value: v,
              color: const Color(0xFF2FC4C0),
              showTitle: false,
              radius: 84,
            ),
            PieChartSectionData(
              value: 100 - v,
              color: const Color(0xFFECEFF1),
              showTitle: false,
              radius: 84,
            ),
          ],
        ),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${v.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF263238),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              d.gaugeMetric,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Color(0xFF78909C)),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _bullet(ChartsData d) {
  final r = d.bulletRanges;
  return _rotated(
    BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, groupVertically: true, barRods: [
            BarChartRodData(
              fromY: 0,
              toY: r[0],
              width: 34,
              color: const Color(0xFFCFD8DC),
            ),
            BarChartRodData(
              fromY: r[0],
              toY: r[1],
              width: 34,
              color: const Color(0xFF90A4AE),
            ),
            BarChartRodData(
              fromY: r[1],
              toY: r[2],
              width: 34,
              color: const Color(0xFF607D8B),
            ),
            BarChartRodData(
              fromY: 0,
              toY: d.bulletValue,
              width: 15,
              color: _c(0),
              borderRadius: BorderRadius.circular(3),
            ),
          ]),
        ],
        titlesData: _titles(
          bottom: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (v, _) => Text(
                _fmt(v),
                style: const TextStyle(fontSize: 9, color: Color(0xFF90A4AE)),
              ),
            ),
          ),
        ),
        gridData: _grid(),
        borderData: _border(),
        alignment: BarChartAlignment.center,
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: d.bulletTarget,
            color: const Color(0xFFD84315),
            strokeWidth: 2,
            dashArray: [5, 4],
          ),
        ]),
      ),
    ),
  );
}
