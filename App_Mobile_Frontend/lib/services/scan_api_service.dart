import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/operations_models.dart';

class ScanApiService {
  static const String baseUrl = ApiConfig.scansUrl;

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<ScanResponseDTO> processScan({
    required String token,
    required ScanRequestDTO request,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _headers(token),
      body: jsonEncode(request.toJson()),
    );

    _handleError(response);

    return ScanResponseDTO.fromJson(jsonDecode(response.body));
  }

  Future<ScanResponseDTO> validateScan({
    required String token,
    required ScanValidationRequestDTO request,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/validate'),
      headers: _headers(token),
      body: jsonEncode(request.toJson()),
    );

    _handleError(response);

    return ScanResponseDTO.fromJson(jsonDecode(response.body));
  }

  Future<List<ScanResponseDTO>> syncOfflineScans({
    required String token,
    required List<ScanRequestDTO> requests,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sync'),
      headers: _headers(token),
      body: jsonEncode(requests.map((e) => e.toJson()).toList()),
    );

    _handleError(response);

    final List data = jsonDecode(response.body);
    return data.map((e) => ScanResponseDTO.fromJson(e)).toList();
  }

  Future<ScanResponseDTO> processImage({
    required String token,
    required String imagePath,
    required int operationId,
    required String deviceId,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/process-image'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['operationId'] = operationId.toString();
    request.fields['deviceId'] = deviceId;

    request.files.add(
      await http.MultipartFile.fromPath('image', imagePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _handleError(response);

    return ScanResponseDTO.fromJson(jsonDecode(response.body));
  }

  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erreur API ${response.statusCode}: ${response.body}',
      );
    }
  }
}