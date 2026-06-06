import 'package:http/http.dart' as http;

import '../models/song.dart';
import 'omr_service.dart';

/// `/omr_backend` (FastAPI) servisine bağlanan OMR uyarlaması.
///
/// Backend: `POST {baseUrl}/convert` (multipart, alan adı: "file")
/// → JSON note timeline döner.
///
/// Not: OMR pahalıdır; çağrı **parça başına yalnızca bir kez** yapılmalı ve
/// sonuç [SongRepository] ile cihazda saklanmalıdır.
class RemoteOmrService implements OmrService {
  RemoteOmrService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<Song> convert(String filePath) async {
    final uri = Uri.parse('$baseUrl/convert');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw OmrException(
        'OMR dönüştürme başarısız (HTTP ${response.statusCode})',
      );
    }
    return Song.fromJsonString(response.body);
  }
}

class OmrException implements Exception {
  OmrException(this.message);
  final String message;
  @override
  String toString() => 'OmrException: $message';
}
