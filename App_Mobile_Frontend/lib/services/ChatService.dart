import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // L'adresse IP de ton micro-service Python (FastAPI)
  final String pythonBaseUrl = "127.0.0.1"; // 10.0.2.2 pour l'émulateur Android vers localhost
  final String serviceApiKey = "marsa_maroc_2026_secret"; // Ta X-API-Key

  Future<String> sendMessageToAI(String userMessage, String jwtToken) async {
  final url = Uri.parse('http://10.0.2.2:8002/v1/generate');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'X-API-Key': 'marsa_maroc_2026_secret',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode({
      'input_type': 'text',         // Défini dans ton schéma Python
      'content': userMessage,       // Défini dans ton schéma Python
      'provider': 'gemini',         // Optionnel (selon ton ProviderName)
      'temperature': 0.7            // Optionnel
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['formatted_response']; // La clé correcte
  } else {
    return "Erreur lors de la communication avec l'IA.";
  }
  }
}