import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/chef_division_models.dart';

class ChefDivisionApiService {

  static const baseUrl =
      ApiConfig.chefdivisionUrl;

  Map<String,String> _headers(
      String token) =>
      {
        'Authorization':
        'Bearer $token',
        'Content-Type':
        'application/json',
      };

  Future<T> _get<T>(
    String endpoint,
    String token,
    T Function(dynamic) parser,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);
    return parser(data);
  }

  Future<List<T>> _getList<T>(
    String endpoint,
    String token,
    T Function(dynamic) parser,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);
    return (data as List).map((e) => parser(e)).toList();
  }

  Future<ChefDivisionProfile> getProfile(String token) =>
      _get('/profile', token, (j) => ChefDivisionProfile.fromJson(j));

  Future<ChefDivisionDashboard> getDashboard(String token) =>
      _get('/dashboard', token, (j) => ChefDivisionDashboard.fromJson(j));

  Future<CongeDashboard> getConges(String token) =>
      _get('/conges/dashboard', token, (j) => CongeDashboard.fromJson(j));

  Future<ArretDashboard> getArrets(String token) =>
      _get('/arrets/dashboard', token, (j) => ArretDashboard.fromJson(j));

  Future<List<EnginKPI>> getTopEngins(String token) =>
      _getList('/stats/engins/top', token, (j) => EnginKPI.fromJson(j));

  Future<List<EnginUsageRate>> getUsageRate(String token) =>
      _getList('/stats/engins/usage-rate', token, (j) => EnginUsageRate.fromJson(j));

  Future<List<EscaleKPI>> getEscales(String token) =>
      _getList('/stats/escales', token, (j) => EscaleKPI.fromJson(j));

  Future<List<EquipeKPI>> getBestTeams(String token) =>
      _getList('/stats/equipes/best', token, (j) => EquipeKPI.fromJson(j));

  Future<List<SignatureModel>> getSignatureHistory(String token) =>
      _getList('/signatures/history', token, (j) => SignatureModel.fromJson(j));
}

