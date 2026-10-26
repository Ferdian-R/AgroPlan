import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/riwayat_panen.dart';
import '../services/api_config.dart';
import 'panen_repository.dart';

/// Implementasi PanenRepository menggunakan REST API backend MySQL
/// dengan fallback ke Mock data jika koneksi backend tidak tersedia.
class ApiPanenRepository implements PanenRepository {
  final MockPanenRepository _fallbackMock = MockPanenRepository();

  @override
  Future<List<RiwayatPanen>> getRiwayatPanen() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.panen))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];
        return data.map((item) => RiwayatPanen.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ ApiPanenRepository.getRiwayatPanen fallback ke mock: $e');
    }
    return _fallbackMock.getRiwayatPanen();
  }

  @override
  Future<bool> tambahCatatanPanen(RiwayatPanen panen) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.panen),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(panen.toJson()),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ ApiPanenRepository.tambahCatatanPanen fallback ke mock: $e');
    }
    return _fallbackMock.tambahCatatanPanen(panen);
  }
}
