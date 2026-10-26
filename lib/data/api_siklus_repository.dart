import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/siklus_tanam.dart';
import '../services/api_config.dart';
import 'siklus_repository.dart';

/// Implementasi SiklusRepository menggunakan REST API backend MySQL
/// dengan fallback ke Mock data jika koneksi backend tidak tersedia.
class ApiSiklusRepository implements SiklusRepository {
  final MockSiklusRepository _fallbackMock = MockSiklusRepository();

  @override
  Future<List<SiklusTanam>> getDaftarSiklus() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.siklus))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];
        return data.map((item) => SiklusTanam.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ ApiSiklusRepository.getDaftarSiklus fallback ke mock: $e');
    }
    return _fallbackMock.getDaftarSiklus();
  }

  @override
  Future<List<SiklusTanam>> getSiklusByLahan(int idLahan) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.siklus}?id_lahan=$idLahan'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];
        return data.map((item) => SiklusTanam.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ ApiSiklusRepository.getSiklusByLahan fallback ke mock: $e');
    }
    return _fallbackMock.getSiklusByLahan(idLahan);
  }

  @override
  Future<SiklusTanam?> getSiklusAktif(int idLahan) async {
    try {
      final list = await getSiklusAktifByLahan(idLahan);
      return list.isNotEmpty ? list.first : null;
    } catch (e) {
      return _fallbackMock.getSiklusAktif(idLahan);
    }
  }

  @override
  Future<List<SiklusTanam>> getSiklusAktifByLahan(int idLahan) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.siklus}?id_lahan=$idLahan&status=Berjalan'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];
        return data.map((item) => SiklusTanam.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ ApiSiklusRepository.getSiklusAktifByLahan fallback ke mock: $e');
    }
    return _fallbackMock.getSiklusAktifByLahan(idLahan);
  }

  @override
  Future<bool> tambahSiklus(SiklusTanam siklus) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.siklus),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'id_lahan': siklus.idLahan,
              'komoditas': siklus.komoditas,
              'tanggal_rencana_tanam': siklus.tanggalRencanaTanam.toIso8601String().split('T')[0],
              'tanggal_tanam_aktual': siklus.tanggalTanamAktual?.toIso8601String().split('T')[0],
              'catatan': siklus.catatan ?? '',
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ ApiSiklusRepository.tambahSiklus fallback ke mock: $e');
    }
    return _fallbackMock.tambahSiklus(siklus);
  }

  @override
  Future<bool> updateStatusSiklus(int idSiklus, String status) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.siklus}/$idSiklus/selesai'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ ApiSiklusRepository.updateStatusSiklus fallback ke mock: $e');
    }
    return _fallbackMock.updateStatusSiklus(idSiklus, status);
  }

  @override
  Future<bool> updateTanggalTanam(int idSiklus, DateTime tanggalBaru) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.siklus}/$idSiklus/tanggal-tanam'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'tanggal_tanam_baru': tanggalBaru.toIso8601String().split('T')[0],
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ ApiSiklusRepository.updateTanggalTanam fallback ke mock: $e');
    }
    return _fallbackMock.updateTanggalTanam(idSiklus, tanggalBaru);
  }
}
