import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/storage/token_storage.dart';

/// Low-level HTTP wrapper.
/// All remote sources call this — never use `http` directly elsewhere.
class ApiClient {
  ApiClient._();

  // ─── URI builder ─────────────────────────────────────────────────────────────

  static Uri _uri(String path, {Map<String, String>? params}) {
    final base = Uri.parse(AppConfig.baseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.port,
      path: '${base.path}$path',
      queryParameters: (params == null || params.isEmpty) ? null : params,
    );
  }

  // ─── Headers ─────────────────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await TokenStorage.read();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── Response parser ─────────────────────────────────────────────────────────

  static dynamic _parse(http.Response res) {
    final decoded = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;
    throw ApiException(
      (decoded is Map ? decoded['message'] : null) ?? 'Request failed',
      statusCode: res.statusCode,
    );
  }

  // ─── HTTP verbs ──────────────────────────────────────────────────────────────

  static Future<dynamic> get(String path, {Map<String, String>? params}) async {
    final res = await http.get(_uri(path, params: params), headers: await _headers());
    return _parse(res);
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _parse(res);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _parse(res);
  }

  static Future<void> delete(String path) async {
    final res = await http.delete(_uri(path), headers: await _headers());
    _parse(res);
  }

  /// Multipart request — used for creating/updating products with images.
  static Future<http.StreamedResponse> multipart(
    String path, {
    String method = 'POST',
    required Map<String, String> fields,
    http.MultipartFile? file,
  }) async {
    final token = await TokenStorage.read();
    final req = http.MultipartRequest(method, _uri(path));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.fields.addAll(fields);
    if (file != null) req.files.add(file);
    return req.send();
  }

  // ─── Helper ──────────────────────────────────────────────────────────────────

  /// Full URL to a stored product image.
  static String imageUrl(String filename) {
    final base = AppConfig.baseUrl.replaceAll('/api', '');
    return '$base/uploads/images/$filename';
  }
}
