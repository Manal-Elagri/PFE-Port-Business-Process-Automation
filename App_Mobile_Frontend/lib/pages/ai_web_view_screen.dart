import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/api_config.dart';

class AiWebViewScreen extends StatefulWidget {
  final String role;

  const AiWebViewScreen({
    super.key,
    required this.role,
  });

  @override
  State<AiWebViewScreen> createState() => _AiWebViewScreenState();
}

class _AiWebViewScreenState extends State<AiWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final uri = Uri.parse(ApiConfig.aiWebUrl).replace(
      queryParameters: {
        'embedded': '1',
        'panel': 'chat',
        'role': widget.role,
      },
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF212121))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),


        onPageFinished: (_) async {
        setState(() => _isLoading = false);

        await Future.delayed(const Duration(milliseconds: 300));

        await _controller.runJavaScript("""
    localStorage.setItem('service_api_key', 'marsa_maroc_2026_secret');
    window.FLUTTER_API_KEY = 'marsa_maroc_2026_secret';

    // 🔥 AJOUT JWT ICI
    localStorage.setItem('jwt_token', '$widget.token');

    const input = document.getElementById('api-key');
    if (input) input.value = 'marsa_maroc_2026_secret';
""");
        },

          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(uri);
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        title: const Text('Assistant IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}