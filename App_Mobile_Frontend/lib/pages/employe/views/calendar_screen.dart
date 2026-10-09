import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  final String token;

  const CalendarScreen({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendrier"),
      ),
      body: const Center(
        child: Text(
          "Bienvenue dans le calendrier",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}