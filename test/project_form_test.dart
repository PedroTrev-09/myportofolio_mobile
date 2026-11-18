import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/project_form.dart';
import 'package:myportofolio_mobile/theme.dart';

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
    MaterialApp(
      theme: buildPortfolioTheme(Brightness.light),
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(scale)),
        child: const ProjectFormPage(),
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
  await tester.enterText(field, value);
}

void main() {
  testWidgets('menu push preserves Home and Back returns to it', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('Tambah Proyek')));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
      isTrue,
    );
    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('drawer replaces routes rather than stacking each destination', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    for (var round = 0; round < 2; round++) {
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
      expect(
        Navigator.of(tester.element(find.byType(MyHomePage))).canPop(),
        isFalse,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('required inputs reject both empty and whitespace-only values', (
    tester,
  ) async {
    await openForm(tester);
    for (final value in ['', '   ']) {
      await fill(tester, 'projectName', value);
      await fill(tester, 'description', value);
      await save(tester);
      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets(
    'dialog shows all values and OK resets text and category together',
    (tester) async {
      await openForm(tester);
      await fill(tester, 'projectName', 'Portofolio Mobile');
      await fill(tester, 'description', 'Latihan form proyek Flutter.');
      await tester.tap(find.byKey(const ValueKey('category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mobile Development').last);
      await tester.pumpAndSettle();
      await fill(tester, 'technologies', 'Flutter, Dart');
      await fill(tester, 'projectLink', 'https://example.com/portfolio');
      await save(tester);
      for (final line in [
        'Nama Proyek: Portofolio Mobile',
        'Deskripsi: Latihan form proyek Flutter.',
        'Kategori: Mobile Development',
        'Teknologi: Flutter, Dart',
        'Tautan: https://example.com/portfolio',
      ]) {
        expect(find.text(line), findsOneWidget);
      }
      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();
      for (final field in tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      )) {
        final state = tester.state<FormFieldState<String>>(
          find.byWidget(field),
        );
        expect(state.value ?? '', isEmpty);
      }
      expect(
        tester
            .state<FormFieldState<String>>(
              find.byKey(const ValueKey('category')),
            )
            .value,
        'Web Development',
      );
      await fill(tester, 'projectName', 'Proyek kedua');
      await fill(tester, 'description', 'Tanpa isian opsional.');
      await save(tester);
      expect(find.text('Kategori: Web Development'), findsOneWidget);
      expect(find.text('Teknologi: '), findsOneWidget);
      expect(find.text('Tautan: '), findsOneWidget);
      expect(find.text('Teknologi: Flutter, Dart'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'form and long dialog remain usable on a 320px phone at scale $scale',
      (tester) async {
        await openForm(tester, size: const Size(320, 568), scale: scale);
        await fill(tester, 'projectName', 'Proyek di layar kecil');
        await fill(
          tester,
          'description',
          List.filled(25, 'Deskripsi proyek panjang.').join(' '),
        );
        await save(tester);
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.widgetWithText(TextButton, 'OK'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
