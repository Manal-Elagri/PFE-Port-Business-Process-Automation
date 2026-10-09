import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/operations_models.dart';

class OperationApiService {
  static const String baseUrl = ApiConfig.operationsUrl;

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<OperationResponseDTO> startOperation({
  required String token,
  required StartOperationRequest request,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/start'),
      headers: _headers(token),
      body: jsonEncode(request.toJson()),
    );

    _handleError(response);

    return OperationResponseDTO.fromJson(jsonDecode(response.body));
  }

  Future<String> pauseOperation({
    required String token,
    required int operationId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$operationId/pause'),
      headers: _headers(token),
    );

    _handleError(response);
    return response.body;
  }

  Future<String> resumeOperation({
    required String token,
    required int operationId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$operationId/resume'),
      headers: _headers(token),
    );

    _handleError(response);
    return response.body;
  }

  Future<ArretDTO> arretManuel({
    required String token,
    required int operationId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$operationId/arret'),
      headers: _headers(token),
    );

    _handleError(response);

    return ArretDTO.fromJson(jsonDecode(response.body));
  }

  Future<ArretDTO> terminerArret({
  required String token,
  required int arretId,
  required String cause,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/arrets/$arretId/finish'),
      headers: _headers(token),
      body: jsonEncode({
        'cause': cause,
      }),
    );

    _handleError(response);

    return ArretDTO.fromJson(jsonDecode(response.body));
  }

  Future<List<ArretDTO>> getArretsEnCours({
  required String token,
  required int operationId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$operationId/arrets'),
      headers: _headers(token),
    );

    print('GET ARRETS STATUS: ${response.statusCode}');
    print('GET ARRETS BODY: ${response.body}');

    _handleError(response);

    final List data = jsonDecode(response.body);
    return data.map((e) => ArretDTO.fromJson(e)).toList();
  }

  Future<String> terminerOperation({
    required String token,
    required int operationId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$operationId/finish'),
      headers: _headers(token),
    );

    _handleError(response);
    return response.body;
  }

  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erreur API ${response.statusCode}: ${response.body}',
      );
    }
  }
}