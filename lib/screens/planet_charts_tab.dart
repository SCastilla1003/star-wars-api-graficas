import 'package:flutter/material.dart';

import '../charts/chart_catalog.dart';
import '../charts/charts_data.dart';
import '../charts/community_gallery.dart';
import '../charts/drafter_gallery.dart';
import '../charts/fl_gallery.dart';
import '../charts/graphic_gallery.dart';
import '../models/planet.dart';

/// Pestaña 3 del detalle: galería completa de gráficas (63 catálogo ×
/// 4 librerías = 252) con selector de librería, filtro por nivel y
/// navegación ◀ ▶ entre las gráficas del filtro activo.
class PlanetChartsTab extends StatefulWidget {
  final List<Planet> planets;
  final Planet focus;

  const PlanetChartsTab({
    super.key,
    required this.planets,
    required this.focus,
  });

  @override
  State<PlanetChartsTab> createState() => _PlanetChartsTabState();
}

enum _Lib { fl, graphic, community, drafter }

const _libLabels = {
  _Lib.fl: 'fl_chart',
  _Lib.graphic: 'graphic',
  _Lib.community: 'community',
  _Lib.drafter: 'drafter',
};

class _PlanetChartsTabState extends State<PlanetChartsTab> {
  _Lib _lib = _Lib.fl;
  ChartLevel? _level;
  String _selectedId = kChartCatalog.first.id;
  ChartsData? _data;

  ChartsData get _d => _data ??= ChartsData.build(
        widget.planets,
        focus: widget.focus,
      );

  List<ChartSpec> get _specs =>
      _level == null ? kChartCatalog : chartsForLevel(_level!);

  int get _index {
    final i = _specs.indexWhere((c) => c.id == _selectedId);
    return i < 0 ? 0 : i;
  }

  ChartSpec get _selected {
    final specs = _specs;
    return specs[_index < specs.length ? _index : 0];
  }

  void _go(int delta) {
    final specs = _specs;
    final next = (_index + delta) % specs.length;
    setState(() => _selectedId = specs[next].id);
  }

  void _setLevel(ChartLevel? level) {
    setState(() {
      _level = level;
      final list = level == null ? kChartCatalog : chartsForLevel(level);
      if (!list.any((c) => c.id == _selectedId)) {
        _selectedId = list.first.id;
      }
    });
  }

  Widget _buildChart(String id) {
    final d = _d;
    final child = switch (_lib) {
      _Lib.fl => buildFlChart(id, d),
      _Lib.graphic => buildGraphicChart(id, d),
      _Lib.community => buildCommunityChart(id, d),
      _Lib.drafter => buildDrafterChart(id, d),
    };
    return KeyedSubtree(
      key: ValueKey('$_lib-$id'),
      child: RepaintBoundary(child: ClipRect(child: child)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final specs = _specs;
    final selected = _selected;
    final theme = Theme.of(context);

    return Column(
      children: [
        // ------------------------------------------------ selector librería
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final lib in _Lib.values)
                ChoiceChip(
                  label: Text(_libLabels[lib]!),
                  avatar: Icon(
                    switch (lib) {
                      _Lib.fl => Icons.show_chart,
                      _Lib.graphic => Icons.scatter_plot_outlined,
                      _Lib.community => Icons.bar_chart_rounded,
                      _Lib.drafter => Icons.donut_small_outlined,
                    },
                    size: 16,
                  ),
                  selected: _lib == lib,
                  onSelected: (_) => setState(() => _lib = lib),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),

        // ------------------------------------------------- filtro por nivel
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Wrap(
            spacing: 6,
            children: [
              ChoiceChip(
                label: Text('Todas (${kChartCatalog.length})'),
                selected: _level == null,
                onSelected: (_) => _setLevel(null),
                visualDensity: VisualDensity.compact,
              ),
              ChoiceChip(
                label: Text(
                    'Básicas (${chartsForLevel(ChartLevel.basica).length})'),
                selected: _level == ChartLevel.basica,
                onSelected: (_) => _setLevel(ChartLevel.basica),
                visualDensity: VisualDensity.compact,
              ),
              ChoiceChip(
                label: Text(
                    'Avanzadas (${chartsForLevel(ChartLevel.avanzada).length})'),
                selected: _level == ChartLevel.avanzada,
                onSelected: (_) => _setLevel(ChartLevel.avanzada),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 6),
              Text('$kTotalCharts gráficas', style: theme.textTheme.labelSmall),
            ],
          ),
        ),

        // ---------------------------------------------------------- visor
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                ),
              ),
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            selected.level == ChartLevel.basica
                                ? 'básica'
                                : 'avanzada',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selected.name,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(_libLabels[_lib]!,
                            style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      selected.description,
                      style: theme.textTheme.labelSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: _buildChart(_selectedId),
                    ),
                  ),
                  const Divider(height: 1, indent: 8, endIndent: 8),

                  // ------------------------------------- navegación ◀ ▶
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          tooltip: 'Anterior',
                          onPressed: () => _go(-1),
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedId,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            isDense: true,
                            items: [
                              for (final s in specs)
                                DropdownMenuItem(
                                  value: s.id,
                                  child: Text(
                                    s.name,
                                    style: theme.textTheme.labelMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (id) =>
                                setState(() => _selectedId = id!),
                          ),
                        ),
                        Text(
                          '${_index + 1} de ${specs.length}',
                          style: theme.textTheme.labelSmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          tooltip: 'Siguiente',
                          onPressed: () => _go(1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
