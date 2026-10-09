import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chef_escale_models.dart';
import '../config/api_config.dart';

class ChefEscaleApiService {
  static const String baseUrl = ApiConfig.chefescaleUrl;

  // Headers utilitaires
  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // --- Profil ---
  Future<ChefEscaleProfile?> getProfile(String token) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/profile'), headers: _headers(token));
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}'); // ← ajoute ça
    if (response.statusCode == 200) return ChefEscaleProfile.fromJson(jsonDecode(response.body));
  } catch (e) { print('ERREUR PROFILE: $e'); }
  return null;
  }


    // ═══════════════════════════════════════════════════════════════
   // Gestion des EQUIPEs
  // ═══════════════════════════════════════════════════════════════
  
  Future<EquipeModel?> createEquipe(
  String token,
  int shiftId,
  String matriculeEquipe,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipes').replace(
          queryParameters: {
            'shiftId': shiftId.toString(),
            'matriculeEquipe': matriculeEquipe,
          },
        ),
        headers: _headers(token),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return EquipeModel.fromJson(
          jsonDecode(response.body),
        );
      }
    } catch (e) {
      print('Create equipe error: $e');
    }

    return null;
  }

  Future<EquipeModel?> updateEquipe(
  String token,
  int equipeId,
  String matricule,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/equipes/$equipeId').replace(
          queryParameters: {
            'matricule': matricule,
          },
        ),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        return EquipeModel.fromJson(
          jsonDecode(response.body),
        );
      }
    } catch (e) {
      print('Update equipe error: $e');
    }

    return null;
  }
  
  Future<bool> deleteEquipe(
  String token,
  int equipeId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/equipes/$equipeId'),
        headers: _headers(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete equipe error: $e');
      return false;
    }
  }

  Future<EquipeModel?> getEquipeById(
  String token,
  int equipeId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipes/$equipeId'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        return EquipeModel.fromJson(
          jsonDecode(response.body),
        );
      }

      // gestion des erreurs métier
      if (response.statusCode == 403) {
        print("Accès refusé : équipe non autorisée");
        return null;
      }

      if (response.statusCode == 404) {
        print("Équipe introuvable");
        return null;
      }

    } catch (e) {
      print('Get equipe by id error: $e');
    }

    return null;
  }

  

    // ═══════════════════════════════════════════════════════════════
   // AFFECTATION PERSONNEL
  // ═══════════════════════════════════════════════════════════════
  
  // Récupérer les chefs d'équipes
  Future<List<PersonnelModel>> getChefsEquipes(
  String token,
  ) async {

    try {

      final response = await http.get(
        Uri.parse('$baseUrl/personnel/chefs-equipes'),
        headers: _headers(token),
      );


      if(response.statusCode == 200){

        List data = jsonDecode(response.body);


        return data
            .map((e)=>PersonnelModel.fromJson(e))
            .toList();

      }


    } catch(e){

      print(
        'Get chefs equipes error: $e'
      );

    }


    return [];

  }


  // Récupérer les employés
  Future<List<PersonnelModel>> getEmployes(
  String token,
  ) async {

    try {

      final response = await http.get(
        Uri.parse('$baseUrl/personnel/employes'),
        headers: _headers(token),
      );


      if(response.statusCode == 200){

        List data = jsonDecode(response.body);


        return data
            .map((e)=>PersonnelModel.fromJson(e))
            .toList();

      }


    } catch(e){

      print(
        'Get employes error: $e'
      );

    }


    return [];

  }


  Future<bool> assignPersonnel(
  String token,
  int equipeId,
  int personnelId,
  String roleMetier,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/equipes/$equipeId/assign-personnel',
        ).replace(
          queryParameters: {
            'personnelId': personnelId.toString(),
            'roleMetier': roleMetier,
          },
        ),
        headers: _headers(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Assign personnel error: $e');
      return false;
    }
  }

  Future<bool> assignChefEquipe(
  String token,
  int equipeId,
  int chefEquipeId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/equipes/$equipeId/assign-chef-equipe',
        ).replace(
          queryParameters: {
            'chefEquipeId': chefEquipeId.toString(),
          },
        ),
        headers: _headers(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Assign chef equipe error: $e');
      return false;
    }
  }

  //=============================================

  Future<List<EquipeModel>?> getMyEquipes(String token) async {
  try {
    final url = Uri.parse('$baseUrl/equipes/chef');
    print('🔍 URL equipes: $url');
    print('🔑 Token début: ${token.length > 50 ? token.substring(0, 50) : token}');

    final response = await http.get(url, headers: _headers(token));

    print('📡 Status equipes: ${response.statusCode}');
    print('📦 Body equipes: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => EquipeModel.fromJson(e)).toList();
    }

  } catch (e) {
    print('❌ Get my equipes error: $e');
  }

  return null;
}

Future<List<ShiftModel>> getActiveShifts(String token) async {
  try {
    final url = Uri.parse('$baseUrl/shift/active');
    print('🔍 URL shifts: $url');

    final response = await http.get(url, headers: _headers(token));

    print('📡 Status shifts: ${response.statusCode}');
    print('📦 Body shifts: ${response.body}');

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => ShiftModel.fromJson(e)).toList();
    }
  } catch (e) {
    print('❌ Get active shifts error: $e');
  }

  return [];
}

    // ═══════════════════════════════════════════════════════════════
   // SHIFT MANAGEMENT
  // ═══════════════════════════════════════════════════════════════
  
  Future<bool> assignEquipeToShift(
  String token,
  int equipeId,
  int shiftId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/equipes/$equipeId/assign-equipe-shift',
        ).replace(
          queryParameters: {
            'shiftId': shiftId.toString(),
          },
        ),
        headers: _headers(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Assign equipe to shift error: $e');
      return false;
    }
  }

  Future<bool> removeEquipeFromShift(
  String token,
  int equipeId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/equipes/$equipeId/remove-equipe-shift',
        ),
        headers: _headers(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Remove equipe from shift error: $e');
      return false;
    }
  }

    // ═══════════════════════════════════════════════════════════════
   // SHIFT HISTORY
  // ═══════════════════════════════════════════════════════════════
  
  Future<List<HistoriqueShiftModel>> getMyShiftHistory(
  String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shifts/history'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map((e) => HistoriqueShiftModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Shift history error: $e');
    }

    return [];
  }

    // ═══════════════════════════════════════════════════════════════
   // Statistiques 
  // ═══════════════════════════════════════════════════════════════
  
  Future<ChefEscaleDashboardStats?> getDashboard(String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return ChefEscaleDashboardStats.fromJson(
        jsonDecode(response.body),
      );
    }
  } catch (e) {
    print('Dashboard error: $e');
  }
  return null;
  }

    // ═══════════════════════════════════════════════════════════════
   // Calendrier
  // ═══════════════════════════════════════════════════════════════
  
  Future<List<EquipeModel>> getCalendar(
  String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/calendar'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map((e) => EquipeModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Calendar error: $e');
    }

    return [];
  }
    
}