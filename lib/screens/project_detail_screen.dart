import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});
  final Project project;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(project.title)),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text('Kategori: ${project.category}'),
            Text('Teknologi: ${project.tags}'),
            const SizedBox(height: 12),
            Text(project.shortDescription),
            const SizedBox(height: 16),
            Text(project.fullDescription),
            if (project.imageUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              Image.network(
                Uri.parse(context.read<ApiClient>().baseUrl)
                    .resolve(project.imageUrl)
                    .toString(),
                semanticLabel: 'Gambar ${project.title}',
                errorBuilder: (_, error, stack) =>
                    const Text('Gambar tidak dapat dimuat.'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
