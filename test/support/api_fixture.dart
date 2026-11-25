import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const projectJson = {
  'id': '948119b0-8146-4866-9b03-63cd8d63c320',
  'title': 'Proyek Django',
  'category': 'Design',
  'short_description': 'Deskripsi singkat',
  'full_description': 'Deskripsi lengkap',
  'tags': 'Flutter, Django',
  'image_url': '',
};

ApiClient fakeApi({Future<http.Response> Function(http.Request)? handler}) =>
    ApiClient(
      client: MockClient(
        handler ??
            (request) async {
              if (request.url.path.endsWith('/auth/token/')) {
                return http.Response('{"token":"test-token"}', 200);
              }
              if (request.url.path.endsWith('/auth/logout/')) {
                return http.Response('', 204);
              }
              if (request.method == 'POST') {
                return http.Response(
                  jsonEncode({
                    ...jsonDecode(request.body) as Map<String, dynamic>,
                    'id': projectJson['id'],
                  }),
                  201,
                );
              }
              return http.Response('[]', 200);
            },
      ),
    );

Widget testScope({
  required Widget child,
  ApiClient? api,
  String? token = 'test-token',
}) => PortfolioAppScope(
  apiClient: api ?? fakeApi(),
  initialToken: token,
  child: child,
);
