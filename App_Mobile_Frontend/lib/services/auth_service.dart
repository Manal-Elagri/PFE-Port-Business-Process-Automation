import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/auth_model.dart';
import '../config/api_config.dart'; 


class AuthService {
  static const String baseUrl = ApiConfig.authUrl;
  StreamSubscription<String>? _fcmRefreshSub;

  Future<AuthResponse?> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": identifier,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        
        // 🔥 TRÈS IMPORTANT : Une fois connecté, on synchronise le Token FCM
        await syncFcmToken(authResponse.token); 
        
        return authResponse;
      } else {
        return null;
      }
    } catch (e) {
      print("Erreur de connexion: $e");
      return null;
    }
  }

  // --- FORGOT PASSWORD (Envoi du mail) ---
  Future<String?> sendForgotPasswordEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return null; 
      return data['error'] ?? "Une erreur est survenue"; 
    } catch (e) { return "Erreur de connexion au serveur"; }
  }

  // --- RESET PASSWORD (Changement final) ---
  Future<String?> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "newPassword": newPassword}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return null; 
      return data['error'] ?? "Code invalide ou expiré";
    } catch (e) { return "Erreur de connexion au serveur"; }
  }

  // --- SYNCHRONISATION DU TOKEN FCM ---
  Future<void> syncFcmToken(String jwtToken) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 1. Demander la permission
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Récupérer le Token unique
        String? token = await messaging.getToken();
        
        if (token != null) {
          print("FCM Token généré : $token");

          // 3. Envoyer au Backend Java (On utilise baseUrl/me/fcm-token)
          final response = await http.put(
            Uri.parse('$baseUrl/me/fcm-token'), 
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $jwtToken",
            },
            body: jsonEncode({"token": token}),
          );

          if (response.statusCode == 200) {
            print("✅ Succès : Token FCM enregistré côté serveur");
          } else {
            print("❌ Erreur enregistrement Token : ${response.statusCode}");
          }
        }
      }
    } catch (e) {
      print("Erreur lors de la synchronisation FCM : $e");
    }
  }

  Future<void> registerFcmToken(String jwtToken) async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final fcmToken = await messaging.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        print('FCM token null');
        return;
      }

      print('FCM TOKEN: $fcmToken');

      await updateFcmToken(
        jwtToken: jwtToken,
        fcmToken: fcmToken,
      );

      _fcmRefreshSub?.cancel();
      _fcmRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(
        (newToken) async {
          await updateFcmToken(
            jwtToken: jwtToken,
            fcmToken: newToken,
          );
        },
      );
    } catch (e) {
      print('Erreur synchronisation FCM: $e');
    }
  }

  Future<void> updateFcmToken({
    required String jwtToken,
    required String fcmToken,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/users/fcm-token'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fcmToken': fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      print('Token FCM enregistré côté backend');
    } else {
      print('Erreur FCM ${response.statusCode}: ${response.body}');
    }
  }

  



}