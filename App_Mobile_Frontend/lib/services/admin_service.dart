import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_models.dart';
import '../config/api_config.dart';

class AdminApiService {
  static const String baseUrl = ApiConfig.adminUrl;

  // Headers utilitaires
  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // --- Profil ---
  Future<AdminProfile?> getProfile(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile'), headers: _headers(token));
      if (response.statusCode == 200) return AdminProfile.fromJson(jsonDecode(response.body));
    } catch (e) { print(e); }
    return null;
  }

  // --- Statistiques ---
  Future<GlobalStats?> getStats(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats/dashboard'), headers: _headers(token));
      if (response.statusCode == 200) return GlobalStats.fromJson(jsonDecode(response.body));
    } catch (e) { print(e); }
    return null;
  }

  // --- Gestion des Demandes ---
  Future<List<DemandeInscription>> getPendingRequests(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/demandes/pending'), headers: _headers(token));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => DemandeInscription.fromJson(e)).toList();
      }
    } catch (e) { print(e); }
    return [];
  }

  Future<List<DemandeInscription>> getAllRequests(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/demandes'), headers: _headers(token));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => DemandeInscription.fromJson(e)).toList();
      }
    } catch (e) { print(e); }
    return [];
  }

  Future<bool> approveRequest(String token, int id) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/demandes/approve/$id'), headers: _headers(token));
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> rejectRequest(String token, int id) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/demandes/reject/$id'), headers: _headers(token));
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

   // --- 3. GESTION DU PERSONNEL ---
  Future<List<PersonnelModel>> getPersonnelByRole(String token, String endpoint) async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/personnel/$endpoint'), headers: _headers(token));
      if (r.statusCode == 200) {
        List data = jsonDecode(r.body);
        return data.map((e) => PersonnelModel.fromJson(e)).toList();
      }
    } catch (e) { print(e); }
    return [];
  }

  Future<bool> deletePersonnel(String token, int id) async {
    final r = await http.delete(Uri.parse('$baseUrl/$id'), headers: _headers(token));
    return r.statusCode == 200;
  }

  Future<bool> updatePersonnel(String token, int id, Map<String, dynamic> body) async {
    final r = await http.put(Uri.parse('$baseUrl/$id'), headers: _headers(token), body: jsonEncode(body));
    return r.statusCode == 200;
  }

  

   
  // ─── PLANNINGS ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> createPlanning(String token, String date) async {
    final r = await http.post(Uri.parse('$baseUrl/planning').replace(queryParameters: {'date': date}), headers: _headers(token));
    return (r.statusCode == 200 || r.statusCode == 201) ? jsonDecode(r.body) : null;
  }

  Future<bool> updatePlanning(String token, int id, String date) async {
    final r = await http.put(Uri.parse('$baseUrl/planning/$id').replace(queryParameters: {'date': date}), headers: _headers(token));
    return r.statusCode == 200;
  }

  Future<bool> deletePlanning(String token, int id) async {
    final r = await http.delete(Uri.parse('$baseUrl/planning/$id'), headers: _headers(token));
    return r.statusCode == 200;
  }

  // ─── SHIFTS ─────────────────────────────────────────────────────────────
  
  Future<bool> createShift(String token, int planningId, String type, String debut, String fin) async {
    final r = await http.post(Uri.parse('$baseUrl/shift').replace(queryParameters: {
      'planningId': planningId.toString(), 'typeShift': type, 'heureDebut': debut, 'heureFin': fin,
    }), headers: _headers(token));
    return r.statusCode == 200;
  }

  Future<bool> updateShift(String token, int id, String debut, String fin) async {
    final r = await http.put(Uri.parse('$baseUrl/shift/$id').replace(queryParameters: {'heureDebut': debut, 'heureFin': fin}), headers: _headers(token));
    return r.statusCode == 200;
  }

  Future<bool> assignManagers(String token, int shiftId, int chefS, int chefD) async {
    final r = await http.put(Uri.parse('$baseUrl/shift/assign').replace(queryParameters: {
      'shiftId': shiftId.toString(), 'chefServiceId': chefS.toString(), 'chefDivisionId': chefD.toString(),
    }), headers: _headers(token));
    return r.statusCode == 200;
  }

  Future<bool> deleteShift(String token, int id) async {
    final r = await http.delete(Uri.parse('$baseUrl/shift/$id'), headers: _headers(token));
    return r.statusCode == 200;
  }

  Future<ShiftModel?> getShiftById(String token, int id) async {
  try {
    final r = await http.get(
      Uri.parse('$baseUrl/shift/$id'),
      headers: _headers(token),
    );
    if (r.statusCode == 200) return ShiftModel.fromJson(jsonDecode(r.body));
  } catch (e) { print(e); }
  return null;
  }

  // ─── SECTION HISTORIQUES (MAPPING COMPLET DU CONTROLLER) ────────────────

  // 1. Historique d'une équipe spécifique : GET /history/equipe/{id}
  Future<List<dynamic>> getEquipeHistory(String token, int equipeId) async {
    try {
      final r = await http.get(
        Uri.parse('$baseUrl/history/equipe/$equipeId'),
        headers: _headers(token),
      );
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) {
      print("Erreur historique équipe: $e");
    }
    return [];
  }

  // 2. Historique d'un shift spécifique : GET /history/shift/{id}
  Future<List<dynamic>> getShiftHistory(String token, int shiftId) async {
    try {
      final r = await http.get(
        Uri.parse('$baseUrl/history/shift/$shiftId'),
        headers: _headers(token),
      );
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) {
      print("Erreur historique shift: $e");
    }
    return [];
  }

  // 3. Tous les historiques (Global) : GET /history/all
  Future<List<dynamic>> getAllHistory(String token) async {
    try {
      final r = await http.get(
        Uri.parse('$baseUrl/history/all'),
        headers: _headers(token),
      );
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) {
      print("Erreur historique global: $e");
    }
    return [];
  }

  Future<List<ShiftModel>> getShiftsByPlanning(String token, int planningId) async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/planning/$planningId/shifts'), headers: _headers(token));
      if (r.statusCode == 200) {
        List data = jsonDecode(r.body);
        return data.map((e) => ShiftModel.fromJson(e)).toList();
      }
    } catch (e) { print(e); }
    return [];
  }

  // Récupérer tous les plannings
  Future<List<Map<String, dynamic>>> getAllPlannings(String token) async {
  try {
    final r = await http.get(
      Uri.parse('$baseUrl/planning'),
      headers: _headers(token),
    );
    print('=== PLANNINGS STATUS: ${r.statusCode} ===');
    print('=== PLANNINGS BODY: ${r.body} ===');
    if (r.statusCode == 200) {
      List data = jsonDecode(r.body);
      return data.cast<Map<String, dynamic>>();
    }
  } catch (e) { print('Erreur plannings: $e'); }
  return [];
}

// ═══════════════════════════════════════════════════════════════
// ENGINS
// ═══════════════════════════════════════════════════════════════

Future<EnginModel?> createEngin(
  String token,
  String type,
  String etat,
  double capacite,
) async {
  try {
    final r = await http.post(
      Uri.parse('$baseUrl/engins').replace(
        queryParameters: {
          'type': type,
          'etat': etat,
          'capacite': capacite.toString(),
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200 || r.statusCode == 201) {
      return EnginModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Create engin error: $e');
  }
  return null;
}

Future<EnginModel?> updateEngin(
  String token,
  int id,
  String etat,
) async {
  try {
    final r = await http.put(
      Uri.parse('$baseUrl/engins/$id').replace(
        queryParameters: {
          'etat': etat,
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200) {
      return EnginModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Update engin error: $e');
  }
  return null;
}

Future<bool> deleteEngin(
  String token,
  int id,
) async {
  try {
    final r = await http.delete(
      Uri.parse('$baseUrl/engins/$id'),
      headers: _headers(token),
    );

    return r.statusCode == 200;
  } catch (e) {
    print('Delete engin error: $e');
    return false;
  }
}

// --- GESTION DES ENGINS ---
  Future<List<EnginModel>> getEngins(String token) async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/engins'), headers: _headers(token));
      if (r.statusCode == 200) {
        List data = jsonDecode(r.body);
        return data.map((e) => EnginModel.fromJson(e)).toList();
      }
    } catch (e) { print(e); }
    return [];
  }



// ═══════════════════════════════════════════════════════════════
// POSTES
// ═══════════════════════════════════════════════════════════════

Future<PosteModel?> createPoste(
  String token,
  int numero,
  String localisation,
  double latitude,
  double longitude,
) async {
  try {
    final r = await http.post(
      Uri.parse('$baseUrl/postes').replace(
        queryParameters: {
          'numero': numero.toString(),
          'localisation': localisation,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200 || r.statusCode == 201) {
      return PosteModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Create poste error: $e');
  }
  return null;
}

Future<PosteModel?> updatePoste(
  String token,
  int id,
  int numero,
  String localisation,
  double latitude,
  double longitude,
) async {
  try {
    final r = await http.put(
      Uri.parse('$baseUrl/postes/$id').replace(
        queryParameters: {
          'numero': numero.toString(),
          'localisation': localisation,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200) {
      return PosteModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Update poste error: $e');
  }
  return null;
}

Future<bool> deletePoste(
  String token,
  int id,
) async {
  try {
    final r = await http.delete(
      Uri.parse('$baseUrl/postes/$id'),
      headers: _headers(token),
    );

    return r.statusCode == 200;
  } catch (e) {
    print('Delete poste error: $e');
    return false;
  }
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
    print('Get postes error: $e');
  }

  return [];
}

// ═══════════════════════════════════════════════════════════════
// PORTIERS
// ═══════════════════════════════════════════════════════════════

Future<PortierModel?> createPortier(
  String token,
  String code,
  int nombreCameras,
) async {
  try {
    final r = await http.post(
      Uri.parse('$baseUrl/portiers').replace(
        queryParameters: {
          'code': code,
          'nombreCameras': nombreCameras.toString(),
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200 || r.statusCode == 201) {
      return PortierModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Create portier error: $e');
  }
  return null;
}

Future<PortierModel?> updatePortier(
  String token,
  int id,
  int nombreCameras,
) async {
  try {
    final r = await http.put(
      Uri.parse('$baseUrl/portiers/$id').replace(
        queryParameters: {
          'nombreCameras': nombreCameras.toString(),
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200) {
      return PortierModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Update portier error: $e');
  }
  return null;
}

Future<bool> deletePortier(
  String token,
  int id,
) async {
  try {
    final r = await http.delete(
      Uri.parse('$baseUrl/portiers/$id'),
      headers: _headers(token),
    );

    return r.statusCode == 200;
  } catch (e) {
    print('Delete portier error: $e');
    return false;
  }
}

Future<List<PortierModel>> getAllPortiers(
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
    print('Get portiers error: $e');
  }

  return [];
}

// ═══════════════════════════════════════════════════════════════
// NAVIRES
// ═══════════════════════════════════════════════════════════════

Future<NavireModel?> createNavire(
  String token,
  String nom,
  String numeroIMO,
) async {
  try {
    final r = await http.post(
      Uri.parse('$baseUrl/navires').replace(
        queryParameters: {
          'nom': nom,
          'numeroIMO': numeroIMO,
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200 || r.statusCode == 201) {
      return NavireModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Create navire error: $e');
  }
  return null;
}

Future<NavireModel?> updateNavire(
  String token,
  int id,
  String nom,
  String numeroIMO,
) async {
  try {
    final r = await http.put(
      Uri.parse('$baseUrl/navires/$id').replace(
        queryParameters: {
          'nom': nom,
          'numeroIMO': numeroIMO,
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200) {
      return NavireModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Update navire error: $e');
  }
  return null;
}

Future<NavireModel?> getNavireById(
  String token,
  int id,
) async {
  try {
    final r = await http.get(
      Uri.parse('$baseUrl/navires/$id'),
      headers: _headers(token),
    );

    if (r.statusCode == 200) {
      return NavireModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Get navire error: $e');
  }
  return null;
}

Future<bool> deleteNavire(
  String token,
  int id,
) async {
  try {
    final r = await http.delete(
      Uri.parse('$baseUrl/navires/$id'),
      headers: _headers(token),
    );

    return r.statusCode == 200;
  } catch (e) {
    print('Delete navire error: $e');
    return false;
  }
}

Future<List<NavireModel>> getAllNavires(
  String token,
) async {
  try {
    final r = await http.get(
      Uri.parse('$baseUrl/navires'),
      headers: _headers(token),
    );

    if (r.statusCode == 200) {
      List data = jsonDecode(r.body);
      return data.map((e) => NavireModel.fromJson(e)).toList();
    }
  } catch (e) {
    print('Get navires error: $e');
  }

  return [];
}

// ═══════════════════════════════════════════════════════════════
// ESCALES
// ═══════════════════════════════════════════════════════════════

Future<EscaleModel?> createEscale(
  String token,
  String numeroEscale,
  String dateArrivee,
  String dateDepart,
  int navireId,
) async {
  try {
    final r = await http.post(
      Uri.parse('$baseUrl/escales').replace(
        queryParameters: {
          'numeroEscale': numeroEscale,
          'dateArrivee': dateArrivee,
          'dateDepart': dateDepart,
          'navireId': navireId.toString(),
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200 || r.statusCode == 201) {
      return EscaleModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Create escale error: $e');
  }
  return null;
}

Future<EscaleModel?> updateEscale(
  String token,
  int id,
  String numeroEscale,
  String dateArrivee,
  String dateDepart,
  int navireId,
) async {
  try {
    final r = await http.put(
      Uri.parse('$baseUrl/escales/$id').replace(
        queryParameters: {
          'numeroEscale': numeroEscale,
          'dateArrivee': dateArrivee,
          'dateDepart': dateDepart,
          'navireId': navireId.toString(),
        },
      ),
      headers: _headers(token),
    );

    if (r.statusCode == 200) {
      return EscaleModel.fromJson(jsonDecode(r.body));
    }
  } catch (e) {
    print('Update escale error: $e');
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
    print('Get escales error: $e');
  }

  return [];
}

Future<List<EscaleModel>> getEscalesByNavire(
  String token,
  int navireId,
) async {
  try {
    final r = await http.get(
      Uri.parse('$baseUrl/escales/navire/$navireId'),
      headers: _headers(token),
    );

    if (r.statusCode == 200) {
      List data = jsonDecode(r.body);
      return data.map((e) => EscaleModel.fromJson(e)).toList();
    }
  } catch (e) {
    print('Get escales by navire error: $e');
  }

  return [];
}

Future<bool> deleteEscale(
  String token,
  int id,
) async {
  try {
    final r = await http.delete(
      Uri.parse('$baseUrl/escales/$id'),
      headers: _headers(token),
    );

    return r.statusCode == 200;
  } catch (e) {
    print('Delete escale error: $e');
    return false;
  }
}

}