import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

import '../models/chef_service_models.dart';

import '../models/chef_division_models.dart';

class ChefServiceApiService {

  static const baseUrl =
      ApiConfig.chefserviceUrl;

  Map<String, String> _headers(
      String token) {
    return {
      'Authorization':
          'Bearer $token',
      'Content-Type':
          'application/json',
    };
  }

  Future<dynamic> _get(
  String endpoint,
  String token,
  Function parser, {
  bool list = false,
}) async {

  final response = await http.get(
    Uri.parse('$baseUrl$endpoint'),
    headers: _headers(token),
  );

  print('$baseUrl$endpoint');
  print(response.body);

  if (response.statusCode != 200) {
    throw Exception('Erreur ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  if (list) {
    if (data is List) {
      return List.from(data.map((e) => parser(e)));
    }
    return <dynamic>[];
  }

  return parser(data);
}

  Future<ChefServiceProfile>
      getProfile(
    String token,
  ) async {
    return await _get(
      '/profile',
      token,
      (j) =>
          ChefServiceProfile
              .fromJson(j),
    );
  }

  Future<ChefServiceDashboard>
      getDashboard({
    required String token,
    required int shiftId,
  }) async {
    return await _get(
      '/dashboard?shiftId=$shiftId',
      token,
      (j) =>
          ChefServiceDashboard
              .fromJson(j),
    );
  }

  Future<List<SignatureModel>>
      getSignatureHistory(
    String token,
  ) async {
    return await _get(
      '/signatures/history',
      token,
      (j) =>
          SignatureModel
              .fromJson(j),
      list: true,
    );
  }

  Future<CongeDashboard>
      getCongeDashboard(
    String token,
  ) async {
    return await _get(
      '/conges/dashboard',
      token,
      (j) =>
          CongeDashboard
              .fromJson(j),
    );
  }

  Future<List<ShiftModel>> getShiftCalendar({
  required String token,
  required String date,
}) async {
  final res = await _get(
    '/shifts/calendar?date=$date',
    token,
    (j) => ShiftModel.fromJson(j),
    list: true,
  );

  return List<ShiftModel>.from(res);
}

  Future<List<HistoriqueShiftModel>> getShiftHistory({
  required String token,
  required int shiftId,
}) async {
  final res = await _get(
    '/shifts/$shiftId/history',
    token,
    (j) => HistoriqueShiftModel.fromJson(j),
    list: true,
  );

  return List<HistoriqueShiftModel>.from(res);
}

  Future<List<EquipeModel>> getEquipesByShift({
  required String token,
  required int shiftId,
}) async {
  final res = await _get(
    '/shifts/$shiftId/equipes',
    token,
    (j) => EquipeModel.fromJson(j),
    list: true,
  );

  return List<EquipeModel>.from(res);
}

  Future<List<EquipeModel>>
      getActiveTeamsToday(
    String token,
  ) async {
    return await _get(
      '/equipes/active-today',
      token,
      (j) =>
          EquipeModel
              .fromJson(j),
      list: true,
    );
  }
}