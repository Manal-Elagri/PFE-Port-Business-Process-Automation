import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final String token;

  const HistoryScreen({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
      ),
      body: const Center(
        child: Text(
          "Bienvenue dans l'historique",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}