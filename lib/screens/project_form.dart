import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});
  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _values = {};
  bool _isSubmitting = false;

  String? _validate(
    String? value,
    String label, {
    int? limit,
    bool image = false,
  }) {
    final text = (value ?? '').trim();
    if (text.replaceAll(RegExp(r'<[^>]*>'), '').trim().isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (limit != null && text.runes.length > limit) {
      return '$label maksimal $limit karakter!';
    }
    if (image) {
      final uri = Uri.tryParse(text);
      final relative = text.startsWith('/') && !text.startsWith('//');
      if (uri == null ||
          text.contains(RegExp(r'[\s\\]')) ||
          (!relative &&
              (!(uri.scheme == 'http' || uri.scheme == 'https') ||
                  uri.host.isEmpty))) {
        return 'Gunakan URL HTTP(S) atau path aset yang diawali /.';
      }
    }
    return null;
  }

  Widget _field(
    String name,
    String label, {
    int? limit,
    int lines = 1,
    bool image = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      key: ValueKey(name),
      maxLines: lines,
      keyboardType: image
          ? TextInputType.url
          : (lines > 1 ? TextInputType.multiline : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => _validate(value, label, limit: limit, image: image),
      onSaved: (value) => _values[name] = value!.trim(),
    ),
  );

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (!await ensureLoggedIn(context) || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      final token = context.read<AuthState>().token!;
      final created = await context.read<ApiClient>().createProject(
        Project(
          title: _values['title']!,
          category: _values['category']!,
          shortDescription: _values['short_description']!,
          fullDescription: _values['full_description']!,
          tags: _values['tags']!,
          imageUrl: _values['image_url']!,
        ),
        token: token,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek berhasil disimpan!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Judul: ${created.title}'),
                Text('Kategori: ${created.category}'),
                Text('Deskripsi singkat: ${created.shortDescription}'),
                Text('Deskripsi lengkap: ${created.fullDescription}'),
                Text('Teknologi: ${created.tags}'),
                Text('Gambar: ${created.imageUrl}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _formKey.currentState!.reset();
                _values.clear();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        await context.read<AuthState>().logout();
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        final loggedIn = await ensureLoggedIn(context);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loggedIn
                  ? 'Login ulang berhasil. Tekan Save untuk mengirim kembali.'
                  : error.userMessage,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add Project Form')),
    drawer: const LeftDrawer(),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field('title', 'Judul Proyek', limit: 255),
                  _field('category', 'Kategori Proyek', limit: 50),
                  _field('short_description', 'Deskripsi Singkat', lines: 2),
                  _field('full_description', 'Deskripsi Lengkap', lines: 5),
                  _field('tags', 'Teknologi / Tags', limit: 255),
                  _field(
                    'image_url',
                    'URL / Path Gambar',
                    limit: 255,
                    image: true,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary,
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
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
