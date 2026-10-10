import 'dart:math' as math;

import 'package:drafter/drafter.dart';
import 'package:flutter/material.dart';

import 'charts_data.dart';

/// Galería de las 63 gráficas del catálogo renderizadas con drafter.
/// Donde drafter no tiene un tipo nativo se usa una variante del mismo
/// widget (siempre drafter, sin CustomPaint externo).
Widget buildDrafterChart(String id, ChartsData d) => Builder(
      builder: (context) => DrafterTheme.brightness(
        dark: Theme.of(context).brightness == Brightness.dark,
        child: _dr(id, d),
      ),
    );

final List<Color> _dp = [
  DrafterColors.blue,
  DrafterColors.teal,
  DrafterColors.violet,
  DrafterColors.amber,
  DrafterColors.green,
  DrafterColors.coral,
  DrafterColors.pink,
  DrafterColors.indigo,
];

Color _dc(int i) => _dp[i % _dp.length];

List<ChartPoint> _pts(List<String> labels, List<double> values) => [
      for (var i = 0; i < values.length; i++)
        ChartPoint(i < labels.length ? labels[i] : '$i', values[i]),
    ];

List<String> _names(List<NameValue> items) => [for (final e in items) e.label];

List<double> _values(List<NameValue> items) => [for (final e in items) e.value];

/// Rota una gráfica vertical 90° para lograr barras horizontales
/// (drafter dibuja barras verticales de forma nativa). Usa un cuadrado
/// inscrito para que la caja rotada siempre quepa sin overflow.
Widget _drRotated(Widget child) => LayoutBuilder(
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

Widget _drMissing(String id) => Center(child: Text('Sin implementar: $id'));

String _lbl(String s) {
  final t = s.split(',').first.split(' ').first;
  return t.length > 11 ? '${t.substring(0, 10)}…' : t;
}

List<PieSlice> _slices(
  List<NameValue> items, {
  bool percent = false,
  bool starTop = false,
}) {
  final total = items.fold<double>(0, (s, e) => s + e.value);
  var maxV = 0.0;
  for (final e in items) {
    if (e.value > maxV) maxV = e.value;
  }
  return [
    for (var i = 0; i < items.length; i++)
      PieSlice(
        value: items[i].value,
        color: _dc(i),
        label: percent
            ? '${(items[i].value / (total == 0 ? 1 : total) * 100).round()}%'
            : (starTop && items[i].value == maxV
                ? '★ ${_lbl(items[i].label)}'
                : _lbl(items[i].label)),
      ),
  ];
}

Map<String, double> _radarMap(List<String> titles, List<double> values) => {
      for (var i = 0; i < titles.length && i < values.length; i++)
        titles[i]: values[i],
    };

List<Candle> _candles(ChartsData d) => [
      for (final b in d.biomeOhlc)
        Candle(
            label: b.label,
            open: b.open,
            high: b.high,
            low: b.low,
            close: b.close),
    ];

Widget _waterfallDr(ChartsData d, {required bool percent}) {
  final steps =
      d.terrainCounts.where((e) => e.label != 'Otros').take(6).toList();
  final sum = steps.fold<double>(0, (s, e) => s + e.value);
  return WaterfallChart(
    steps: [
      for (final e in steps)
        WaterfallStep(
            e.label, percent ? (sum == 0 ? 0 : e.value / sum * 100) : e.value),
    ],
    initialValue: 0,
    totalLabel: 'Total',
  );
}

Widget _dr(String id, ChartsData d) {
  switch (id) {
    // ------------------------------------------------------------ líneas
    case 'line_simple':
    case 'line_smooth':
      return LineChart(points: _pts(d.seqLabels, d.seqDiameter));
    case 'line_multi':
      return GroupedLineChart(
        categories: d.seqLabels,
        series: [
          ChartSeries(
              name: 'Población',
              color: _dc(0),
              values: ChartsData.normalize(d.seqPopulation)),
          ChartSeries(name: 'Agua', color: _dc(1), values: d.seqWater),
          ChartSeries(
              name: 'Rotación',
              color: _dc(2),
              values: ChartsData.normalize(d.seqRotation)),
        ],
      );
    case 'line_markers':
      return GroupedLineChart(
        categories: d.seqLabels,
        series: [
          ChartSeries(name: 'Diámetro', color: _dc(0), values: d.seqDiameter),
        ],
      );
    case 'line_dashed':
      return ScatterPlot(
        points: [
          for (var i = 0; i < d.seqDiameter.length; i++)
            ScatterPoint(
                x: i.toDouble(), y: d.seqDiameter[i], color: _dc(0)),
        ],
      );
    case 'line_gradient':
      return AreaChart(points: _pts(d.seqLabels, d.seqDiameter), color: _dc(0));
    case 'step_line':
      return StepLineChart(points: _pts(d.seqLabels, d.seqDiameter));
    case 'line_log':
      return LineChart(points: _pts(d.seqLabels, d.seqPopulationLog));

    // ------------------------------------------------------------ barras
    case 'bar_vertical':
      return SimpleBarChart(
        bars: [
          for (final e in d.topDiameter)
            BarItem(e.label, e.value, color: _dc(0)),
        ],
      );
    case 'bar_horizontal':
      return _drRotated(
        SimpleBarChart(
          bars: [
            for (final e in d.topPopulation)
              BarItem(e.label, e.value, color: _dc(1)),
          ],
        ),
      );
    case 'bar_grouped': {
      final maxMean = d.biomeDiameterBox
          .fold<double>(0, (a, b) => a > b.mean ? a : b.mean);
      return GroupedBarChart(
        categories: d.biomeLabels,
        series: [
          ChartSeries(
            name: 'Diámetro',
            color: _dc(0),
            values: [
              for (final b in d.biomeDiameterBox)
                maxMean == 0 ? 0 : b.mean / maxMean * 100,
            ],
          ),
          ChartSeries(name: 'Agua %', color: _dc(1), values: d.biomeWaterAvg),
        ],
      );
    }
    case 'bar_stacked': {
      final series = <ChartSeries>[];
      for (var c = 0; c < d.stackClimates.length; c++) {
        series.add(ChartSeries(
          name: d.stackClimates[c],
          color: _dc(c),
          values: [
            for (var b = 0; b < d.stackBiomes.length; b++)
              d.stackValues[c][b],
          ],
        ));
      }
      return StackedBarChart(categories: d.stackBiomes, series: series);
    }
    case 'bar_stacked_100': {
      final series = <ChartSeries>[];
      for (var c2 = 0; c2 < d.matrixCols.length; c2++) {
        final col = <double>[];
        for (var r = 0; r < d.matrixRows.length; r++) {
          final row = d.matrixValues[r];
          final total = row.fold<double>(0, (a, b) => a + b);
          col.add(total == 0 ? 0 : row[c2] / total * 100);
        }
        series.add(ChartSeries(name: d.matrixCols[c2], color: _dc(c2), values: col));
      }
      return StackedBarChart(categories: d.matrixRows, series: series);
    }
    case 'bar_diverging':
      return GroupedBarChart(
        categories: _names(d.divergingDiameter),
        series: [
          ChartSeries(
              name: 'Δ diámetro', color: _dc(1), values: _values(d.divergingDiameter)),
        ],
      );
    case 'bar_stacked_total': {
      final series = <ChartSeries>[];
      for (var c = 0; c < d.stackClimates.length; c++) {
        series.add(ChartSeries(
          name: d.stackClimates[c],
          color: _dc(c),
          values: [
            for (var b = 0; b < d.stackBiomes.length; b++) d.stackValues[c][b],
          ],
        ));
      }
      return StackedBarChart(categories: d.stackBiomes, series: series);
    }
    case 'combo_bar_line':
      return GroupedBarChart(
        categories: d.seqLabels,
        series: [
          ChartSeries(
              name: 'Diámetro', color: _dc(0), values: d.seqDiameter),
          ChartSeries(
              name: 'Agua media acum.',
              color: _dc(3),
              values: d.waterCumAvg),
        ],
      );
    case 'funnel':
      return FunnelChart(
        stages: [
          for (var i = 0; i < d.climateCounts.length; i++)
            FunnelStage(
              label: d.climateCounts[i].label,
              value: d.climateCounts[i].value,
              color: _dc(i),
            ),
        ],
      );
    case 'gantt':
      return GanttChart(
        tasks: [
          for (final e in d.ganttTasks.take(10))
            GanttTask(
                name: e.label,
                startMonth: 0,
                duration: e.value.round(),
                color: _dc(4)),
        ],
      );

    // -------------------------------------------------------------- áreas
    case 'area_simple':
      return AreaChart(points: _pts(d.seqLabels, d.seqDiameter), color: _dc(2));
    case 'area_gradient':
      return AreaChart(points: _pts(d.seqLabels, d.seqDiameter), color: _dc(1));
    case 'step_area':
      return AreaChart(points: _pts(d.seqLabels, d.seqDiameter), color: _dc(5));
    case 'area_stacked':
      return StreamGraphChart(
        categories: d.biomeLabels,
        series: [
          ChartSeries(name: 'Agua > 50%', color: _dc(0), values: d.waterRich),
          ChartSeries(name: 'Agua <= 50%', color: _dc(3), values: d.waterPoor),
        ],
      );
    case 'stream_graph':
      return StreamGraphChart(
        categories: d.biomeLabels,
        series: [
          ChartSeries(name: 'Nº planetas', color: _dc(0), values: d.biomeCountValues),
          ChartSeries(name: 'Agua media', color: _dc(1), values: d.biomeWaterAvg),
        ],
      );

    // ------------------------------------------------------------- tartas
    case 'pie_basic':
      return PieChart(slices: _slices(d.climateCounts));
    case 'pie_percent':
      return PieChart(slices: _slices(d.climateCounts, percent: true));
    case 'pie_exploded':
      return PieChart(slices: _slices(d.climateCounts, starTop: true));
    case 'donut_basic':
      return DonutChart(slices: _slices(d.climateCounts));
    case 'donut_kpi':
      return Builder(
        builder: (context) => Stack(
          alignment: Alignment.center,
          children: [
            DonutChart(slices: _slices(d.climateCounts)),
            Text(
              '${d.totalPlanets}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      );
    case 'donut_multi_ring':
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: DonutChart(slices: _slices(d.climateCounts))),
          FractionallySizedBox(
            widthFactor: 0.55,
            heightFactor: 0.55,
            child: DonutChart(slices: _slices(d.biomeCounts)),
          ),
        ],
      );
    case 'polar_area':
      return PolarAreaChart(
        slices: [
          for (var i = 0; i < d.biomeCounts.length; i++)
            PolarSlice(
                label: _lbl(d.biomeCounts[i].label),
                value: d.biomeCounts[i].value,
                color: _dc(i)),
        ],
      );
    case 'radial_bar':
      return PolarAreaChart(
        slices: [
          for (var i = 0; i < d.biomeCounts.length; i++)
            PolarSlice(
                label: _lbl(d.biomeCounts[i].label),
                value: d.biomeCounts[i].value,
                color: _dc(i + 2)),
        ],
      );

    // ----------------------------------------------------------- dispersión
    case 'scatter_basic':
      return ScatterPlot(
        points: [
          for (final p in d.scatterDiameterPopulation)
            ScatterPoint(x: p.x, y: p.y, color: _dc(0)),
        ],
      );
    case 'scatter_bubble':
      return BubbleChart(
        series: [
          [
            for (final p in d.scatterDiameterPopulation)
              BubbleData(x: p.x, y: p.y, size: p.size + 1, color: _dc(1)),
          ],
        ],
      );
    case 'bubble_log':
      return BubbleChart(
        series: [
          [
            for (final p in d.scatterBubble)
              BubbleData(x: p.x, y: p.y, size: p.size + 1, color: _dc(2)),
          ],
        ],
      );
    case 'scatter_regression': {
      final pts = d.scatterDiameterPopulation;
      double ly(double y) => y <= 0 ? 0 : math.log(y) / math.ln10;
      var minX = pts.isEmpty ? 0.0 : pts.first.x;
      var maxX = minX;
      for (final p in pts) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
      }
      return ScatterPlot(
        points: [
          for (final p in pts) ScatterPoint(x: p.x, y: ly(p.y), color: _dc(0)),
          for (var i = 0; i <= 20; i++)
            ScatterPoint(
              x: minX + (maxX - minX) * i / 20,
              y: d.regSlope * (minX + (maxX - minX) * i / 20) +
                  d.regIntercept,
              color: _dc(3),
            ),
        ],
      );
    }
    case 'strip_plot': {
      final points = <ScatterPoint>[];
      for (var g = 0; g < d.stripGroups.length; g++) {
        final values = d.stripGroups[g].values;
        for (var i = 0; i < values.length; i++) {
          final jitter = (((i * 7 + g * 13) % 7) - 3) * 0.1;
          points.add(ScatterPoint(
              x: g + jitter, y: values[i], color: _dc(g)));
        }
      }
      return ScatterPlot(points: points);
    }
    case 'line_annotations': {
      final maxI = d.annotatedMaxIndex;
      final minI = d.annotatedMinIndex;
      return ScatterPlot(
        points: [
          for (var i = 0; i < d.seqDiameter.length; i++)
            ScatterPoint(
              x: i.toDouble(),
              y: d.seqDiameter[i],
              color: (i == maxI || i == minI) ? _dc(5) : const Color(0xFFB0BEC5),
            ),
        ],
      );
    }

    // --------------------------------------------------------------- radar
    case 'radar_basic':
      return RadarChart(
        series: [
          RadarSeries(color: _dc(0), values: _radarMap(d.radarTitles, d.radarFocus)),
          RadarSeries(
              color: const Color(0xFF90A4AE), values: _radarMap(d.radarTitles, d.radarAvg)),
        ],
      );
    case 'radar_circle':
      return RadarChart(
        series: [
          RadarSeries(color: _dc(2), values: _radarMap(d.radarTitles, d.radarFocus)),
          RadarSeries(color: _dc(5), values: _radarMap(d.radarTitles, d.radarAvg)),
        ],
      );
    case 'radar_multi':
      return RadarChart(
        series: [
          for (var s = 0; s < d.multiRadar.length; s++)
            RadarSeries(
              color: _dc(s),
              values: _radarMap(d.radarTitles, d.multiRadar[s]),
            ),
        ],
      );

    // ---------------------------------------------------------- sparklines
    case 'spark_line':
      return SizedBox(
          height: 64, child: LineChart.values(values: d.seqDiameter));
    case 'spark_area':
      return SizedBox(
          height: 64,
          child: AreaChart.values(values: d.seqPopulationLog, color: _dc(2)));
    case 'spark_bar':
      return SizedBox(
          height: 64,
          child: SimpleBarChart.values(values: d.seqWater.toList()));

    // -------------------------------------------------------- avanzadas puras
    case 'candlestick':
      return CandlestickChart(candles: _candles(d));
    case 'ohlc':
      return CandlestickChart(
        candles: _candles(d),
        movingAverages: [MovingAverage(period: 3, color: _dc(3))],
      );
    case 'histogram':
      return Histogram(values: d.diameterAll, binCount: 6);
    case 'box_plot':
      return BoxPlotChart(groups: [
        for (final b in d.biomeDiameterBox)
          BoxGroup(
            label: b.label,
            min: b.min,
            q1: b.q1,
            median: b.median,
            q3: b.q3,
            max: b.max,
            color: _dc(0),
          ),
      ]);
    case 'dumbbell':
      return BoxPlotChart(groups: [
        for (final b in d.biomeDiameterRange)
          BoxGroup(
            label: b.label,
            min: b.lower,
            q1: b.center,
            median: b.center,
            q3: b.center,
            max: b.upper,
            color: _dc(4),
          ),
      ]);
    case 'bar_error':
      return BoxPlotChart(groups: [
        for (final b in d.biomeDiameterBox)
          BoxGroup(
            label: b.label,
            min: math.max(0, b.mean - b.std),
            q1: b.mean,
            median: b.mean,
            q3: b.mean,
            max: b.mean + b.std,
            color: _dc(3),
          ),
      ]);
    case 'waterfall':
      return _waterfallDr(d, percent: false);
    case 'waterfall_percent':
      return _waterfallDr(d, percent: true);

    case 'pyramid':
      return GroupedBarChart(
        categories: _names(d.pyramidLeft),
        series: [
          ChartSeries(name: 'Nº planetas', color: _dc(0), values: _values(d.pyramidLeft)),
          ChartSeries(
            name: 'Agua %',
            color: _dc(1),
            values: [
              for (var i = 0; i < d.pyramidLeft.length; i++)
                -(i < d.pyramidRight.length ? d.pyramidRight[i].value : 0.0),
            ],
          ),
        ],
      );

    case 'treemap': {
      final items = <TreemapItem>[];
      var idx = 0;
      for (final node in d.hierarchyClimate) {
        for (final child in node.children) {
          items.add(TreemapItem(
            label: '${_lbl(node.label)}·${_lbl(child.label)}',
            value: child.value,
            color: _dc(idx++),
          ));
        }
      }
      return TreemapChart(items: items);
    }

    case 'sunburst':
      return SunburstChart(
        roots: [
          for (var p = 0; p < d.hierarchyClimate.length; p++)
            SunburstNode(
              label: d.hierarchyClimate[p].label,
              value: d.hierarchyClimate[p].value,
              color: _dc(p),
              children: [
                for (final child in d.hierarchyClimate[p].children)
                  SunburstNode(
                      label: child.label,
                      value: child.value,
                      color: _dc(p)),
              ],
            ),
        ],
      );

    case 'sankey': {
      final froms = <String>[];
      final tos = <String>[];
      for (final f in d.flows) {
        if (!froms.contains(f.from)) froms.add(f.from);
        if (!tos.contains(f.to)) tos.add(f.to);
      }
      return SankeyChart(
        nodes: [
          for (var i = 0; i < froms.length; i++)
            SankeyNode(
                id: froms[i],
                label: froms[i],
                column: 0,
                color: _dc(i)),
          for (var i = 0; i < tos.length; i++)
            SankeyNode(
                id: 't$i',
                label: tos[i],
                column: 1,
                color: _dc(i + 3)),
        ],
        links: [
          for (final f in d.flows)
            SankeyLink(from: f.from, to: 't${tos.indexOf(f.to)}', value: f.value),
        ],
      );
    }

    case 'heatmap_matrix': {
      final start = DateTime(2026, 1, 1);
      final cells = <ContributionData>[];
      var idx = 0;
      for (var r = 0; r < d.matrixRows.length; r++) {
        for (var c2 = 0; c2 < d.matrixCols.length; c2++) {
          cells.add(ContributionData(
            date: start.add(Duration(days: idx++)),
            count: d.matrixValues[r][c2].round(),
          ));
        }
      }
      return Heatmap(contributions: cells);
    }
    case 'heatmap_calendar': {
      final start = DateTime(2026, 1, 1);
      return Heatmap(contributions: [
        for (var i = 0; i < d.calendarCells.length; i++)
          ContributionData(
            date: start.add(Duration(days: i)),
            count: d.calendarCells[i].value.round(),
          ),
      ]);
    }
    case 'correlation_matrix': {
      final start = DateTime(2026, 1, 1);
      final cells = <ContributionData>[];
      var idx = 0;
      for (var i = 0; i < d.corrLabels.length; i++) {
        for (var j = i + 1; j < d.corrLabels.length; j++) {
          cells.add(ContributionData(
            date: start.add(Duration(days: idx++)),
            count: (d.corrMatrix[i][j] * 100).round(),
          ));
        }
      }
      return Heatmap(contributions: cells);
    }

    case 'range_area':
    case 'line_band':
      return GroupedLineChart(
        categories: d.biomeLabels,
        series: [
          ChartSeries(name: 'Media', color: _dc(0), values: [
            for (final b in d.biomeWaterBand) b.center,
          ]),
          ChartSeries(name: 'Superior', color: _dc(1), values: [
            for (final b in d.biomeWaterBand) b.upper,
          ]),
          ChartSeries(name: 'Inferior', color: _dc(2), values: [
            for (final b in d.biomeWaterBand) b.lower,
          ]),
        ],
      );
    case 'range_column':
      return CandlestickChart(
        candles: [
          for (final b in d.biomeDiameterRange)
            Candle(
              label: b.label,
              open: b.lower,
              high: b.upper,
              low: b.lower,
              close: b.upper,
            ),
        ],
      );

    case 'gauge':
      return GaugeChart(
        value: d.gaugeValue.clamp(0, 100).toDouble(),
        min: 0,
        max: 100,
        label: d.gaugeMetric,
        color: _dc(1),
      );
    case 'bullet':
      return BulletChart(
        metrics: [
          BulletMetric(
            label: d.focus.name,
            value: d.bulletValue,
            target: d.bulletTarget,
            ranges: d.bulletRanges,
            color: _dc(0),
          ),
        ],
      );
    default:
      return _drMissing(id);
  }
}
