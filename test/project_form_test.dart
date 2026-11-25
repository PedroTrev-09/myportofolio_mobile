import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

import 'support/api_fixture.dart';

Future<void> openForm(
  WidgetTester tester, {
  Size size = const Size(800, 1000),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    testScope(
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: const ProjectFormPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'Save');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, String key, String value) async {
  final field = find.byKey(ValueKey(key));
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, value);
}

Future<void> fillProject(WidgetTester tester) async {
  for (final entry in {
    'title': 'Portofolio Mobile',
    'category': 'Design',
    'short_description': 'Ringkasan',
    'full_description': 'Deskripsi lengkap',
    'tags': 'Flutter',
    'image_url': '/static/img/monte.png',
  }.entries) {
    await fill(tester, entry.key, entry.value);
  }
}

void main() {
  testWidgets('authenticated card pushes form and Back restores Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      testScope(child: const MaterialApp(home: MyHomePage())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('Tambah Proyek')));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('authenticated drawer replaces form and Home routes', (
    tester,
  ) async {
    await tester.pumpWidget(
      testScope(child: const MaterialApp(home: MyHomePage())),
    );
    await tester.pumpAndSettle();
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
      isFalse,
    );
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets(
    'all actual serializer fields are required and reject whitespace',
    (tester) async {
      await openForm(tester);
      for (final value in ['', '   ']) {
        for (final key in [
          'title',
          'category',
          'short_description',
          'full_description',
          'tags',
          'image_url',
        ]) {
          await fill(tester, key, value);
        }
        await save(tester);
        expect(find.textContaining('tidak boleh kosong!'), findsNWidgets(6));
        expect(find.byType(AlertDialog), findsNothing);
      }
    },
  );

  testWidgets(
    'image URL validation accepts local assets and rejects unsafe formats',
    (tester) async {
      await openForm(tester);
      await fillProject(tester);
      for (final value in [
        'javascript:alert(1)',
        '//example.com/a.png',
        '/\\evil/a.png',
        'https://example.com/a b.png',
      ]) {
        await fill(tester, 'image_url', value);
        await save(tester);
        expect(
          find.text('Gunakan URL HTTP(S) atau path aset yang diawali /.'),
          findsOneWidget,
        );
        expect(find.byType(AlertDialog), findsNothing);
      }
      await fill(tester, 'image_url', '/static/img/monte.png');
      await save(tester);
      expect(find.text('Proyek berhasil disimpan!'), findsOneWidget);
      expect(find.text('Gambar: /static/img/monte.png'), findsOneWidget);
    },
  );

  testWidgets('successful 201 shows returned fields and OK resets the form', (
    tester,
  ) async {
    await openForm(tester);
    await fillProject(tester);
    await save(tester);
    for (final text in [
      'Judul: Portofolio Mobile',
      'Kategori: Design',
      'Deskripsi singkat: Ringkasan',
      'Deskripsi lengkap: Deskripsi lengkap',
      'Teknologi: Flutter',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    for (final state in tester.stateList<FormFieldState<String>>(
      find.byType(TextFormField),
    )) {
      expect(state.value ?? '', isEmpty);
    }
  });

  testWidgets('small phone and enlarged text keep network Save reachable', (
    tester,
  ) async {
    await openForm(tester, size: const Size(320, 568), scale: 2);
    await fillProject(tester);
    await save(tester);
    expect(find.text('Proyek berhasil disimpan!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
