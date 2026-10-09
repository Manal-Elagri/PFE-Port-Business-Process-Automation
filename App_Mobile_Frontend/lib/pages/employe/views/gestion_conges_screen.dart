import 'package:flutter/material.dart';

class GestionCongesScreen extends StatelessWidget {
  final String token;

  const GestionCongesScreen({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des congés"),
      ),
      body: const Center(
        child: Text(
          "Bienvenue dans la gestion des congés",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}