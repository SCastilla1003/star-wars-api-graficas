import 'package:flutter/material.dart';

import '../models/planet.dart';
import '../repositories/planet_repository.dart';
import '../services/swapi_exception.dart';
import '../theme/planet_biome.dart';
import '../widgets/filter_chip_group.dart';
import 'planet_detail_screen.dart';

class PlanetsListScreen extends StatefulWidget {
  const PlanetsListScreen({super.key});

  @override
  State<PlanetsListScreen> createState() => _PlanetsListScreenState();
}

class _PlanetsListScreenState extends State<PlanetsListScreen> {
  final PlanetRepository _repository = PlanetRepository();
  final TextEditingController _searchController = TextEditingController();

  List<String> _climates = [];
  List<String> _terrains = [];
  final Set<String> _selectedClimates = {};
  final Set<String> _selectedTerrains = {};

  List<Planet>? _planets;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final climates = await _repository.getAvailableClimates();
      final terrains = await _repository.getAvailableTerrains();
      final planets = await _repository.filterPlanets();
      if (!mounted) return;
      setState(() {
        _climates = climates;
        _terrains = terrains;
        _planets = planets;
      });
    } on SwapiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _applyFilters() async {
    try {
      final planets = await _repository.filterPlanets(
        query: _searchController.text,
        climates: _selectedClimates,
        terrains: _selectedTerrains,
      );
      if (!mounted) return;
      setState(() => _planets = planets);
    } on SwapiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  void _toggleClimate(String value) {
    setState(() {
      _selectedClimates.contains(value)
          ? _selectedClimates.remove(value)
          : _selectedClimates.add(value);
    });
    _applyFilters();
  }

  void _toggleTerrain(String value) {
    setState(() {
      _selectedTerrains.contains(value)
          ? _selectedTerrains.remove(value)
          : _selectedTerrains.add(value);
    });
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planetas')),
      body: _error != null
          ? _ErrorView(message: _error!, onRetry: _load)
          : _planets == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    await _repository.getAllPlanets(forceRefresh: true);
                    await _applyFilters();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Buscar planetas',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                      const SizedBox(height: 12),
                      FilterChipGroup(
                        options: _climates,
                        selected: _selectedClimates,
                        onToggle: _toggleClimate,
                      ),
                      const SizedBox(height: 8),
                      FilterChipGroup(
                        options: _terrains,
                        selected: _selectedTerrains,
                        onToggle: _toggleTerrain,
                      ),
                      const SizedBox(height: 16),
                      if (_planets!.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Center(child: Text('Sin resultados')),
                        )
                      else
                        ..._planets!.map((planet) => _PlanetTile(planet: planet)),
                    ],
                  ),
                ),
    );
  }
}

class _PlanetTile extends StatelessWidget {
  final Planet planet;

  const _PlanetTile({required this.planet});

  @override
  Widget build(BuildContext context) {
    final style = styleFor(planet);
    final tags = [...planet.climateList, ...planet.terrainList].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: style.primary.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: style.primary.withValues(alpha: 0.15),
          child: Icon(style.icon, color: style.primary),
        ),
        title: Text(planet.name),
        subtitle: Text(tags.isEmpty ? style.label : '${style.label} · $tags'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PlanetDetailScreen(planetId: planet.id)),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
