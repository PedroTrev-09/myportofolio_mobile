import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/theme.dart';

Future<void> openExperience(
  WidgetTester tester, {
  Size size = const Size(800, 1000),
  double scale = 1,
  double keyboard = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildPortfolioTheme(Brightness.light),
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: const ExperienceFormPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String key, String value) async {
  final field = find.byKey(ValueKey(key));
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, value);
}

Future<void> submit(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'Simpan');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> chooseDate(WidgetTester tester, String key, String date) async {
  final field = find.byKey(ValueKey(key));
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.edit_outlined));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(
      of: find.byType(InputDatePickerFormField),
      matching: find.byType(TextField),
    ),
    date,
  );
  await tester.tap(find.text('Pilih').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('experience card pushes a route and system Back restores Home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('Tambah Pengalaman')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('Tambah Pengalaman')));
    await tester.pumpAndSettle();
    expect(find.byType(ExperienceFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(ExperienceFormPage))).canPop(),
      isTrue,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets(
    'shared drawer opens Experience and preserves Home and Add Project',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Home'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Add Project'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Tambah Pengalaman'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.byType(ExperienceFormPage))).canPop(),
        isFalse,
      );
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('required text rejects blank, whitespace and markup-only input', (
    tester,
  ) async {
    await openExperience(tester);
    for (final value in ['', '   ', '<b></b>']) {
      await enter(tester, 'experienceTitle', value);
      await enter(tester, 'experienceLocation', value);
      await enter(tester, 'experienceDescription', value);
      await submit(tester);
      for (final label in ['Judul', 'Lokasi', 'Deskripsi']) {
        expect(find.text('$label tidak boleh kosong!'), findsOneWidget);
      }
      expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('title and location enforce the Django 255-character boundary', (
    tester,
  ) async {
    await openExperience(tester);
    for (final length in [256, 255]) {
      await enter(tester, 'experienceTitle', 'a' * length);
      await enter(tester, 'experienceLocation', 'b' * length);
      await submit(tester);
      for (final label in ['Judul', 'Lokasi']) {
        expect(
          find.text('$label maksimal 255 karakter!'),
          length == 256 ? findsOneWidget : findsNothing,
        );
      }
    }
  });

  testWidgets(
    'date ordering rejects an end before start and accepts the same day',
    (tester) async {
      await openExperience(tester);
      await enter(tester, 'experienceTitle', 'Magang');
      await enter(tester, 'experienceDescription', 'Pengembangan aplikasi.');
      await chooseDate(tester, 'experienceStartedAt', '01/10/2026');
      await chooseDate(tester, 'experienceEndedAt', '01/09/2026');
      await submit(tester);
      expect(
        find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      await chooseDate(tester, 'experienceEndedAt', '01/10/2026');
      await submit(tester);
      expect(find.text('Tanggal mulai: 2026-01-10'), findsOneWidget);
      expect(find.text('Tanggal selesai: 2026-01-10'), findsOneWidget);
    },
  );

  testWidgets(
    'summary contains all six values and closing preserves the form',
    (tester) async {
      await openExperience(tester);
      await enter(tester, 'experienceTitle', '  Desainer  ');
      await enter(tester, 'experienceLocation', 'Jakarta');
      await enter(
        tester,
        'experienceDescription',
        'Mendesain identitas visual.',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('experienceCategory')),
      );
      await tester.tap(find.byKey(const ValueKey('experienceCategory')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Freelance').last);
      await tester.pumpAndSettle();
      await chooseDate(tester, 'experienceStartedAt', '02/01/2026');
      await chooseDate(tester, 'experienceEndedAt', '03/01/2026');
      await submit(tester);
      for (final text in [
        'Judul: Desainer',
        'Kategori: Freelance',
        'Lokasi: Jakarta',
        'Tanggal mulai: 2026-02-01',
        'Tanggal selesai: 2026-03-01',
        'Deskripsi: Mendesain identitas visual.',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      await tester.tap(find.widgetWithText(TextButton, 'Tutup'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('experienceStartedAt')),
            )
            .controller!
            .text,
        '2026-02-01',
      );
      await tester.ensureVisible(find.byTooltip('Kosongkan tanggal selesai'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Kosongkan tanggal selesai'));
      await submit(tester);
      expect(find.text('Tanggal selesai: Masih berlangsung'), findsOneWidget);
    },
  );

  testWidgets(
    'small phone with keyboard and enlarged text keeps Save reachable',
    (tester) async {
      await openExperience(
        tester,
        size: const Size(320, 568),
        scale: 1.5,
        keyboard: 220,
      );
      await enter(tester, 'experienceTitle', 'Proyek desain');
      await enter(tester, 'experienceDescription', 'Deskripsi panjang. ' * 40);
      await submit(tester);
      expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
