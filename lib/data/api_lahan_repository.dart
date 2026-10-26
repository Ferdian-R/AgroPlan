import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lahan.dart';
import '../services/api_config.dart';
import 'lahan_repository.dart';

/// Implementasi LahanRepository menggunakan REST API backend MySQL
/// dengan fallback ke Mock data jika koneksi backend tidak tersedia.
class ApiLahanRepository implements LahanRepository {
  final MockLahanRepository _fallbackMock = MockLahanRepository();

  @override
  Future<List<Lahan>> getDaftarLahan() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.lahan))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];
        return data.map((item) => Lahan.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ ApiLahanRepository.getDaftarLahan fallback ke mock: $e');
    }
    return _fallbackMock.getDaftarLahan();
  }

  @override
  Future<Lahan> getDetailLahan(int idLahan) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.lahan}/$idLahan'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        return Lahan.fromJson(jsonBody['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('⚠️ ApiLahanRepository.getDetailLahan fallback ke mock: $e');
    }
    return _fallbackMock.getDetailLahan(idLahan);
  }

  @override
  Future<bool> tambahLahan(Lahan lahan) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.lahan),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'nama_lahan': lahan.namaLahan,
              'lokasi': lahan.lokasi ?? 'Lokasi',
              'luas_lahan': lahan.luasLahan,
              'jenis_tanah': 'Aluvial',
              'komoditas_utama': lahan.komoditasUtama,
              'id_pengguna': 1,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ ApiLahanRepository.tambahLahan fallback ke mock: $e');
    }
    return _fallbackMock.tambahLahan(lahan);
  }

  @override
  Future<bool> updateLahan(Lahan lahan) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.lahan}/${lahan.idLahan}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'nama_lahan': lahan.namaLahan,
              'lokasi': lahan.lokasi,
              'luas_lahan': lahan.luasLahan,
              'komoditas_utama': lahan.komoditasUtama,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ ApiLahanRepository.updateLahan fallback ke mock: $e');
    }
    return _fallbackMock.updateLahan(lahan);
  }

  @override
  Future<bool> hapusLahan(int idLahan) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.lahan}/$idLahan'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ ApiLahanRepository.hapusLahan fallback ke mock: $e');
    }
    return _fallbackMock.hapusLahan(idLahan);
  }
}
