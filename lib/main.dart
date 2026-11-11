import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio • Haikal Rafka',
      debugShowCheckedModeBanner: false,
      theme: buildPortfolioTheme(Brightness.light),
      darkTheme: buildPortfolioTheme(Brightness.dark),
      home: const MyHomePage(),
    );
  }
}
