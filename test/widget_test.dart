import 'package:flutter/material.dart';
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
}
