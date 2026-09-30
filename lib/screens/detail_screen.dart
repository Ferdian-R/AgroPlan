import 'package:flutter/material.dart';
import '../models/lahan.dart';
import '../routes/app_routes.dart';

class DetailScreen extends StatefulWidget {
  // (1) data yang DITERIMA dari Home
  final Lahan lahan;

  const DetailScreen({super.key, required this.lahan});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // (2) menyimpan catatan yang dikirim balik dari form
  String? _catatan;

  // (3) buka form, TUNGGU hasilnya, lalu tampilkan
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    if (!mounted || hasil == null) return; // null = pengguna batal

    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Di dalam State, data widget dibaca dengan "widget.lahan"
    final lahan = widget.lahan;

    return Scaffold(
      appBar: AppBar(title: Text(lahan.namaLahan)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(lahan.namaLahan, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(lahan.chipText),
          const SizedBox(height: 16),
          Text('Jenis tanah: ${lahan.jenisTanah ?? '-'}'),
          Text('Lokasi: ${lahan.lokasi ?? '-'}'),
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