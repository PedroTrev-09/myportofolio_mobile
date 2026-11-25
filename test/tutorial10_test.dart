import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'support/api_fixture.dart';
import 'project_form_test.dart' as form;

void main() {
  test('Project JSON matches actual Django fields and omits server UUID', () {
    final project = Project.fromJson({...projectJson, 'image_url': null});
    expect(project.imageUrl, '');
    expect(project.toJson().containsKey('id'), isFalse);
    expect(project.toJson()['short_description'], 'Deskripsi singkat');
    expect(project.toJson().containsKey('project_url'), isFalse);
  });

  test('HTTP client sends token, JSON body and accepts 201 then 204', () async {
    final requests = <http.Request>[];
    final api = fakeApi(
      handler: (request) async {
        requests.add(request);
        if (request.url.path.endsWith('/auth/token/')) {
          return http.Response('{"token":"key"}', 200);
        }
        if (request.url.path.endsWith('/auth/logout/')) {
          return http.Response('', 204);
        }
        if (request.method == 'POST') {
          return http.Response(jsonEncode(projectJson), 201);
        }
        return http.Response(jsonEncode([projectJson]), 200);
      },
    );
    addTearDown(api.close);
    expect((await api.getProjects()).single.title, 'Proyek Django');
    expect(requests.first.headers.containsKey('authorization'), isFalse);
    expect(await api.obtainToken('user', 'password'), 'key');
    expect(jsonDecode(requests.last.body), {
      'username': 'user',
      'password': 'password',
    });
    await api.createProject(Project.fromJson(projectJson), token: 'key');
    expect(requests.last.headers['authorization'], 'Token key');
    expect(jsonDecode(requests.last.body).containsKey('id'), isFalse);
    await api.logout(token: 'key');
    expect(requests.last.headers['authorization'], 'Token key');
  });

  test(
    'invalid response and non-2xx raise ApiException without exposing bodies',
    () async {
      for (final response in [
        http.Response('<html>secret traceback</html>', 500),
        http.Response('{}', 200),
        http.Response('not-json', 200),
      ]) {
        final api = fakeApi(handler: (_) async => response);
        await expectLater(api.getProjects(), throwsA(isA<ApiException>()));
        api.close();
      }
      expect(
        const ApiException(500, 'secret traceback').userMessage,
        isNot(contains('traceback')),
      );
    },
  );

  test('AuthState clears local token even when revocation fails', () async {
    final api = fakeApi(handler: (_) async => http.Response('', 503));
    final auth = AuthState(api, initialToken: 'key');
    var changes = 0;
    auth.addListener(() => changes++);
    await auth.logout();
    expect(auth.isLoggedIn, isFalse);
    expect(changes, 1);
    auth.dispose();
    api.close();
  });

  testWidgets(
    'guest card asks for login, cancellation does not open the form',
    (tester) async {
      await tester.pumpWidget(
        testScope(token: null, child: const MaterialApp(home: MyHomePage())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('Tambah Proyek')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    },
  );

  testWidgets('login validates, masks password, reports 400 and allows retry', (
    tester,
  ) async {
    var attempt = 0;
    final api = fakeApi(
      handler: (_) async => ++attempt == 1
          ? http.Response('{"error":"private"}', 400)
          : http.Response('{"token":"key"}', 200),
    );
    await tester.pumpWidget(
      testScope(
        api: api,
        token: null,
        child: const MaterialApp(home: MyHomePage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('Tambah Proyek')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Username tidak boleh kosong!'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isTrue,
    );
    await tester.enterText(find.byType(TextFormField).first, 'owner');
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Username atau password salah (400).'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });

  testWidgets(
    'public list caches Future, handles error/retry, and shows empty refresh',
    (tester) async {
      var calls = 0;
      final result = Completer<http.Response>();
      final api = fakeApi(
        handler: (_) {
          calls++;
          return calls == 1
              ? result.future
              : Future.value(http.Response('[]', 200));
        },
      );
      await tester.pumpWidget(
        testScope(
          api: api,
          token: null,
          child: const MaterialApp(home: ProjectListScreen()),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();
      expect(calls, 1);
      result.complete(http.Response('<html>private</html>', 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('private'), findsNothing);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada proyek.'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(calls, 2);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 500),
      );
      await tester.pumpAndSettle();
      expect(calls, 3);
    },
  );

  testWidgets('public project list opens detail and omits an empty image URL', (
    tester,
  ) async {
    final api = fakeApi(
      handler: (_) async => http.Response(jsonEncode([projectJson]), 200),
    );
    await tester.pumpWidget(
      testScope(
        api: api,
        token: null,
        child: const MaterialApp(home: ProjectListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proyek Django'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Deskripsi lengkap'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  for (final code in [401, 403]) {
    testWidgets('POST $code does not show success and preserves form data', (
      tester,
    ) async {
      final api = fakeApi(
        handler: (request) async {
          if (request.url.path.endsWith('/auth/logout/')) {
            return http.Response('', 204);
          }
          return http.Response('private server response', code);
        },
      );
      await tester.pumpWidget(
        testScope(
          api: api,
          child: const MaterialApp(home: ProjectFormPage()),
        ),
      );
      await tester.pumpAndSettle();
      await form.fillProject(tester);
      await form.save(tester);
      expect(find.text('Proyek berhasil disimpan!'), findsNothing);
      if (code == 401) {
        expect(find.byType(LoginScreen), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      } else {
        expect(find.textContaining('(403)'), findsOneWidget);
      }
      expect(find.text('Portofolio Mobile'), findsOneWidget);
      expect(find.textContaining('private server response'), findsNothing);
    });
  }
}
