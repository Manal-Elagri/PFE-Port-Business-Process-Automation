import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  static const Color brandBlue = Color(0xFF2046E3);

  void _handleReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      String? error = await AuthService().resetPassword(
        _tokenController.text.trim().toUpperCase(), 
        _passController.text.trim()
      );

      setState(() => _isLoading = false);

      if (error == null) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text("Mot de passe modifié avec succès !", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("Se connecter maintenant", style: TextStyle(fontWeight: FontWeight.bold, color: brandBlue)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.security_rounded, size: 80, color: brandBlue),
              const SizedBox(height: 20),
              const Text("Réinitialisation", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text("Veuillez saisir le code reçu par email et votre nouveau mot de passe.", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 40),

              // Champ Token
              TextFormField(
                controller: _tokenController,
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                decoration: _inputStyle("Code de sécurité (8 caractères)", Icons.vpn_key_outlined),
                validator: (v) => v!.length != 8 ? "Le code doit contenir 8 caractères" : null,
              ),
              const SizedBox(height: 20),

              // Champ Password
              TextFormField(
                controller: _passController,
                obscureText: _isObscure,
                decoration: _inputStyle("Nouveau mot de passe", Icons.lock_outline_rounded, true),
                validator: (v) => v!.length < 6 ? "Minimum 6 caractères" : null,
              ),
              const SizedBox(height: 20),

              // Champ Confirmation
              TextFormField(
                controller: _confirmPassController,
                obscureText: _isObscure,
                decoration: _inputStyle("Confirmer le mot de passe", Icons.lock_reset_rounded, true),
                validator: (v) => v != _passController.text ? "Les mots de passe ne correspondent pas" : null,
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(backgroundColor: brandBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Mettre à jour", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon, [bool isPass = false]) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: brandBlue),
      suffixIcon: isPass ? IconButton(
        icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
        onPressed: () => setState(() => _isObscure = !_isObscure),
      ) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}