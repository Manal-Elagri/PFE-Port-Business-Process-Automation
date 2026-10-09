import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_links/app_links.dart';

import 'pages/home_page.dart';
import 'pages/signature/document_signature_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp();
    print("Firebase Mobile initialisé");
  } catch (e) {
    print("Erreur Firebase: $e");
  }

  await initializeDateFormatting('fr_FR', null);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialLink = await _appLinks.getInitialLink();

      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      _linkSub = _appLinks.uriLinkStream.listen(_handleDeepLink);
    } catch (e) {
      print('Erreur deep link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'pfeapp' && uri.host == 'document-signature') {
      final documentId = int.tryParse(uri.queryParameters['documentId'] ?? '');
      final token = uri.queryParameters['token'];

      if (documentId == null || token == null || token.isEmpty) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => DocumentSignatureScreen(
              documentId: documentId,
              token: token,
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MARSA MAROC – TCR Casablanca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B42C4)),
        useMaterial3: true,
      ),
      home: const PublicHomePage(),
    );
  }
}