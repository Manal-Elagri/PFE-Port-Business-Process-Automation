import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employe_models.dart';
import '../models/admin_models.dart';
import '../config/api_config.dart';

class EmployeApiService {
  static const String baseUrl = ApiConfig.employeUrl;

  // Headers utilitaires
  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // --- Profil ---
  Future<EmployeProfile?> getProfile(String token) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/me'), headers: _headers(token));
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}'); // ← ajoute ça
    if (response.statusCode == 200) return EmployeProfile.fromJson(jsonDecode(response.body));
  } catch (e) { print('ERREUR PROFILE: $e'); }
  return null;
  }

  // =====================================================
  // CONGES
  // =====================================================

  Future<bool> demanderConge({
    required String token,
    required String dateDebut,
    required String dateFin,
    required String type,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/conges?dateDebut=$dateDebut&dateFin=$dateFin&type=$type'),
      headers: _headers(token),
    );
    return res.statusCode == 200;
  }

  Future<List<CongeModel>> getMyConges(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/conges'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => CongeModel.fromJson(e)).toList();
    }
    return [];
  }

  // =====================================================
  // ASSIGNMENTS
  // =====================================================

  Future<List<EquipePersonnelModel>> getMyAssignments(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/assignments'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => EquipePersonnelModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<EquipePersonnelModel>> getByEquipe(String token, int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/assignments/equipe/$id'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => EquipePersonnelModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<EquipePersonnelModel>> getByShift(String token, int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/assignments/shift/$id'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => EquipePersonnelModel.fromJson(e)).toList();
    }
    return [];
  }

  // =====================================================
  // CALENDAR
  // =====================================================

  Future<List<EquipePersonnelModel>> getCalendar(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/calendar'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => EquipePersonnelModel.fromJson(e)).toList();
    }
    return [];
  }

  // =====================================================
  // HISTORY
  // =====================================================

  Future<List<HistoriqueShiftModel>> getHistory(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => HistoriqueShiftModel.fromJson(e)).toList();
    }
    return [];
  }

  // =====================================================
  // OPERATION : résérver pour le pointeur 
  // =====================================================

  Future<bool> canStartOperation(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/can-start-operation'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return false;
  }

  Future<OperationContextModel?> getOperationContext(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/operation-context'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      return OperationContextModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }


  Future<List<EscaleModel>> getEscales(
  String token,
  ) async {
    try {
      final r = await http.get(
        Uri.parse('$baseUrl/escales'),
        headers: _headers(token),
      );

      if (r.statusCode == 200) {
        List data = jsonDecode(r.body);
        return data.map((e) => EscaleModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Get escales parse error: $e');
  rethrow;
    }

    return [];
  }

  

  Future<List<PosteModel>> getPostes(
    String token,
  ) async {
  try {
    final r = await http.get(
      Uri.parse('$baseUrl/postes'),
      headers: _headers(token),
    );

    if (r.statusCode == 200) {
      List data = jsonDecode(r.body);
      return data.map((e) => PosteModel.fromJson(e)).toList();
    }
  } catch (e) {
    print('Get postes parse error: $e');
    rethrow;
  }

  return [];
  }


  Future<List<PortierModel>> getPortiers(
  String token,
  ) async {
    try {
      final r = await http.get(
        Uri.parse('$baseUrl/portiers'),
        headers: _headers(token),
      );

      if (r.statusCode == 200) {
        List data = jsonDecode(r.body);
        return data.map((e) => PortierModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Get portiers parse error: $e');
      rethrow;
    }

    return [];
  }
  

   Future<List<EnginModel>> getEnginsActifs(String token) async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/engins/actifs'), headers: _headers(token));
      if (r.statusCode == 200) {
        List data = jsonDecode(r.body);
        return data.map((e) => EnginModel.fromJson(e)).toList();
      }
    } catch (e) { print('Get engin parse error: $e');
  rethrow; }
    return [];
  }

 
}