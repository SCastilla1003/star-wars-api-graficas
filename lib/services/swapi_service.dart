import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/planet.dart';
import 'swapi_exception.dart';

/// Respuesta paginada cruda de SWAPI (endpoint /planets/).
class SwapiPage {
  final int count;
  final String? next;
  final String? previous;
  final List<Planet> results;

  const SwapiPage({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory SwapiPage.fromJson(Map<String, dynamic> json) {
    return SwapiPage(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List? ?? const [])
          .map((e) => Planet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Cliente HTTP directo contra SWAPI. No hace caché ni filtrado local:
/// eso vive en PlanetRepository. Aquí solo hay llamadas a la red.
class SwapiService {
  // Si swapi.dev llegara a fallar, la alternativa compatible es
  // 'https://swapi.tech/api' (formato de respuesta ligeramente distinto).
  static const String baseUrl = 'https://swapi.dev/api';

  final http.Client _client;

  SwapiService({http.Client? client}) : _client = client ?? http.Client();

  /// Trae una página de planetas. page=1 es la primera.
  Future<SwapiPage> fetchPlanetsPage({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/planets/?page=$page');
    return _getPage(uri);
  }

  /// Trae una página siguiendo la url "next" que devuelve SWAPI.
  Future<SwapiPage> fetchPage(String url) => _getPage(Uri.parse(url));

  /// Búsqueda por nombre soportada nativamente por SWAPI
  /// (?search=nombre). Solo filtra por nombre, no por clima/terreno.
  Future<SwapiPage> searchPlanetsByName(String query) async {
    final uri = Uri.parse(
      '$baseUrl/planets/?search=${Uri.encodeQueryComponent(query)}',
    );
    return _getPage(uri);
  }

  /// Trae un planeta puntual por id (ej. 1 -> Tatooine).
  Future<Planet> fetchPlanetById(int id) async {
    final uri = Uri.parse('$baseUrl/planets/$id/');
    try {
      final response = await _client.get(uri);
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Planet.fromJson(json);
    } on SwapiException {
      rethrow;
    } catch (e) {
      throw SwapiException('No se pudo obtener el planeta $id: $e');
    }
  }

  Future<SwapiPage> _getPage(Uri uri) async {
    try {
      final response = await _client.get(uri);
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SwapiPage.fromJson(json);
    } on SwapiException {
      rethrow;
    } catch (e) {
      throw SwapiException('No se pudo consultar $uri: $e');
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SwapiException(
        'Error HTTP al consultar SWAPI',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}
