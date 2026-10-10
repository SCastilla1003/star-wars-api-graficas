import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'charts_data.dart';

/// Galería de las 63 gráficas del catálogo renderizadas con graphic.
Widget buildGraphicChart(String id, ChartsData d) => _gg(id, d);

typedef _M = Map<String, dynamic>;

List<_M> _nv(List<NameValue> items) =>
    [for (final e in items) {'k': e.label, 'v': e.value}];

List<_M> _seq(List<double> values, List<String> labels) => [
      for (var i = 0; i < values.length && i < labels.length; i++)
        {'k': labels[i], 'v': values[i]},
    ];

List<_M> _long(
  List<List<double>> series,
  List<String> names,
  List<String> labels,
) =>
    [
      for (var i = 0; i < labels.length; i++)
        for (var s = 0; s < series.length && s < names.length; s++)
          {'k': labels[i], 's': names[s], 'v': series[s][i]},
    ];

List<_M> _stackRows(ChartsData d) => [
      for (var b = 0; b < d.stackBiomes.length; b++)
        for (var c = 0; c < d.stackClimates.length; c++)
          {
            'k': d.stackBiomes[b],
            's': d.stackClimates[c],
            'v': d.stackValues[c][b],
          },
    ];

Variable<_M, String> _kVar({bool inflate = true}) => Variable(
      accessor: (m) => m['k'] as String,
      scale: OrdinalScale(inflate: inflate),
    );

Variable<_M, num> _vVar({num? min, num? max}) => Variable(
      accessor: (m) => m['v'] as num,
      scale: (min == null && max == null) ? null : LinearScale(min: min, max: max),
    );

Variable<_M, String> _sVar() => Variable(accessor: (m) => m['s'] as String);

List<AxisGuide> get _axes => [Defaults.horizontalAxis, Defaults.verticalAxis];

Widget _gg(String id, ChartsData d) {
  switch (id) {
    // --------------------------------------------------------------- líneas
    case 'line_simple':
      return Chart<_M>(
        data: _seq(d.seqDiameter, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [LineMark(size: SizeEncode(value: 2))],
        axes: _axes,
      );
    case 'line_multi':
      return Chart<_M>(
        data: _long([
          d.seqPopulationLog,
          d.seqWater,
          d.seqRotation,
        ], [
          'Población',
          'Agua',
          'Rotación',
        ], d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar(), 's': _sVar()},
        marks: [
          LineMark(
            position: Varset('k') * Varset('v') / Varset('s'),
            color: ColorEncode(variable: 's', values: Defaults.colors10),
            size: SizeEncode(value: 2),
          ),
        ],
        axes: _axes,
      );
    case 'line_markers':
      return Chart<_M>(
        data: _seq(d.seqDiameter, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          LineMark(size: SizeEncode(value: 2)),
          PointMark(size: SizeEncode(value: 4)),
        ],
        axes: _axes,
      );
    case 'line_dashed':
      return Chart<_M>(
        data: _seq(d.seqDiameter, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          LineMark(
            shape: ShapeEncode(value: BasicLineShape(dash: [6, 4])),
            size: SizeEncode(value: 2),
          ),
        ],
        axes: _axes,
      );
    case 'line_smooth':
      return Chart<_M>(
        data: _seq(d.seqDiameter, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          LineMark(
            shape: ShapeEncode(value: BasicLineShape(smooth: true)),
            size: SizeEncode(value: 3),
          ),
        ],
        axes: _axes,
      );
    case 'line_gradient':
      return Chart<_M>(
        data: _seq(d.seqPopulationLog, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          AreaMark(
            gradient: GradientEncode(
              value: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Defaults.primaryColor.withAlpha(30),
                  Defaults.primaryColor.withAlpha(180),
                ],
              ),
            ),
          ),
          LineMark(size: SizeEncode(value: 2)),
        ],
        axes: _axes,
      );
    case 'step_line':
      return Chart<_M>(
        data: _seq(d.seqDiameter, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          LineMark(
            shape: ShapeEncode(value: BasicLineShape(stepped: true)),
            size: SizeEncode(value: 2),
          ),
        ],
        axes: _axes,
      );
    case 'line_log':
      return Chart<_M>(
        data: _seq(d.seqPopulationLog, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          LineMark(size: SizeEncode(value: 2)),
          PointMark(size: SizeEncode(value: 3)),
        ],
        axes: _axes,
      );

    // --------------------------------------------------------------- barras
    case 'bar_vertical':
      return Chart<_M>(
        data: _nv(d.topDiameter),
        variables: {'k': _kVar(), 'v': _vVar(min: 0)},
        marks: [IntervalMark()],
        axes: _axes,
      );
    case 'bar_horizontal':
      return Chart<_M>(
        data: _nv(d.topDiameter),
        variables: {'k': _kVar(), 'v': _vVar(min: 0)},
        marks: [IntervalMark()],
        coord: RectCoord(transposed: true),
        axes: _axes,
      );
    case 'bar_grouped':
      return Chart<_M>(
        data: _long([d.seqDiameter, d.seqWater], ['Diámetro', 'Agua'],
            d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar(), 's': _sVar()},
        marks: [
          IntervalMark(
            position: Varset('k') * Varset('v') / Varset('s'),
            color: ColorEncode(variable: 's', values: Defaults.colors10),
            modifiers: [DodgeModifier()],
          ),
        ],
        axes: _axes,
      );
    case 'bar_stacked':
      return Chart<_M>(
        data: _stackRows(d),
        variables: {'k': _kVar(), 'v': _vVar(), 's': _sVar()},
        marks: [
          IntervalMark(
            position: Varset('k') * Varset('v') / Varset('s'),
            color: ColorEncode(variable: 's', values: Defaults.colors10),
            modifiers: [StackModifier()],
          ),
        ],
        axes: _axes,
      );
    case 'bar_stacked_100':
      return Chart<_M>(
        data: _stackRows(d),
        variables: {'k': _kVar(), 'v': _vVar(), 's': _sVar()},
        transforms: [Proportion(variable: 'v', nest: Varset('k'), as: 'p')],
        marks: [
          IntervalMark(
            position: Varset('k') * Varset('p') / Varset('s'),
            color: ColorEncode(variable: 's', values: Defaults.colors10),
            modifiers: [StackModifier()],
          ),
        ],
        axes: _axes,
      );
    case 'bar_diverging':
      return Chart<_M>(
        data: _nv(d.divergingDiameter),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          IntervalMark(
            color: ColorEncode(
              encoder: (t) => (t['v'] as num) >= 0
                  ? const Color(0xff2e7d32)
                  : const Color(0xffc62828),
            ),
          ),
        ],
        axes: _axes,
      );
    case 'bar_stacked_total': {
      final rows = _stackRows(d);
      final totals = <String, double>{};
      for (final r in rows) {
        final k = r['k'] as String;
        totals[k] = (totals[k] ?? 0) + (r['v'] as num).toDouble();
      }
      for (final r in rows) {
        r['t'] = totals[r['k'] as String];
      }
      return Chart<_M>(
        data: rows,
        variables: {
          'k': _kVar(),
          'v': _vVar(),
          's': _sVar(),
          't': Variable(accessor: (m) => m['t'] as num),
        },
        marks: [
          IntervalMark(
            position: Varset('k') * Varset('v') / Varset('s'),
            color: ColorEncode(variable: 's', values: Defaults.colors10),
            modifiers: [StackModifier()],
          ),
          LineMark(
            position: Varset('k') * Varset('t'),
            color: ColorEncode(value: const Color(0xff212121)),
            size: SizeEncode(value: 3),
          ),
        ],
        axes: _axes,
      );
    }
    case 'combo_bar_line': {
      final rows = <_M>[
        for (var i = 0; i < d.seqLabels.length; i++)
          {
            'k': d.seqLabels[i],
            'v': d.seqDiameter[i],
            't': d.seqPopulationLog[i],
          },
      ];
      return Chart<_M>(
        data: rows,
        variables: {
          'k': _kVar(),
          'v': _vVar(min: 0),
          't': Variable(accessor: (m) => m['t'] as num),
        },
        marks: [
          IntervalMark(color: ColorEncode(value: Defaults.primaryColor)),
          LineMark(
            position: Varset('k') * Varset('t'),
            color: ColorEncode(value: const Color(0xffff7043)),
            size: SizeEncode(value: 3),
          ),
        ],
        axes: _axes,
      );
    }

    // ------------------------------------------------------------ dispersión
    case 'scatter_basic':
      return Chart<_M>(
        data: [
          for (final p in d.scatterDiameterPopulation)
            {'x': p.x, 'y': p.y},
        ],
        variables: {
          'x': Variable(accessor: (m) => m['x'] as num),
          'y': Variable(accessor: (m) => m['y'] as num),
        },
        marks: [
          PointMark(
            size: SizeEncode(value: 6),
            color: ColorEncode(value: Defaults.primaryColor),
          ),
        ],
        axes: _axes,
      );
    case 'scatter_bubble':
      return Chart<_M>(
        data: [
          for (final p in d.scatterDiameterPopulation)
            {'x': p.x, 'y': p.y, 's': p.size},
        ],
        variables: {
          'x': Variable(accessor: (m) => m['x'] as num),
          'y': Variable(accessor: (m) => m['y'] as num),
          's': Variable(accessor: (m) => m['s'] as num),
        },
        marks: [
          PointMark(
            size: SizeEncode(variable: 's', values: [5, 22]),
            color: ColorEncode(value: Defaults.colors10[1]),
          ),
        ],
        axes: _axes,
      );
    case 'bubble_log':
      return Chart<_M>(
        data: [
          for (final p in d.scatterBubble) {'x': p.x, 'y': p.y, 's': p.size},
        ],
        variables: {
          'x': Variable(accessor: (m) => m['x'] as num),
          'y': Variable(accessor: (m) => m['y'] as num),
          's': Variable(accessor: (m) => m['s'] as num),
        },
        marks: [
          PointMark(
            size: SizeEncode(variable: 's', values: [5, 22]),
            color: ColorEncode(value: Defaults.colors10[2]),
          ),
        ],
        axes: _axes,
      );
    case 'scatter_regression': {
      final slope = d.regSlope;
      final inter = d.regIntercept;
      return Chart<_M>(
        data: [
          for (final p in d.scatterDiameterPopulation)
            {
              'x': p.x,
              'y': p.y <= 0 ? 0.0 : math.log(p.y) / math.ln10,
              'fit': slope * p.x + inter,
            },
        ],
        variables: {
          'x': Variable(accessor: (m) => m['x'] as num),
          'y': Variable(accessor: (m) => m['y'] as num),
          'fit': Variable(accessor: (m) => m['fit'] as num),
        },
        marks: [
          PointMark(
            size: SizeEncode(value: 5),
            color: ColorEncode(value: Defaults.primaryColor),
          ),
          LineMark(
            position: Varset('x') * Varset('fit'),
            color: ColorEncode(value: const Color(0xffd84315)),
            shape: ShapeEncode(value: BasicLineShape(dash: [8, 4])),
            size: SizeEncode(value: 3),
          ),
        ],
        axes: _axes,
      );
    }
    case 'strip_plot': {
      final rows = <_M>[];
      for (var g = 0; g < d.stripGroups.length; g++) {
        for (final v in d.stripGroups[g].values) {
          rows.add({'k': d.stripGroups[g].label, 'v': v});
        }
      }
      return Chart<_M>(
        data: rows,
        variables: {'k': _kVar(inflate: false), 'v': _vVar()},
        marks: [
          PointMark(
            size: SizeEncode(value: 6),
            color: ColorEncode(variable: 'k', values: Defaults.colors10),
            modifiers: [JitterModifier()],
          ),
        ],
        axes: _axes,
      );
    }
    case 'line_annotations':
      return Chart<_M>(
        data: _seq(d.seqDiameter, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [LineMark(size: SizeEncode(value: 2))],
        axes: _axes,
        annotations: [
          LineAnnotation(
            dim: Dim.y,
            value: d.seqDiameter[d.annotatedMaxIndex],
            style: PaintStyle(
                strokeColor: const Color(0xffc62828), dash: [4, 2]),
          ),
          LineAnnotation(
            dim: Dim.y,
            value: d.seqDiameter[d.annotatedMinIndex],
            style: PaintStyle(
                strokeColor: const Color(0xff2e7d32), dash: [4, 2]),
          ),
        ],
      );

    // ---------------------------------------------------------------- radar
    case 'radar_basic':
      return _radar(d, loop: false, points: false, area: false);
    case 'radar_circle':
      return _radar(d, loop: true, points: true, area: false);
    case 'radar_multi':
      return _radar(d, loop: true, points: false, area: true);
    case 'polar_area':
      return _rose(_nv(d.biomeCounts));
    case 'radial_bar':
      return _rose(_nv(d.terrainWaterAvg));

    // ---------------------------------------------------------------- áreas
    case 'area_simple':
      return Chart<_M>(
        data: _seq(d.seqPopulationLog, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          AreaMark(color: ColorEncode(value: Defaults.primaryColor.withAlpha(90))),
          LineMark(size: SizeEncode(value: 2)),
        ],
        axes: _axes,
      );
    case 'area_stacked':
      return Chart<_M>(
        data: _stackRows(d),
        variables: {'k': _kVar(), 'v': _vVar(), 's': _sVar()},
        marks: [
          AreaMark(
            position: Varset('k') * Varset('v') / Varset('s'),
            color: ColorEncode(variable: 's', values: Defaults.colors10),
            modifiers: [StackModifier()],
          ),
        ],
        axes: _axes,
      );
    case 'area_gradient':
      return Chart<_M>(
        data: _seq(d.seqPopulationLog, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          AreaMark(
            gradient: GradientEncode(
              value: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Defaults.colors10[4].withAlpha(20),
                  Defaults.colors10[4].withAlpha(200),
                ],
              ),
            ),
          ),
          LineMark(size: SizeEncode(value: 2)),
        ],
        axes: _axes,
      );
    case 'step_area':
      return Chart<_M>(
        data: _seq(d.seqWater, d.seqLabels),
        variables: {'k': _kVar(), 'v': _vVar()},
        marks: [
          AreaMark(
            shape: ShapeEncode(value: BasicAreaShape(stepped: true)),
            color: ColorEncode(value: Defaults.colors10[1].withAlpha(90)),
          ),
          LineMark(
            shape: ShapeEncode(value: BasicLineShape(stepped: true)),
            size: SizeEncode(value: 2),
          ),
        ],
        axes: _axes,
      );
    case 'stream_graph':
      return Chart<_M>(
        data: _stackRows(d),
        variables: {'k': _kVar(), 'v': _vVar(), 's': _sVar()},
        marks: [
          AreaMark(
            position: Varset('k') * Varset('v') / Varset('s'),
            color: ColorEncode(variable: 's', values: Defaults.colors10),
            modifiers: [StackModifier(), SymmetricModifier()],
          ),
        ],
        axes: _axes,
      );

    // ------------------------------------------------------------ sparklines
    case 'spark_line':
      return SizedBox(
        height: 64,
        child: Chart<_M>(
          data: _seq(d.seqDiameter, d.seqLabels),
          variables: {'k': _kVar(), 'v': _vVar()},
          marks: [
            LineMark(
              size: SizeEncode(value: 2),
              color: ColorEncode(value: Defaults.primaryColor),
            ),
          ],
        ),
      );
    case 'spark_area':
      return SizedBox(
        height: 64,
        child: Chart<_M>(
          data: _seq(d.seqPopulationLog, d.seqLabels),
          variables: {'k': _kVar(), 'v': _vVar()},
          marks: [
            AreaMark(
              color: ColorEncode(value: Defaults.colors10[4].withAlpha(110)),
            ),
            LineMark(size: SizeEncode(value: 2)),
          ],
        ),
      );
    case 'spark_bar':
      return SizedBox(
        height: 64,
        child: Chart<_M>(
          data: _nv(d.topDiameter),
          variables: {'k': _kVar(), 'v': _vVar(min: 0)},
          marks: [
            IntervalMark(color: ColorEncode(value: Defaults.colors10[3])),
          ],
        ),
      );

    // ---------------------------------------------------------- avanzadas
    case 'histogram':
      return Chart<_M>(
        data: _nv(ChartsData.histogramBins(d.diameterAll, 6)),
        variables: {'k': _kVar(), 'v': _vVar(min: 0)},
        marks: [
          IntervalMark(
            shape: ShapeEncode(value: RectShape(histogram: true)),
            color: ColorEncode(value: Defaults.colors10[8]),
          ),
        ],
        axes: _axes,
      );
    case 'box_plot': {
      final rows = <_M>[
        for (final b in d.biomeDiameterBox)
          {'k': b.label, 'lo': b.q1, 'hi': b.q3, 'm': b.median},
      ];
      return Chart<_M>(
        data: rows,
        variables: {
          'k': _kVar(),
          'lo': Variable(accessor: (m) => m['lo'] as num),
          'hi': Variable(accessor: (m) => m['hi'] as num),
          'm': Variable(accessor: (m) => m['m'] as num),
        },
        marks: [
          AreaMark(
            position: Varset('k') * (Varset('lo') + Varset('hi')),
            color: ColorEncode(value: Defaults.colors10[0].withAlpha(110)),
          ),
          LineMark(
            position: Varset('k') * Varset('m'),
            color: ColorEncode(value: const Color(0xffc62828)),
            size: SizeEncode(value: 3),
          ),
        ],
        axes: _axes,
      );
    }
    case 'waterfall':
    case 'waterfall_percent': {
      final steps =
          d.terrainCounts.where((e) => e.label != 'Otros').take(6).toList();
      final sum = steps.fold<double>(0, (s, e) => s + e.value);
      final percent = id == 'waterfall_percent';
      double val(double v) => percent ? (sum == 0 ? 0 : v / sum * 100) : v;
      var acc = 0.0;
      final rows = <_M>[];
      final totalRows = <_M>[];
      for (final e in steps) {
        final v = val(e.value);
        acc += v;
        rows.add({'k': e.label, 'v': v});
        totalRows.add({'k': e.label, 't': acc});
      }
      return Chart<_M>(
        data: [
          for (var i = 0; i < rows.length; i++) {...rows[i], 't': totalRows[i]['t']},
        ],
        variables: {
          'k': _kVar(),
          'v': _vVar(min: 0),
          't': Variable(accessor: (m) => m['t'] as num),
        },
        marks: [
          IntervalMark(
            color: ColorEncode(
              encoder: (t) => (t['v'] as num) >= 0
                  ? const Color(0xff2e7d32)
                  : const Color(0xffc62828),
            ),
          ),
          LineMark(
            position: Varset('k') * Varset('t'),
            color: ColorEncode(value: const Color(0xff212121)),
            shape: ShapeEncode(value: BasicLineShape(dash: [5, 3])),
            size: SizeEncode(value: 3),
          ),
        ],
        axes: _axes,
      );
    }
    case 'funnel':
      return Chart<_M>(
        data: _nv(d.terrainCounts
            .where((e) => e.label != 'Otros')
            .take(7)
            .toList()),
        variables: {'k': _kVar(), 'v': _vVar(min: 0)},
        marks: [
          IntervalMark(color: ColorEncode(value: Defaults.colors10[7])),
        ],
        coord: RectCoord(transposed: true),
        axes: _axes,
      );
    case 'gantt':
      return Chart<_M>(
        data: _nv(d.ganttTasks),
        variables: {'k': _kVar(), 'v': _vVar(min: 0)},
        marks: [
          IntervalMark(color: ColorEncode(value: Defaults.colors10[1])),
        ],
        coord: RectCoord(transposed: true),
        axes: _axes,
      );
    case 'pyramid': {
      final rows = <_M>[
        for (var i = 0; i < d.pyramidLeft.length; i++) ...[
          {'k': d.pyramidLeft[i].label, 's': 'Izq', 'v': d.pyramidLeft[i].value},
          {
            'k': d.pyramidLeft[i].label,
            's': 'Der',
            'v': -(i < d.pyramidRight.length ? d.pyramidRight[i].value : 0.0),
          },
        ],
      ];
      return Chart<_M>(
        data: rows,
        variables: {'k': _kVar(), 'v': _vVar(), 's': _sVar()},
        marks: [
          IntervalMark(
            position: Varset('k') * Varset('v') / Varset('s'),
            color: ColorEncode(variable: 's', values: Defaults.colors10),
            modifiers: [DodgeModifier()],
          ),
        ],
        axes: _axes,
      );
    }
    case 'treemap': {
      final items = <NameValue>[];
      for (final node in d.hierarchyClimate) {
        for (final child in node.children) {
          items.add(NameValue(
              '·', child.value));
        }
      }
      final rows = <_M>[
        for (var i = 0; i < items.length; i++)
          {
            'k': items[i].label,
            'c': '${i % 6}',
            'r': '${i ~/ 6}',
            'v': items[i].value,
          },
      ];
      return Chart<_M>(
        data: rows,
        variables: {
          'c': Variable(accessor: (m) => m['c'] as String),
          'r': Variable(accessor: (m) => m['r'] as String),
          'v': Variable(accessor: (m) => m['v'] as num),
        },
        marks: [
          PolygonMark(
            color: ColorEncode(
              variable: 'v',
              values: [
                const Color(0xffe0f7fa),
                const Color(0xff006064),
              ],
            ),
          ),
        ],
        axes: _axes,
      );
    }
    case 'sunburst':
      return _pieChart(
        [
          for (final node in d.hierarchyClimate)
            for (final child in node.children)
              NameValue('${_lbl(node.label)}·${_lbl(child.label)}',
                  child.value),
        ],
        startRadius: 0.35,
        showNames: false,
      );
    case 'sankey':
      return Chart<_M>(
        data: _nv([
          for (final f in d.flows)
            NameValue('${_lbl(f.from)}→${_lbl(f.to)}', f.value),
        ]),
        variables: {'k': _kVar(), 'v': _vVar(min: 0)},
        marks: [
          IntervalMark(color: ColorEncode(value: Defaults.colors10[5])),
        ],
        coord: RectCoord(transposed: true),
        axes: _axes,
      );
    case 'heatmap_matrix': {
      final rows = <_M>[
        for (var r = 0; r < d.matrixRows.length; r++)
          for (var c = 0; c < d.matrixCols.length; c++)
            {
              'c': d.matrixCols[c],
              'r': d.matrixRows[r],
              'v': d.matrixValues[r][c],
            },
      ];
      return _heat(rows);
    }
    case 'heatmap_calendar': {
      final rows = <_M>[
        for (var i = 0; i < d.calendarCells.length; i++)
          {
            'c': '${i % 10}',
            'r': '${i ~/ 10}',
            'v': d.calendarCells[i].value,
          },
      ];
      return _heat(rows);
    }
    case 'correlation_matrix': {
      final rows = <_M>[];
      for (var i = 0; i < d.corrLabels.length; i++) {
        for (var j = i + 1; j < d.corrLabels.length; j++) {
          rows.add({
            'c': _lbl(d.corrLabels[j]),
            'r': _lbl(d.corrLabels[i]),
            'v': d.corrMatrix[i][j] * 100,
          });
        }
      }
      return Chart<_M>(
        data: rows,
        variables: {
          'c': Variable(accessor: (m) => m['c'] as String),
          'r': Variable(accessor: (m) => m['r'] as String),
          'v': Variable(accessor: (m) => m['v'] as num),
        },
        marks: [
          PolygonMark(
            color: ColorEncode(
              variable: 'v',
              values: [
                const Color(0xffc62828),
                const Color(0xffeeeeee),
                const Color(0xff1565c0),
              ],
              stops: [0, 0.5, 1],
            ),
          ),
        ],
        axes: _axes,
      );
    }
    case 'range_area':
    case 'line_band': {
      final band = id == 'line_band';
      final rows = <_M>[
        for (final b in d.biomeWaterBand)
          {'k': b.label, 'lo': b.lower, 'hi': b.upper, 'm': b.center},
      ];
      return Chart<_M>(
        data: rows,
        variables: {
          'k': _kVar(),
          'lo': Variable(accessor: (m) => m['lo'] as num),
          'hi': Variable(accessor: (m) => m['hi'] as num),
          'm': Variable(accessor: (m) => m['m'] as num),
        },
        marks: [
          AreaMark(
            position: Varset('k') * (Varset('lo') + Varset('hi')),
            color: ColorEncode(value: Defaults.colors10[1].withAlpha(90)),
          ),
          LineMark(
            position: Varset('k') * Varset('m'),
            color: ColorEncode(value: Defaults.colors10[1]),
            size: SizeEncode(value: 3),
          ),
          if (band)
            LineMark(
              position: Varset('k') * Varset('hi'),
              color: ColorEncode(value: Defaults.colors10[6]),
              shape: ShapeEncode(value: BasicLineShape(dash: [4, 3])),
              size: SizeEncode(value: 1),
            ),
          if (band)
            LineMark(
              position: Varset('k') * Varset('lo'),
              color: ColorEncode(value: Defaults.colors10[6]),
              shape: ShapeEncode(value: BasicLineShape(dash: [4, 3])),
              size: SizeEncode(value: 1),
            ),
        ],
        axes: _axes,
      );
    }
    case 'range_column': {
      final rows = <_M>[
        for (final b in d.biomeDiameterRange)
          {'k': b.label, 'lo': b.lower, 'hi': b.upper},
      ];
      return Chart<_M>(
        data: rows,
        variables: {
          'k': _kVar(),
          'lo': Variable(accessor: (m) => m['lo'] as num),
          'hi': Variable(accessor: (m) => m['hi'] as num),
        },
        marks: [
          IntervalMark(
            position: Varset('k') * (Varset('lo') + Varset('hi')),
            color: ColorEncode(value: Defaults.colors10[0]),
            shape: ShapeEncode(
                value: RectShape(borderRadius: BorderRadius.circular(3))),
          ),
        ],
        axes: _axes,
      );
    }
    case 'gauge': {
      final v = d.gaugeValue.clamp(0, 100).toDouble();
      return Stack(
        alignment: Alignment.center,
        children: [
          Chart<_M>(
            data: [
              {'k': 'valor', 'v': v},
              {'k': 'resto', 'v': 100 - v},
            ],
            variables: {
              'k': Variable(accessor: (m) => m['k'] as String),
              'v': Variable(accessor: (m) => m['v'] as num),
            },
            transforms: [Proportion(variable: 'v', as: 'p')],
            marks: [
              IntervalMark(
                position: Varset('p') / Varset('k'),
                color: ColorEncode(
                  encoder: (t) => t['k'] == 'valor'
                      ? Defaults.colors10[3]
                      : const Color(0xffe0e0e0),
                ),
                modifiers: [StackModifier()],
              ),
            ],
            coord: PolarCoord(
              transposed: true,
              dimCount: 1,
              startAngle: -math.pi,
              endAngle: 0,
            ),
          ),
          Builder(
            builder: (context) => Text(
              '${v.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      );
    }
    case 'bullet': {
      final rows = <_M>[
        {'s': '25%', 'v': d.bulletRanges[0]},
        {'s': '50%', 'v': d.bulletRanges[1]},
        {'s': 'Valor', 'v': d.bulletValue},
        {'s': 'Objetivo', 'v': d.bulletTarget},
      ];
      return Chart<_M>(
        data: rows,
        variables: {'v': _vVar(min: 0), 's': _sVar()},
        marks: [
          IntervalMark(
            position: Varset('s') * Varset('v'),
            color: ColorEncode(
              encoder: (t) {
                final s = t['s'];
                if (s == 'Valor') return Defaults.colors10[0];
                if (s == 'Objetivo') return Defaults.colors10[7];
                return s == '25%'
                    ? const Color(0xffe0e0e0)
                    : const Color(0xffbdbdbd);
              },
            ),
          ),
        ],
        coord: RectCoord(transposed: true),
        axes: _axes,
      );
    }
    case 'bar_error': {
      final rows = <_M>[
        for (final b in d.biomeDiameterBox)
          {'k': b.label, 'v': b.mean, 'e': b.std},
      ];
      return Chart<_M>(
        data: rows,
        variables: {
          'k': _kVar(),
          'v': _vVar(min: 0),
          'e': Variable(accessor: (m) => m['e'] as num),
        },
        marks: [
          IntervalMark(
            color: ColorEncode(value: Defaults.colors10[6]),
            label: LabelEncode(
              encoder: (t) =>
                  Label('±${(t['e'] as num).toStringAsFixed(1)}'),
            ),
          ),
        ],
        axes: _axes,
      );
    }

    // ------------------------------------------------------------- tartas
    case 'pie_basic':
      return _pieChart(d.climateCounts, showNames: true);
    case 'pie_percent':
      return _pieChart(d.climateCounts, percentLabels: true);
    case 'pie_exploded':
      return _pieChart(d.climateCounts, startRadius: 0.05, showNames: true);
    case 'donut_basic':
      return _pieChart(d.climateCounts, startRadius: 0.4, showNames: true);
    case 'donut_kpi':
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
              child: _pieChart(d.climateCounts, startRadius: 0.4)),
          Builder(
            builder: (context) => Text(
              '${d.totalPlanets}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      );
    case 'donut_multi_ring':
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
              child: _pieChart(d.climateCounts, startRadius: 0.45)),
          FractionallySizedBox(
            widthFactor: 0.55,
            heightFactor: 0.55,
            child: _pieChart(d.biomeCounts, startRadius: 0.35),
          ),
        ],
      );

    // ------------------------------------------------------------- candle
    case 'candlestick':
    case 'ohlc': {
      final hollow = id == 'candlestick';
      final rows = <_M>[
        for (final b in d.biomeOhlc)
          {'k': b.label, 'o': b.open, 'c': b.close, 'h': b.high, 'l': b.low},
      ];
      return Chart<_M>(
        data: rows,
        variables: {
          'k': _kVar(),
          'o': Variable(accessor: (m) => m['o'] as num),
          'c': Variable(accessor: (m) => m['c'] as num),
          'h': Variable(accessor: (m) => m['h'] as num),
          'l': Variable(accessor: (m) => m['l'] as num),
        },
        marks: [
          CustomMark(
            position: Varset('k') *
                (Varset('o') + Varset('c') + Varset('h') + Varset('l')),
            color: ColorEncode(
              encoder: (t) => (t['c'] as num) >= (t['o'] as num)
                  ? const Color(0xff2e7d32)
                  : const Color(0xffc62828),
            ),
            shape: ShapeEncode(value: CandlestickShape(hollow: hollow)),
            size: SizeEncode(value: 10),
          ),
        ],
        axes: _axes,
      );
    }

    // ---------------------------------------------------------- dumbbell
    case 'dumbbell': {
      final rows = <_M>[
        for (final b in d.biomeDiameterRange) ...[
          {'k': b.label, 's': 'Mín', 'v': b.lower},
          {'k': b.label, 's': 'Máx', 'v': b.upper},
        ],
      ];
      return Chart<_M>(
        data: rows,
        variables: {'k': _kVar(), 'v': _vVar(), 's': _sVar()},
        marks: [
          PointMark(
            position: Varset('k') * Varset('v') / Varset('s'),
            size: SizeEncode(value: 9),
            color: ColorEncode(
              encoder: (t) => t['s'] == 'Mín'
                  ? Defaults.colors10[0]
                  : Defaults.colors10[3],
            ),
            shape: ShapeEncode(value: CircleShape(hollow: true, strokeWidth: 2)),
          ),
        ],
        axes: _axes,
      );
    }

    default:
      return Center(child: Text('Sin implementar: $id'));
  }
}

// --------------------------------------------------------------------------- //
// Helpers.
// --------------------------------------------------------------------------- //

Widget _radar(
  ChartsData d, {
  required bool loop,
  required bool points,
  required bool area,
}) {
  final rows = <_M>[
    for (var i = 0; i < d.radarTitles.length; i++)
      if (!area) ...[
        {'k': d.radarTitles[i], 's': 'Planeta', 'v': d.radarFocus[i]},
        {'k': d.radarTitles[i], 's': 'Media', 'v': d.radarAvg[i]},
      ],
    if (area)
      for (var s = 0; s < d.multiRadar.length; s++)
        for (var i = 0; i < d.radarTitles.length; i++)
          {
            'k': d.radarTitles[i],
            's': d.multiRadarLabels[s],
            'v': d.multiRadar[s][i],
          },
  ];
  final seriesNames = area
      ? d.multiRadarLabels
      : [
          'Planeta',
          'Media',
        ];
  final colors = area
      ? [for (var i = 0; i < seriesNames.length; i++) Defaults.colors10[i]]
      : Defaults.colors10;
  return Chart<_M>(
    data: rows,
    variables: {
      'k': Variable(accessor: (m) => m['k'] as String),
      'v': Variable(accessor: (m) => m['v'] as num),
      's': Variable(accessor: (m) => m['s'] as String),
    },
    marks: [
      if (area)
        AreaMark(
          position: Varset('k') * Varset('v') / Varset('s'),
          color: ColorEncode(
            variable: 's',
            values: [for (final c in colors) c.withAlpha(110)],
          ),
          shape: ShapeEncode(value: BasicAreaShape(loop: true)),
        ),
      if (!area)
        LineMark(
          position: Varset('k') * Varset('v') / Varset('s'),
          color: ColorEncode(variable: 's', values: colors),
          shape: ShapeEncode(value: BasicLineShape(loop: loop)),
          size: SizeEncode(value: 3),
        ),
      if (points)
        PointMark(
          position: Varset('k') * Varset('v') / Varset('s'),
          color: ColorEncode(variable: 's', values: colors),
          size: SizeEncode(value: 5),
        ),
    ],
    coord: PolarCoord(),
    axes: [Defaults.circularAxis, Defaults.radialAxis],
  );
}

Widget _rose(List<_M> data) => Chart<_M>(
      data: data,
      variables: {
        'k': Variable(accessor: (m) => m['k'] as String),
        'v': Variable(accessor: (m) => m['v'] as num),
      },
      marks: [
        IntervalMark(
          color: ColorEncode(variable: 'k', values: Defaults.colors10),
          shape: ShapeEncode(
              value: RectShape(borderRadius: BorderRadius.circular(4))),
        ),
      ],
      coord: PolarCoord(startRadius: 0.15),
      axes: [Defaults.circularAxis],
    );

Widget _pieChart(
  List<NameValue> items, {
  double startRadius = 0,
  bool showNames = false,
  bool percentLabels = false,
}) =>
    Chart<_M>(
      data: [
        for (final e in items) {'k': e.label, 'v': e.value},
      ],
      variables: {
        'k': Variable(accessor: (m) => m['k'] as String),
        'v': Variable(accessor: (m) => m['v'] as num),
      },
      transforms: [Proportion(variable: 'v', as: 'p')],
      marks: [
        IntervalMark(
          position: Varset('p') / Varset('k'),
          color: ColorEncode(variable: 'k', values: Defaults.colors10),
          modifiers: [StackModifier()],
          label: showNames || percentLabels
              ? LabelEncode(
                  encoder: (t) => Label(
                    percentLabels
                        ? '${((t['p'] as num) * 100).round()}%'
                        : _lbl(t['k'].toString()),
                  ),
                )
              : null,
        ),
      ],
      coord: PolarCoord(
        transposed: true,
        dimCount: 1,
        startRadius: startRadius > 0 ? startRadius : null,
      ),
    );

Widget _heat(List<_M> rows) => Chart<_M>(
      data: rows,
      variables: {
        'c': Variable(accessor: (m) => m['c'] as String),
        'r': Variable(accessor: (m) => m['r'] as String),
        'v': Variable(accessor: (m) => m['v'] as num),
      },
      marks: [
        PolygonMark(
          color: ColorEncode(
            variable: 'v',
            values: [
              const Color(0xffe0f2f1),
              const Color(0xff00695c),
            ],
          ),
        ),
      ],
      axes: _axes,
    );

String _lbl(String s) {
  final t = s.split(',').first.split(' ').first;
  return t.length > 11 ? '${t.substring(0, 10)}…' : t;
}
