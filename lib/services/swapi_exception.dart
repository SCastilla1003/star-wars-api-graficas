/// Excepción lanzada cuando falla una llamada a SWAPI
/// (timeout, error HTTP, JSON inválido, etc).
class SwapiException implements Exception {
  final String message;
  final int? statusCode;

  const SwapiException(this.message, {this.statusCode});

  @override
  String toString() => 'SwapiException($statusCode): $message';
}
