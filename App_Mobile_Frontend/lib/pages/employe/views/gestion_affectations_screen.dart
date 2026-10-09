import 'package:flutter/material.dart';

class GestionAffectationsScreen extends StatelessWidget {
  final String token;

  const GestionAffectationsScreen({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Affectations"),
      ),
      body: const Center(
        child: Text(
          "Bienvenue dans la gestion des affectations",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}