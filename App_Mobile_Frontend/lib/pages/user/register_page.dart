import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; // Import pour le crop
import 'package:flutter/services.dart';
import '../../services/register_service.dart';
import '../consult_demandes_page.dart';

class RegisterPage extends StatefulWidget {
  final String category;
  const RegisterPage({super.key, required this.category});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  bool _isLoading = false;
  
  // États de visibilité mot de passe
  bool _isObscurePass = true;
  bool _isObscureConfirm = true;

  // Contrôleurs
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController(); // Nouveau
  String? _selectedRole;

  static const Color brandBlue = Color(0xFF2046E3);

  final List<String> _rolesChefs = ['CHEF_EQUIPE', 'CHEF_ESCALE', 'CHEF_SERVICE', 'CHEF_DIVISION'];
  final List<String> _rolesEmployes = ['POINTEUR', 'OPERATEUR', 'OUVRIER', 'GRUTIER', 'TECHNICIEN', 'AGENT_CONTROLE'];

  // MÉTHODE PICKER + CROPPER
  Future<void> _pickAndCropImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Force le carré
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer la photo',
            toolbarColor: brandBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Recadrer'),
        ],
      );

      if (croppedFile != null) {
        setState(() => _imageFile = File(croppedFile.path));
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        _showError("Veuillez ajouter une photo de profil");
        return;
      }

      setState(() => _isLoading = true);
      final service = RegisterService();

      try {
        String? uploadedUrl = await service.uploadImage(_imageFile!);
        if (uploadedUrl != null) {
          final response = await service.createRegistrationRequest(
            imageURL: uploadedUrl,
            nom: _nomCtrl.text,
            prenom: _prenomCtrl.text,
            telephone: _telCtrl.text,
            cin: _cinCtrl.text,
            password: _passCtrl.text,
            role: _selectedRole!,
            email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
          );

          if (response != null && response['codeReference'] != null) {
            _showSuccessDialog(response['codeReference']);
          } else {
            _showError("Erreur : CIN ou Email déjà utilisé.");
          }
        }
      } catch (e) {
        _showError("Erreur de connexion.");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            const Text("Demande envoyée !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            const Text("Conservez ce code pour suivre votre dossier :", textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: brandBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: brandBlue.withOpacity(0.2))),
              child: Row(
                children: [
                  Expanded(child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, color: brandBlue))),
                  IconButton(icon: const Icon(Icons.copy, size: 18, color: brandBlue), onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code copié")));
                  }),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(backgroundColor: brandBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Retour à l'accueil", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isResponsable = widget.category == 'Responsable';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Inscription ${widget.category}"), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo picker centré
              Center(
                child: GestureDetector(
                  onTap: _pickAndCropImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: brandBlue.withOpacity(0.1),
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null ? const Icon(Icons.person, color: brandBlue, size: 40) : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: CircleAvatar(
                          radius: 18, backgroundColor: brandBlue,
                          child: Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              Row(
                children: [
                  Expanded(child: _buildField(_prenomCtrl, "Prénom", Icons.person_outline)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_nomCtrl, "Nom", Icons.person_outline)),
                ],
              ),
              _buildField(_telCtrl, "Téléphone", Icons.phone_android, keyboard: TextInputType.phone),
              _buildField(
                _emailCtrl,
                "Email ${isResponsable ? '' : '(Optionnel)'}",
                Icons.email_outlined,
                validator: (v) => isResponsable && (v == null || v.isEmpty) ? "L'email est requis" : null,
              ),
              _buildField(_cinCtrl, "CIN", Icons.badge_outlined),

              const Divider(height: 40),
              const Text("Sécurisation du compte", style: TextStyle(fontWeight: FontWeight.bold, color: brandBlue)),
              const SizedBox(height: 8),
              const Text("Le mot de passe doit contenir au moins 6 caractères.", style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 15),

              // Champ Mot de passe
              _buildPasswordField(_passCtrl, "Mot de passe", _isObscurePass, () {
                setState(() => _isObscurePass = !_isObscurePass);
              }),
              
              // Champ Confirmation
              _buildPasswordField(_confirmPassCtrl, "Confirmer le mot de passe", _isObscureConfirm, () {
                setState(() => _isObscureConfirm = !_isObscureConfirm);
              }, isConfirm: true),

              const SizedBox(height: 15),

              // Dropdown Rôles
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: "Fonction",
                  prefixIcon: const Icon(Icons.work_outline, color: brandBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                items: (isResponsable ? _rolesChefs : _rolesEmployes).map((role) {
                  return DropdownMenuItem(value: role, child: Text(role.replaceAll('_', ' ')));
                }).toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
                validator: (v) => v == null ? "Sélectionnez une fonction" : null,
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: brandBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Envoyer la demande", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultDemandesPage())),
                  child: const Text("Suivre une demande existante", style: TextStyle(color: brandBlue, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget champ texte standard
  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {TextInputType keyboard = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: hint, prefixIcon: Icon(icon, color: brandBlue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        validator: validator ?? (value) => value!.isEmpty ? "Requis" : null,
      ),
    );
  }

  // Widget champ mot de passe avec oeil
  Widget _buildPasswordField(TextEditingController ctrl, String hint, bool obscure, VoidCallback toggle, {bool isConfirm = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: const Icon(Icons.lock_outline, color: brandBlue),
          suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: toggle),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Requis";
          if (value.length < 6) return "Trop court (min 6)";
          if (isConfirm && value != _passCtrl.text) return "Ne correspond pas";
          return null;
        },
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }
}