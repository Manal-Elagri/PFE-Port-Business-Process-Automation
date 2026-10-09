import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
class RegisterService {
  static const String baseUrl = ApiConfig.registerUrl;

  Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path, 
          contentType: MediaType('image', 'jpeg')));
      var response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) return jsonDecode(response.body)['imageUrl'];
    } catch (e) { print("Erreur upload: $e"); }
    return null;
  }

  // Modifié pour retourner la Map de la réponse (contenant le codeReference)
  Future<Map<String, dynamic>?> createRegistrationRequest({
    required String imageURL, required String nom, required String prenom,
    required String telephone, required String cin, required String password,
    required String role, String? email,
  }) async {
    try {
      final params = {
        'imageURL': imageURL, 'nom': nom, 'prenom': prenom, 'telephone': telephone,
        'cin': cin, 'password': password, 'role': role,
      };
      if (email != null) params['email'] = email;

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.post(uri);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) { print("Erreur creation: $e"); }
    return null;
  }

  // Rechercher une demande
  Future<Map<String, dynamic>?> getRequestByReference(String code) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reference/$code'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print("Erreur recherche: $e"); }
    return null;
  }

  // Supprimer/Annuler une demande
  Future<bool> cancelRequest(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}