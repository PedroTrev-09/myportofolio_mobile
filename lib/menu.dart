import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme.dart';

/// The menu is static at this tutorial stage; it needs no local mutable state.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = '2506553383';
  final String nama = 'Haikal Rafka A Rahman';
  final String kelas = 'PBP A';

  final List<ItemHomepage> items = const [
    ItemHomepage(
      'Lihat Proyek',
      Icons.folder_outlined,
      PortfolioColors.dusk,
      Colors.white,
    ),
    ItemHomepage(
      'Tambah Proyek',
      Icons.add_circle_outline,
      PortfolioColors.sunset,
      PortfolioColors.ink,
    ),
    ItemHomepage(
      'Lihat Pengalaman',
      Icons.work_outline,
      PortfolioColors.midday,
      PortfolioColors.ink,
    ),
    ItemHomepage(
      'Tambah Pengalaman',
      Icons.playlist_add,
      PortfolioColors.inkSoft,
      Colors.white,
    ),
    ItemHomepage(
      'Logout',
      Icons.logout,
      PortfolioColors.paperAlt,
      PortfolioColors.ink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPortfolio'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.wb_sunny_outlined, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'PORTOFOLIO PRIBADI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nama,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Mahasiswa Sistem Informasi, Universitas Indonesia. '
                      'Graphic design, branding, dan fotografi.',
                      style: TextStyle(fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // The full name must remain readable, including on narrow phones.
                        if (constraints.maxWidth < 560) {
                          return Column(
                            children: [
                              InfoCard(title: 'Nama', content: nama),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: InfoCard(title: 'NPM', content: npm),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InfoCard(
                                      title: 'Kelas',
                                      content: kelas,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: InfoCard(title: 'NPM', content: npm),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: InfoCard(title: 'Nama', content: nama),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InfoCard(title: 'Kelas', content: kelas),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Proyek, pengalaman, dan perjalanan kreatif saya.',
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final largeText =
                            MediaQuery.textScalerOf(context).scale(14) > 21;
                        final columns = constraints.maxWidth < 300 || largeText
                            ? 2
                            : 3;
                        final cardWidth =
                            (constraints.maxWidth - 12 * (columns - 1)) /
                            columns;
                        var minimumHeight = 96.0;
                        for (final item in items) {
                          final painter = TextPainter(
                            text: TextSpan(
                              text: item.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout(maxWidth: cardWidth - 24);
                          minimumHeight = math.max(
                            minimumHeight,
                            painter.height + 64,
                          );
                          painter.dispose();
                        }
                        final cardHeight = math.max(
                          minimumHeight,
                          cardWidth /
                              (constraints.maxWidth >= 700 && !largeText
                                  ? 1.8
                                  : .92),
                        );
                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          primary: false,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: cardWidth / cardHeight,
                          children: items
                              .map(
                                (item) =>
                                    ItemCard(item, key: ValueKey(item.name)),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '© 2026 Haikal Rafka A Rahman • PBP A',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A title/value card: layout sizing belongs to its parent, not the full screen.
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tutorial's menu model, with explicit contrasting colors from the website.
class ItemHomepage {
  const ItemHomepage(this.name, this.icon, this.color, this.foregroundColor);

  final String name;
  final IconData icon;
  final Color color;
  final Color foregroundColor;
}

class ItemCard extends StatelessWidget {
  const ItemCard(this.item, {super.key});

  final ItemHomepage item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: item.color,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Kamu telah menekan tombol ${item.name}!'),
                  duration: const Duration(seconds: 3),
                ),
              );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 30, color: item.foregroundColor),
                const SizedBox(height: 10),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: item.foregroundColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
