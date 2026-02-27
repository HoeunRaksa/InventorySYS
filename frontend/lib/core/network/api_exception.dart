/// Structured exception for all API failures.
/// Thrown by ApiClient when the server returns a non-2xx status.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException [$statusCode]: $message';
}
