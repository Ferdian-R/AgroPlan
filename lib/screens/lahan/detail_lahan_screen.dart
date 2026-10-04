import 'package:flutter/material.dart';
import '../../models/lahan.dart';
import '../../routes/app_routes.dart';

class DetailLahanScreen extends StatefulWidget {
  final Lahan lahan;

  const DetailLahanScreen({super.key, required this.lahan});

  @override
  State<DetailLahanScreen> createState() => _DetailLahanScreenState();
}

class _DetailLahanScreenState extends State<DetailLahanScreen> {
  String? _catatan;

  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    if (!mounted || hasil == null) return;

    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lahan = widget.lahan;

    return Scaffold(
      appBar: AppBar(title: Text(lahan.namaLahan)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            lahan.namaLahan,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(height: 32),
          Text(
            _catatan == null ? 'Belum ada catatan.' : 'Catatan: $_catatan',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Catatan'),
          ),
        ],
      ),
    );
  }
}
