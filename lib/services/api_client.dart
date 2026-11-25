import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  String get userMessage => switch (statusCode) {
    0 => 'Tidak dapat terhubung ke server. Periksa koneksi dan URL backend.',
    400 => 'Isian tidak dapat diterima server. Periksa kembali data yang dimasukkan.',
    401 => 'Login diperlukan atau sesi sudah berakhir (401).',
    403 => 'Akun ini tidak memiliki izin untuk mengubah proyek (403).',
    _ => 'Permintaan gagal ($statusCode). Silakan coba lagi.',
  };

  @override
  String toString() => 'ApiException($statusCode)';
}

class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path');

  Future<http.Response> _request(Future<http.Response> Function() send) async {
    try {
      final response = await send().timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, response.body);
      }
      return response;
    } on http.ClientException {
      throw const ApiException(0, 'Network error');
    } on TimeoutException {
      throw const ApiException(0, 'Request timed out');
    }
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException(502, 'Invalid JSON response');
    }
  }

  Future<List<Project>> getProjects() async {
    final response = await _request(
      () => _client.get(
        _uri('/api/v1/projects/'),
        headers: const {'Accept': 'application/json'},
      ),
    );
    try {
      return (_decode(response) as List<dynamic>)
          .map((item) => Project.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TypeError {
      throw const ApiException(502, 'Unexpected project response');
    }
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _request(
      () => _client.post(
        _uri('/api/v1/projects/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(project.toJson()),
      ),
    );
    if (response.statusCode != 201)
      throw ApiException(response.statusCode, 'Expected 201 Created');
    try {
      return Project.fromJson(_decode(response) as Map<String, dynamic>);
    } on TypeError {
      throw const ApiException(502, 'Unexpected project response');
    }
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _request(
      () => _client.post(
        _uri('/api/v1/auth/token/'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'username': username, 'password': password}),
      ),
    );
    final decoded = _decode(response);
    if (decoded is! Map<String, dynamic> ||
        decoded['token'] is! String ||
        (decoded['token'] as String).isEmpty) {
      throw const ApiException(502, 'Invalid token response');
    }
    return decoded['token'] as String;
  }

  Future<void> logout({required String token}) async {
    await _request(
      () => _client.post(
        _uri('/api/v1/auth/logout/'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      ),
    );
  }

  void close() => _client.close();
}
