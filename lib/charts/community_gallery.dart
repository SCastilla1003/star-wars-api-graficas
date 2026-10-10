import 'dart:math' as math;

import 'package:community_charts_common/community_charts_common.dart' as cm;
import 'package:community_charts_flutter/community_charts_flutter.dart' as cc;
import 'package:flutter/material.dart';

import 'charts_data.dart';

/// Galería de las 63 gráficas del catálogo renderizadas con community_charts.
Widget buildCommunityChart(String id, ChartsData d) => _cg(id, d);

final List<cc.Color> _cp = <cc.Color>[
  cc.MaterialPalette.blue.shadeDefault,
  cc.MaterialPalette.teal.shadeDefault,
  cc.MaterialPalette.purple.shadeDefault,
  cc.MaterialPalette.deepOrange.shadeDefault,
  cc.MaterialPalette.green.shadeDefault,
  cc.MaterialPalette.pink.shadeDefault,
  cc.MaterialPalette.indigo.shadeDefault,
  cc.MaterialPalette.yellow.shadeDefault,
];

cc.Color _cc(int i) => _cp[i % _cp.length];

Widget _cg(String id, ChartsData d) {
  switch (id) {
    // --------------------------------------------------------------- líneas
    case 'line_simple':
      return _ordLine([_catSeq('Diámetro', d.seqLabels, d.seqDiameter, _cc(0))]);
    case 'line_multi':
      return _ordLine(
        [
          _catSeq('Población', d.seqLabels, d.seqPopulationLog, _cc(0)),
          _catSeq('Agua', d.seqLabels, d.seqWater, _cc(1)),
          _catSeq('Rotación', d.seqLabels, d.seqRotation, _cc(2)),
        ],
        legend: true,
      );
    case 'line_markers':
      return _ordLine(
        [_catSeq('Diámetro', d.seqLabels, d.seqDiameter, _cc(0))],
        renderer: cc.LineRendererConfig<String>(includePoints: true, radiusPx: 4),
      );
    case 'line_dashed':
      return _ordLine(
        [_catSeq('Diámetro', d.seqLabels, d.seqDiameter, _cc(0))],
        renderer: cc.LineRendererConfig<String>(dashPattern: [6, 4], strokeWidthPx: 2),
      );
    case 'line_smooth':
      return _ordLine(
        [_catSeq('Diámetro', d.seqLabels, d.seqDiameter, _cc(2))],
        renderer: cc.LineRendererConfig<String>(strokeWidthPx: 4, roundEndCaps: true),
      );
    case 'line_gradient':
      return _ordLine(
        [_catSeq('Población', d.seqLabels, d.seqPopulationLog, _cc(0))],
        renderer: cc.LineRendererConfig<String>(
            includeArea: true, areaOpacity: 0.45, strokeWidthPx: 3),
      );
    case 'step_line':
      return _ordLine(
        [_catSeq('Diámetro', d.seqLabels, d.seqDiameter, _cc(3))],
        renderer: cc.LineRendererConfig<String>(dashPattern: [14, 6], strokeWidthPx: 4),
      );
    case 'line_log':
      return _ordLine(
        [_catSeq('Población (log)', d.seqLabels, d.seqPopulationLog, _cc(6))],
        renderer: cc.LineRendererConfig<String>(includePoints: true, radiusPx: 3),
      );

    // --------------------------------------------------------------- barras
    case 'bar_vertical':
      return _bar([_nv('Diámetro', d.topDiameter, _cc(0))]);
    case 'bar_horizontal':
      return _bar([_nv('Diámetro', d.topDiameter, _cc(0))], vertical: false);
    case 'bar_grouped':
      return _bar(
        [
          _catSeq('Diámetro', d.seqLabels, d.seqDiameter, _cc(0)),
          _catSeq('Agua', d.seqLabels, d.seqWater, _cc(1)),
        ],
        legend: true,
      );
    case 'bar_stacked':
      return _bar(_stackSeries(d), legend: true, grouping: cc.BarGroupingType.stacked);
    case 'bar_stacked_100':
      return cc.BarChart(
        _stackSeries(d),
        barGroupingType: cc.BarGroupingType.stacked,
        behaviors: [
          cc.PercentInjector(totalType: cc.PercentInjectorTotalType.domain)
        ],
        primaryMeasureAxis: cc.PercentAxisSpec(),
      );
    case 'bar_diverging':
      return _bar([_nv('vs. media', d.divergingDiameter, _cc(3), bySign: true)]);
    case 'bar_stacked_total': {
      final series = _stackSeries(d);
      final totals = <double>[];
      for (var b = 0; b < d.stackBiomes.length; b++) {
        var sum = 0.0;
        for (var c = 0; c < d.stackClimates.length; c++) {
          sum += d.stackValues[c][b];
        }
        totals.add(sum);
      }
      series.add(_catSeq('Total', d.stackBiomes, totals, _cc(7))
        ..setAttribute(cc.rendererIdKey, 'ln'));
      return cc.OrdinalComboChart(
        series,
        defaultRenderer:
            cc.BarRendererConfig<String>(groupingType: cc.BarGroupingType.stacked),
        customSeriesRenderers: [
          cc.LineRendererConfig<String>(customRendererId: 'ln', strokeWidthPx: 3)
        ],
        behaviors: [cc.SeriesLegend()],
      );
    }
    case 'combo_bar_line': {
      final series = <cc.Series<dynamic, String>>[
        _catSeq('Diámetro', d.seqLabels, d.seqDiameter, _cc(0)),
        _catSeq('Población', d.seqLabels, d.seqPopulationLog, _cc(3))
          ..setAttribute(cc.rendererIdKey, 'ln'),
      ];
      return cc.OrdinalComboChart(
        series,
        defaultRenderer: cc.BarRendererConfig<String>(),
        customSeriesRenderers: [
          cc.LineRendererConfig<String>(
              customRendererId: 'ln', strokeWidthPx: 3, includePoints: true)
        ],
        behaviors: [cc.SeriesLegend()],
      );
    }

    // ------------------------------------------------------------ dispersión
    case 'scatter_basic':
      return _scatter(
        [
          cc.Series<ScatterPt, num>(
            id: 'Diám. vs Pob.',
            data: d.scatterDiameterPopulation,
            domainFn: (p, _) => p.x,
            measureFn: (p, _) => p.y,
            colorFn: (_, _) => _cc(0),
          ),
        ],
      );
    case 'scatter_bubble':
      return _scatter(
        [
          cc.Series<ScatterPt, num>(
            id: 'Burbujas',
            data: d.scatterDiameterPopulation,
            domainFn: (p, _) => p.x,
            measureFn: (p, _) => p.y,
            radiusPxFn: (p, _) => (5 + p.size * 0.35).clamp(5, 24),
            colorFn: (_, _) => _cc(1),
          ),
        ],
      );
    case 'bubble_log':
      return _scatter(
        [
          cc.Series<ScatterPt, num>(
            id: 'Burbujas log',
            data: d.scatterBubble,
            domainFn: (p, _) => p.x,
            measureFn: (p, _) => p.y,
            radiusPxFn: (p, _) => (5 + p.size * 0.35).clamp(5, 24),
            colorFn: (_, _) => _cc(2),
          ),
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
      final line = <ScatterPt>[
        ScatterPt(
            label: 'reg',
            x: minX,
            y: d.regSlope * minX + d.regIntercept,
            size: 0),
        ScatterPt(
            label: 'reg',
            x: maxX,
            y: d.regSlope * maxX + d.regIntercept,
            size: 0),
      ];
      return cc.ScatterPlotChart(
        [
          cc.Series<ScatterPt, num>(
            id: 'Puntos',
            data: pts,
            domainFn: (p, _) => p.x,
            measureFn: (p, _) => ly(p.y),
            colorFn: (_, _) => _cc(0),
          ),
          cc.Series<ScatterPt, num>(
            id: 'Regresión',
            data: line,
            domainFn: (p, _) => p.x,
            measureFn: (p, _) => p.y,
            colorFn: (_, _) => _cc(3),
          )..setAttribute(cc.rendererIdKey, 'ln'),
        ],
        defaultRenderer: cc.PointRendererConfig<num>(),
        customSeriesRenderers: [
          cc.LineRendererConfig<num>(
              customRendererId: 'ln', strokeWidthPx: 3, dashPattern: [8, 4])
        ],
      );
    }
    case 'strip_plot': {
      final pts = <ScatterPt>[];
      for (var g = 0; g < d.stripGroups.length; g++) {
        final values = d.stripGroups[g].values;
        for (var i = 0; i < values.length; i++) {
          final jitter = (((i * 7 + g * 13) % 7) - 3) * 0.1;
          pts.add(ScatterPt(
            label: '$g',
            x: g + jitter,
            y: values[i],
            size: 0,
          ));
        }
      }
      return _scatter(
        [
          cc.Series<ScatterPt, num>(
            id: 'Grupos',
            data: pts,
            domainFn: (e, _) => e.x,
            measureFn: (e, _) => e.y,
            colorFn: (e, _) => _cc(int.tryParse(e.label) ?? 0),
          ),
        ],
      );
    }
    case 'line_annotations':
      return cc.OrdinalComboChart(
        [
          _catSeq('Diámetro', d.seqLabels, d.seqDiameter, _cc(0)),
        ],
        defaultRenderer: cc.LineRendererConfig<String>(includePoints: true),
        behaviors: [
          cc.RangeAnnotation([
            cc.RangeAnnotationSegment(
              d.seqDiameter[d.annotatedMinIndex],
              d.seqDiameter[d.annotatedMaxIndex],
              cc.RangeAnnotationAxisType.measure,
              startLabel: 'Mín',
              endLabel: 'Máx',
              color: cc.MaterialPalette.gray.shade200,
            ),
          ]),
        ],
      );

    // ----------------------------------------------------------------- radar
    case 'radar_basic':
    case 'radar_circle':
    case 'radar_multi': {
      final pts = id == 'radar_multi';
      if (pts) {
        return _ordLine(
          [
            for (var s = 0; s < d.multiRadar.length; s++)
              _catSeq(d.multiRadarLabels[s], d.radarTitles, d.multiRadar[s],
                  _cc(s)),
          ],
          renderer: cc.LineRendererConfig<String>(
              includePoints: true, radiusPx: 5, strokeWidthPx: 3),
          legend: true,
        );
      }
      final withPoints = id == 'radar_circle';
      return _ordLine(
        [
          _catSeq('Planeta', d.radarTitles, d.radarFocus, _cc(2)),
          _catSeq('Media', d.radarTitles, d.radarAvg, _cc(5)),
        ],
        renderer: cc.LineRendererConfig<String>(
          includePoints: withPoints,
          radiusPx: 5,
          strokeWidthPx: 3,
        ),
        legend: true,
      );
    }
    case 'polar_area':
      return _pie(d.biomeCounts, outsideLabels: true);
    case 'radial_bar':
      return _bar([_nv('Biomas', d.biomeCounts, _cc(2))], vertical: false);

    case 'area_simple':
      return _ordLine(
        [_catSeq('Población', d.seqLabels, d.seqPopulationLog, _cc(0))],
        renderer: cc.LineRendererConfig<String>(
            includeArea: true, areaOpacity: 0.3),
      );
    case 'area_stacked':
      return _ordLine(
        _stackSeries(d),
        renderer: cc.LineRendererConfig<String>(
            stacked: true, includeArea: true, areaOpacity: 0.35),
        legend: true,
      );
    case 'area_gradient':
      return _ordLine(
        [_catSeq('Población', d.seqLabels, d.seqPopulationLog, _cc(6))],
        renderer: cc.LineRendererConfig<String>(
            includeArea: true, areaOpacity: 0.55, strokeWidthPx: 3),
      );
    case 'step_area':
      return _ordLine(
        [_catSeq('Agua', d.seqLabels, d.seqWater, _cc(1))],
        renderer: cc.LineRendererConfig<String>(
            includeArea: true,
            areaOpacity: 0.35,
            dashPattern: [6, 4],
            includePoints: true),
      );
    case 'stream_graph': {
      final series = <cc.Series<dynamic, String>>[];
      for (var b = 0; b < d.stackBiomes.length; b++) {
        final values = <double>[
          for (var c = 0; c < d.stackClimates.length; c++) d.stackValues[c][b],
        ];
        series.add(_catSeq(d.stackBiomes[b], d.stackClimates, values, _cc(b)));
      }
      return _ordLine(
        series,
        renderer: cc.LineRendererConfig<String>(
            stacked: true, includeArea: true, areaOpacity: 0.5),
        legend: true,
      );
    }

    // ------------------------------------------------------------ sparklines
    case 'spark_line':
      return SizedBox(
        height: 64,
        child: cc.LineChart(
          [_numSeq(d.seqDiameter, _cc(0))],
          domainAxis: cc.NumericAxisSpec(renderSpec: cc.NoneRenderSpec()),
          primaryMeasureAxis: cc.NumericAxisSpec(renderSpec: cc.NoneRenderSpec()),
        ),
      );
    case 'spark_area':
      return SizedBox(
        height: 64,
        child: cc.LineChart(
          [_numSeq(d.seqPopulationLog, _cc(2))],
          defaultRenderer: cc.LineRendererConfig<num>(
              includeArea: true, areaOpacity: 0.4),
          domainAxis: cc.NumericAxisSpec(renderSpec: cc.NoneRenderSpec()),
          primaryMeasureAxis: cc.NumericAxisSpec(renderSpec: cc.NoneRenderSpec()),
        ),
      );
    case 'spark_bar':
      return SizedBox(
        height: 64,
        child: cc.BarChart(
          [_nv('Diámetro top', d.topDiameter, _cc(4))],
          domainAxis: cc.OrdinalAxisSpec(
              showAxisLine: true, renderSpec: cc.NoneRenderSpec()),
          primaryMeasureAxis:
              cc.NumericAxisSpec(renderSpec: cc.NoneRenderSpec()),
        ),
      );

    // ---------------------------------------------------------- tartas / donas
    case 'pie_basic':
      return _pie(d.climateCounts);
    case 'pie_percent':
      return _pie(d.climateCounts, percentLabels: true, outsideLabels: true);
    case 'pie_exploded':
      return _pie(d.climateCounts, firstStrong: true);
    case 'donut_basic':
      return _pie(d.climateCounts, arcWidth: 55);
    case 'donut_kpi':
      return Stack(
        alignment: Alignment.center,
        children: [
          _pie(d.climateCounts, arcWidth: 55),
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
          Positioned.fill(child: _pie(d.climateCounts, arcWidth: 45)),
          FractionallySizedBox(
            widthFactor: 0.55,
            heightFactor: 0.55,
            child: _pie(d.biomeCounts, arcWidth: 35),
          ),
        ],
      );

    // --------------------------------------------------------------- avanzadas
    case 'histogram': {
      final bins = ChartsData.histogramBins(d.diameterAll, 6);
      return _bar([_nv('Bins', bins, _cc(4))]);
    }
    case 'box_plot':
      return _bar(
        [
          _err<BoxStats>(
            'Caja',
            d.biomeDiameterBox,
            domain: (e) => e.label,
            mid: (e) => e.median,
            lo: (e) => e.min,
            hi: (e) => e.max,
          ),
        ],
        err: _whiskers(),
      );
    case 'dumbbell':
      return _bar(
        [
          _err<BandStat>(
            'Rango',
            d.biomeDiameterRange,
            domain: (e) => e.label,
            mid: (e) => e.center,
            lo: (e) => e.lower,
            hi: (e) => e.upper,
          ),
        ],
        err: _whiskers(),
      );
    case 'bar_error':
      return _bar(
        [
          _err<BoxStats>(
            'Media±σ',
            d.biomeDiameterBox,
            domain: (e) => e.label,
            mid: (e) => e.mean,
            lo: (e) => math.max(0, e.mean - e.std),
            hi: (e) => e.mean + e.std,
          ),
        ],
        err: _whiskers(),
      );
    case 'candlestick':
      return _bar(
        [
          _err<OhlcBar>(
            'OHLC',
            d.biomeOhlc,
            domain: (e) => e.label,
            mid: (e) => e.close,
            lo: (e) => e.low,
            hi: (e) => e.high,
            color: (e, _) => e.close >= e.open
                ? cc.MaterialPalette.green.shadeDefault
                : cc.MaterialPalette.red.shadeDefault,
          ),
        ],
        err: _whiskers(),
      );
    case 'ohlc': {
      final bars = _err<OhlcBar>(
        'OHLC',
        d.biomeOhlc,
        domain: (e) => e.label,
        mid: (e) => e.close,
        lo: (e) => e.low,
        hi: (e) => e.high,
        color: (e, _) => e.close >= e.open
            ? cc.MaterialPalette.green.shadeDefault
            : cc.MaterialPalette.red.shadeDefault,
      );
      final medians = <double>[
        for (final e in d.biomeOhlc) (e.high + e.low) / 2,
      ];
      final line = _catSeq('Mediana', _labels(d.biomeOhlc), medians, _cc(3))
        ..setAttribute(cc.rendererIdKey, 'ln');
      return cc.OrdinalComboChart(
        [bars, line],
        defaultRenderer: cc.BarRendererConfig<String>(
            barRendererDecorator: _whiskers()),
        customSeriesRenderers: [
          cc.LineRendererConfig<String>(customRendererId: 'ln', strokeWidthPx: 3)
        ],
        behaviors: [cc.SeriesLegend()],
      );
    }
    case 'waterfall':
      return _waterfall(d, percent: false);
    case 'waterfall_percent':
      return _waterfall(d, percent: true);
    case 'funnel':
      return _bar(
        [
          _nv(
              'Etapas',
              d.terrainCounts.where((e) => e.label != 'Otros').take(7).toList(),
              _cc(3)),
        ],
        vertical: false,
      );
    case 'gantt':
      return _bar([_nv('Tareas', d.ganttTasks, _cc(1))], vertical: false);
    case 'pyramid': {
      final left = <cc.Series<dynamic, String>>[
        _nv('Izquierda', d.pyramidLeft, _cc(0)),
        cc.Series<int, String>(
          id: 'Derecha',
          data: List<int>.generate(d.pyramidLeft.length, (i) => i),
          domainFn: (i, _) => d.pyramidLeft[i].label,
          measureFn: (i, _) => -(
              i < d.pyramidRight.length ? d.pyramidRight[i].value : 0.0),
          colorFn: (_, _) => _cc(1),
        ),
      ];
      return _bar(left, legend: true);
    }
    case 'treemap': {
      final items = <NameValue>[];
      for (final node in d.hierarchyClimate) {
        for (final child in node.children) {
          items.add(NameValue('${_lbl(node.label)}·${_lbl(child.label)}',
              child.value));
        }
      }
      return _bar(
        [
          cc.Series<NameValue, String>(
            id: 'Treemap',
            data: items,
            domainFn: (e, _) => e.label,
            measureFn: (e, _) => e.value,
            colorFn: (e, i) => _heat((e.value) / 40.0),
          ),
        ],
        vertical: false,
      );
    }
    case 'sunburst': {
      final items = <NameValue>[];
      for (final node in d.hierarchyClimate) {
        for (final child in node.children) {
          items.add(NameValue('${_lbl(node.label)}·${_lbl(child.label)}',
              child.value));
        }
      }
      return _pie(items, outsideLabels: true);
    }
    case 'sankey': {
      final items = [
        for (final f in d.flows) NameValue('${_lbl(f.from)}→${_lbl(f.to)}', f.value),
      ];
      return _bar([_nv('Flujos', items, _cc(2))], vertical: false);
    }
    case 'heatmap_matrix': {
      final items = <NameValue>[];
      var maxV = 1.0;
      for (var r = 0; r < d.matrixRows.length; r++) {
        for (var c = 0; c < d.matrixCols.length; c++) {
          final v = d.matrixValues[r][c];
          items.add(NameValue('${_lbl(d.matrixRows[r])}·${_lbl(d.matrixCols[c])}', v));
          if (v > maxV) maxV = v;
        }
      }
      return _bar(
        [
          cc.Series<NameValue, String>(
            id: 'Matriz',
            data: items,
            domainFn: (e, _) => e.label,
            measureFn: (e, _) => e.value,
            colorFn: (e, _) => _heat(e.value / maxV),
          ),
        ],
      );
    }
    case 'heatmap_calendar': {
      var maxV = 1.0;
      for (final e in d.calendarCells) {
        if (e.value > maxV) maxV = e.value;
      }
      return _bar(
        [
          cc.Series<NameValue, String>(
            id: 'Calendario',
            data: d.calendarCells,
            domainFn: (e, _) => _lbl(e.label),
            measureFn: (e, _) => e.value,
            colorFn: (e, _) => _heat(e.value / maxV),
          ),
        ],
        vertical: false,
      );
    }
    case 'correlation_matrix': {
      final items = <NameValue>[];
      for (var i = 0; i < d.corrLabels.length; i++) {
        for (var j = i + 1; j < d.corrLabels.length; j++) {
          items.add(NameValue('${_lbl(d.corrLabels[i])}·${_lbl(d.corrLabels[j])}',
              d.corrMatrix[i][j]));
        }
      }
      return _bar(
        [
          cc.Series<NameValue, String>(
            id: 'Correlación',
            data: items,
            domainFn: (e, _) => e.label,
            measureFn: (e, _) => e.value * 100,
            colorFn: (e, _) => e.value >= 0 ? _heat(e.value) : _heatRed(-e.value),
          ),
        ],
      );
    }
    case 'range_area':
      return _ordLine(
        [
          cc.Series<BandStat, String>(
            id: 'Rango',
            data: d.biomeWaterBand,
            domainFn: (e, _) => e.label,
            measureFn: (e, _) => e.center,
            measureLowerBoundFn: (e, _) => e.lower,
            measureUpperBoundFn: (e, _) => e.upper,
            colorFn: (_, _) => _cc(1),
          ),
        ],
        renderer: cc.LineRendererConfig<String>(strokeWidthPx: 3),
      );
    case 'line_band':
      return _ordLine(
        [
          _catSeq('Media', d.biomeLabels, [
            for (final b in d.biomeWaterBand) b.center,
          ], _cc(0)),
          _catSeq('Superior', d.biomeLabels, [
            for (final b in d.biomeWaterBand) b.upper,
          ], _cc(1)),
          _catSeq('Inferior', d.biomeLabels, [
            for (final b in d.biomeWaterBand) b.lower,
          ], _cc(2)),
        ],
        legend: true,
      );
    case 'range_column':
      return _bar(
        [
          _catSeq('Mín', d.biomeLabels, [
            for (final b in d.biomeDiameterRange) b.lower,
          ], _cc(0)),
          _catSeq('Máx', d.biomeLabels, [
            for (final b in d.biomeDiameterRange) b.upper,
          ], _cc(1)),
        ],
        legend: true,
      );
    case 'gauge': {
      final v = d.gaugeValue.clamp(0, 100).toDouble();
      return Stack(
        alignment: Alignment.center,
        children: [
          cc.PieChart<String>(
            [
              cc.Series<String, String>(
                id: 'Valor',
                data: ['valor', 'resto'],
                domainFn: (s, _) => s,
                measureFn: (s, _) => s == 'valor' ? v : 100 - v,
                colorFn: (s, _) => s == 'valor'
                    ? _cc(4)
                    : cc.Color.fromHex(code: '#E0E0E0'),
              ),
            ],
            defaultRenderer: cc.ArcRendererConfig<String>(
              arcWidth: 26,
              startAngle: 4 / 5 * math.pi,
              arcLength: 7 / 5 * math.pi,
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
    case 'bullet':
      return _bar(
        [
          _catSeq('25%', [d.focus.name], [d.bulletRanges[0]],
              cc.MaterialPalette.gray.shade200),
          _catSeq('50%', [d.focus.name], [d.bulletRanges[1]],
              cc.MaterialPalette.gray.shade400),
          _catSeq('Valor', [d.focus.name], [d.bulletValue], _cc(0)),
          _catSeq('Objetivo', [d.focus.name], [d.bulletTarget], _cc(3)),
        ],
        legend: true,
      );

    // -------------------------------------------------------- faltantes por id
    default:
      return Center(child: Text('Sin implementar: $id'));
  }
}

// --------------------------------------------------------------------------- //
// Helpers de series y widgets.
// --------------------------------------------------------------------------- //

cc.Series<int, String> _catSeq(
  String id,
  List<String> labels,
  List<double> values,
  cc.Color color,
) =>
    cc.Series<int, String>(
      id: id,
      data: List<int>.generate(values.length, (i) => i),
      domainFn: (i, _) => labels[i],
      measureFn: (i, _) => values[i],
      colorFn: (_, _) => color,
    );

cc.Series<int, num> _numSeq(List<double> values, cc.Color color) =>
    cc.Series<int, num>(
      id: 'serie',
      data: List<int>.generate(values.length, (i) => i),
      domainFn: (i, _) => i,
      measureFn: (i, _) => values[i],
      colorFn: (_, _) => color,
    );

cc.Series<NameValue, String> _nv(
  String id,
  List<NameValue> items,
  cc.Color color, {
  bool bySign = false,
}) =>
    cc.Series<NameValue, String>(
      id: id,
      data: items,
      domainFn: (e, _) => e.label,
      measureFn: (e, _) => e.value,
      colorFn: bySign
          ? (e, _) => e.value >= 0 ? _cc(4) : _cc(3)
          : (_, _) => color,
    );

cc.Series<T, String> _err<T>(
  String id,
  List<T> data, {
  required String Function(T) domain,
  required double Function(T) mid,
  required double Function(T) lo,
  required double Function(T) hi,
  cc.Color Function(T, int?)? color,
}) =>
    cc.Series<T, String>(
      id: id,
      data: data,
      domainFn: (e, _) => domain(e),
      measureFn: (e, _) => mid(e),
      measureLowerBoundFn: (e, _) => lo(e),
      measureUpperBoundFn: (e, _) => hi(e),
      measureOffsetFn: (e, _) => 0,
      colorFn: color ?? (_, _) => _cc(0),
    );

cm.BarRendererDecorator<String> _whiskers() => cm.BarErrorDecorator<String>(
      strokeColor: cc.Color.fromHex(code: '#546E7A'),
      strokeWidthPx: 2,
      endpointLengthPx: 10,
    );

List<cc.Series<dynamic, String>> _stackSeries(ChartsData d) => [
      for (var c = 0; c < d.stackClimates.length; c++)
        _catSeq(d.stackClimates[c], d.stackBiomes, [
          for (var b = 0; b < d.stackBiomes.length; b++)
            d.stackValues[c][b],
        ], _cc(c)),
    ];

Widget _ordLine(
  List<cc.Series<dynamic, String>> series, {
  cc.LineRendererConfig<String>? renderer,
  bool legend = false,
}) =>
    cc.OrdinalComboChart(
      series,
      defaultRenderer: renderer ?? cc.LineRendererConfig<String>(),
      behaviors: legend ? [cc.SeriesLegend()] : null,
    );

Widget _bar(
  List<cc.Series<dynamic, String>> series, {
  bool vertical = true,
  cc.BarGroupingType grouping = cc.BarGroupingType.grouped,
  cm.BarRendererDecorator<String>? err,
  bool legend = false,
}) =>
    cc.BarChart(
      series,
      vertical: vertical,
      barGroupingType: grouping,
      barRendererDecorator: err,
      behaviors: legend ? [cc.SeriesLegend()] : null,
    );

Widget _scatter(List<cc.Series<dynamic, num>> series) =>
    cc.ScatterPlotChart(series, defaultRenderer: cc.PointRendererConfig<num>());

Widget _pie(
  List<NameValue> items, {
  int? arcWidth,
  bool percentLabels = false,
  bool outsideLabels = false,
  bool firstStrong = false,
}) {
  final total = items.fold<double>(0, (s, e) => s + e.value);
  return cc.PieChart<String>(
    [
      cc.Series<NameValue, String>(
        id: 'tarta',
        data: items,
        domainFn: (e, _) => e.label,
        measureFn: (e, _) => e.value,
        colorFn: (e, i) {
          if (firstStrong) {
            return i == 0 ? _cc(0) : cc.Color.fromHex(code: '#B0BEC5');
          }
          return _cc(i ?? 0);
        },
        labelAccessorFn: (e, i) => percentLabels
            ? '${total == 0 ? 0 : (e.value / total * 100).round()}%'
            : _lbl(e.label),
      ),
    ],
    defaultRenderer: cc.ArcRendererConfig<String>(
      arcWidth: arcWidth,
      arcRendererDecorators: [
        cc.ArcLabelDecorator(
          labelPosition: outsideLabels
              ? cc.ArcLabelPosition.outside
              : cc.ArcLabelPosition.auto,
          insideLabelStyleSpec: cc.TextStyleSpec(
            fontSize: 10,
            color: cc.MaterialPalette.white,
          ),
          outsideLabelStyleSpec: cc.TextStyleSpec(fontSize: 10),
        ),
      ],
    ),
  );
}

Widget _waterfall(ChartsData d, {required bool percent}) {
  final steps =
      d.terrainCounts.where((e) => e.label != 'Otros').take(6).toList();
  final sum = steps.fold<double>(0, (s, e) => s + e.value);
  double val(double v) => percent ? (sum == 0 ? 0 : v / sum * 100) : v;
  final running = <double>[];
  var acc = 0.0;
  for (final e in steps) {
    acc += val(e.value);
    running.add(acc);
  }
  return cc.OrdinalComboChart(
    [
      _nv('Incrementos', [
        for (final e in steps) NameValue(e.label, val(e.value)),
      ], _cc(4)),
      _catSeq('Acumulado', [for (final e in steps) e.label], running, _cc(3))
        ..setAttribute(cc.rendererIdKey, 'ln'),
    ],
    defaultRenderer: cc.BarRendererConfig<String>(),
    customSeriesRenderers: [
      cc.LineRendererConfig<String>(customRendererId: 'ln', strokeWidthPx: 3)
    ],
    behaviors: [cc.SeriesLegend()],
  );
}

String _lbl(String s) {
  final t = s.split(',').first.split(' ').first;
  return t.length > 11 ? '${t.substring(0, 10)}…' : t;
}

List<String> _labels(List<OhlcBar> bars) => [for (final b in bars) b.label];

/// Interpola blanco→rojo (t: 0..1) como color community_charts.
cc.Color _heatRed(double t) {
  final k = t.clamp(0.0, 1.0);
  final r = (236 - 40 * k).round();
  final g = (240 - 170 * k).round();
  final b = (244 - 170 * k).round();
  final hex = '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
  return cc.Color.fromHex(code: '#$hex');
}

/// Interpola blanco→teal (t: 0..1) como color community_charts.
cc.Color _heat(double t) {
  final k = t.clamp(0.0, 1.0);
  final r = (236 - 200 * k).round();
  final g = (240 - 80 * k).round();
  final b = (244 - 60 * k).round();
  final hex = '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
  return cc.Color.fromHex(code: '#$hex');
}
