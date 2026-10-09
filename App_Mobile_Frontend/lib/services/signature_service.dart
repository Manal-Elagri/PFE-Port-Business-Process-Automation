import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SignatureApiService {
  String getPdfUrl({
    required int documentId,
    required String token,
  }) {
    return '${ApiConfig.baseUrl}/api/security/documents/$documentId/pdf?token=${Uri.encodeComponent(token)}';
  }

  Future<String> signDocumentBySecureLink({
    required int documentId,
    required String token,
    required String otpCode,
    required String signatureBase64,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/security/documents/$documentId/sign',
    ).replace(queryParameters: {'token': token});

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'otpCode': otpCode,
        'signatureBase64': signatureBase64,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur signature ${response.statusCode}: ${response.body}');
    }

    return response.body;
  }
}