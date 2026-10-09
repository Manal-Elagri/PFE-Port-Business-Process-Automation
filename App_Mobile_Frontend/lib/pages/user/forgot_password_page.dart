import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'reset_password_page.dart'; // Nécessaire pour la suite

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  static const Color brandBlue = Color(0xFF2046E3);

  void _handleSendEmail() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);

    String? error = await AuthService().sendForgotPasswordEmail(_emailController.text.trim());
    
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code envoyé ! Vérifiez vos emails."), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Icon(Icons.mail_lock_rounded, size: 100, color: brandBlue),
            const SizedBox(height: 24),
            const Text("Récupération", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Entrez votre email professionnel pour recevoir le code à 8 caractères.", 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Adresse Email",
                prefixIcon: const Icon(Icons.email_outlined, color: brandBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendEmail,
                style: ElevatedButton.styleFrom(backgroundColor: brandBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Recevoir le code", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}