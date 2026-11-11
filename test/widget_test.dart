import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/theme.dart';

Future<void> pumpMenu(
  WidgetTester tester, {
  Size size = const Size(800, 1000),
  double scale = 1,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildPortfolioTheme(brightness),
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(scale)),
        child: const MyHomePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bootstrap opens the portfolio instead of the counter demo', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Haikal Rafka A Rahman'), findsNWidgets(2));
    expect(find.text('2506553383'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.byIcon(Icons.add), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final item in const MyHomePage().items) {
    testWidgets('${item.name} shows its own SnackBar', (tester) async {
      await pumpMenu(tester);
      await tester.tap(find.byKey(ValueKey(item.name)));
      await tester.pumpAndSettle();
      expect(
        find.text('Kamu telah menekan tombol ${item.name}!'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a new action replaces the previous SnackBar', (tester) async {
    await pumpMenu(tester);
    await tester.tap(find.byKey(const ValueKey('Lihat Proyek')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('Tambah Proyek')));
    await tester.pumpAndSettle();
    expect(find.text('Kamu telah menekan tombol Lihat Proyek!'), findsNothing);
    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1440, 900),
  ]) {
    testWidgets('layout and all menu actions fit $size', (tester) async {
      await pumpMenu(tester, size: size);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('Logout')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('Logout')));
      await tester.pumpAndSettle();
      expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('large text on a small phone stays scrollable without overflow', (
    tester,
  ) async {
    await pumpMenu(tester, size: const Size(320, 568), scale: 2);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('Logout')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('Logout')));
    await tester.pumpAndSettle();
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the menu also renders in the portfolio night palette', (
    tester,
  ) async {
    await pumpMenu(tester, brightness: Brightness.dark);
    final context = tester.element(find.byType(MyHomePage));
    expect(Theme.of(context).colorScheme.surface, PortfolioColors.night);
    await tester.tap(find.byKey(const ValueKey('Lihat Pengalaman')));
    await tester.pumpAndSettle();
    expect(
      find.text('Kamu telah menekan tombol Lihat Pengalaman!'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu actions work with keyboard focus', (tester) async {
    await pumpMenu(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
  });

  test('action labels have at least 4.5 to 1 color contrast', () {
    for (final item in const MyHomePage().items) {
      final a = item.color.computeLuminance();
      final b = item.foregroundColor.computeLuminance();
      final ratio = (math.max(a, b) + .05) / (math.min(a, b) + .05);
      expect(ratio, greaterThanOrEqualTo(4.5), reason: item.name);
    }
  });
}
