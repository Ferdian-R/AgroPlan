import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/laporan_kondisi.dart';
import '../services/api_config.dart';
import 'laporan_repository.dart';

/// Implementasi LaporanRepository menggunakan REST API backend MySQL
/// dengan fallback ke Mock data jika koneksi backend tidak tersedia.
class ApiLaporanRepository implements LaporanRepository {
  final MockLaporanRepository _fallbackMock = MockLaporanRepository();

  @override
  Future<List<LaporanKondisi>> getDaftarLaporan() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.laporan))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];
        return data.map((item) => LaporanKondisi.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ ApiLaporanRepository.getDaftarLaporan fallback ke mock: $e');
    }
    return _fallbackMock.getDaftarLaporan();
  }

  @override
  Future<bool> tambahLaporan(LaporanKondisi laporan) async {
    try {
      // Jika ada file foto lokal, kirim via multipart
      if (laporan.fotoUrl != null &&
          laporan.fotoUrl!.isNotEmpty &&
          File(laporan.fotoUrl!).existsSync()) {
        final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.laporan));
        request.fields['id_lahan'] = laporan.idLahan.toString();
        request.fields['id_siklus'] = (laporan.idSiklus ?? 1).toString();
        request.fields['tanggal_lapor'] = laporan.tanggalLapor.toIso8601String().split('T')[0];
        request.fields['jenis_kondisi'] = laporan.jenisKondisi;
        request.fields['tingkat_keparahan'] = 'Sedang';
        request.fields['catatan'] = laporan.catatan;

        request.files.add(await http.MultipartFile.fromPath('foto', laporan.fotoUrl!));
        final streamedResponse = await request.send().timeout(const Duration(seconds: 8));
        if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
          return true;
        }
      } else {
        // Kirim via JSON biasa
        final response = await http
            .post(
              Uri.parse(ApiConfig.laporan),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'id_lahan': laporan.idLahan,
                'id_siklus': laporan.idSiklus ?? 1,
                'tanggal_lapor': laporan.tanggalLapor.toIso8601String().split('T')[0],
                'jenis_kondisi': laporan.jenisKondisi,
                'tingkat_keparahan': 'Sedang',
                'catatan': laporan.catatan,
                'foto_url': laporan.fotoUrl,
              }),
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('⚠️ ApiLaporanRepository.tambahLaporan fallback ke mock: $e');
    }
    return _fallbackMock.tambahLaporan(laporan);
  }

  @override
  Future<bool> updateLaporan(LaporanKondisi laporan) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.laporan}/${laporan.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'jenis_kondisi': laporan.jenisKondisi,
              'tingkat_keparahan': 'Sedang',
              'catatan': laporan.catatan,
              'tanggal_lapor': laporan.tanggalLapor.toIso8601String().split('T')[0],
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ ApiLaporanRepository.updateLaporan fallback ke mock: $e');
    }
    return _fallbackMock.updateLaporan(laporan);
  }

  @override
  Future<bool> hapusLaporan(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.laporan}/$id'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ ApiLaporanRepository.hapusLaporan fallback ke mock: $e');
    }
    return _fallbackMock.hapusLaporan(id);
  }
}
