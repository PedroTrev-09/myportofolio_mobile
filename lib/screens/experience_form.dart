import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _startedController = TextEditingController();
  final _endedController = TextEditingController();
  String _title = '';
  String _location = 'Lombok, NTB';
  String _description = '';
  String _category = 'full-time';
  DateTime? _startedAt;
  DateTime? _endedAt;

  static const _categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  @override
  void dispose() {
    _startedController.dispose();
    _endedController.dispose();
    super.dispose();
  }

  String _plainText(String value) =>
      value.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  String? _validateText(String? value, String label, {int? maxLength}) {
    final text = _plainText(value ?? '');
    if (text.isEmpty) return '$label tidak boleh kosong!';
    if (maxLength != null && text.runes.length > maxLength) {
      return '$label maksimal $maxLength karakter!';
    }
    return null;
  }

  String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Future<void> _pickDate({required bool start}) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          (start ? _startedAt : _endedAt) ?? _startedAt ?? DateTime.now(),
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
      helpText: start ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (!mounted || date == null) return;
    setState(() {
      if (start) {
        _startedAt = date;
        _startedController.text = _date(date);
      } else {
        _endedAt = date;
        _endedController.text = _date(date);
      }
    });
  }

  void _showSummary() {
    if (!_formKey.currentState!.validate()) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Pengalaman'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Judul: ${_plainText(_title)}'),
              Text('Kategori: ${_categories[_category]}'),
              Text('Lokasi: ${_plainText(_location)}'),
              Text('Tanggal mulai: ${_date(_startedAt!)}'),
              Text(
                'Tanggal selesai: ${_endedAt == null ? 'Masih berlangsung' : _date(_endedAt!)}',
              ),
              Text('Deskripsi: ${_plainText(_description)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengalaman')),
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
                    TextFormField(
                      key: const ValueKey('experienceTitle'),
                      decoration: _decoration('Judul Pengalaman'),
                      onChanged: (value) => _title = value,
                      validator: (value) =>
                          _validateText(value, 'Judul', maxLength: 255),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('experienceCategory'),
                      initialValue: 'full-time',
                      isExpanded: true,
                      decoration: _decoration('Kategori Pengalaman'),
                      items: _categories.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _category = value;
                      },
                      validator: (value) => _categories.containsKey(value)
                          ? null
                          : 'Pilih kategori yang tersedia!',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('experienceLocation'),
                      initialValue: _location,
                      decoration: _decoration('Lokasi'),
                      onChanged: (value) => _location = value,
                      validator: (value) =>
                          _validateText(value, 'Lokasi', maxLength: 255),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('experienceStartedAt'),
                      controller: _startedController,
                      readOnly: true,
                      decoration: _decoration(
                        'Tanggal Mulai',
                        suffix: const Icon(Icons.calendar_today_outlined),
                      ),
                      onTap: () => _pickDate(start: true),
                      validator: (_) => _startedAt == null
                          ? 'Tanggal mulai wajib dipilih!'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('experienceEndedAt'),
                      controller: _endedController,
                      readOnly: true,
                      decoration: _decoration(
                        'Tanggal Selesai (opsional)',
                        hint: 'Kosongkan jika masih berlangsung',
                        suffix: _endedAt == null
                            ? const Icon(Icons.calendar_today_outlined)
                            : IconButton(
                                tooltip: 'Kosongkan tanggal selesai',
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() {
                                  _endedAt = null;
                                  _endedController.clear();
                                }),
                              ),
                      ),
                      onTap: () => _pickDate(start: false),
                      validator: (_) =>
                          _startedAt != null &&
                              _endedAt != null &&
                              _endedAt!.isBefore(_startedAt!)
                          ? 'Tanggal selesai tidak boleh sebelum tanggal mulai!'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('experienceDescription'),
                      maxLines: 5,
                      decoration: _decoration('Deskripsi Pengalaman'),
                      onChanged: (value) => _description = value,
                      validator: (value) => _validateText(value, 'Deskripsi'),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                        ),
                        onPressed: _showSummary,
                        child: const Text('Simpan'),
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
}
