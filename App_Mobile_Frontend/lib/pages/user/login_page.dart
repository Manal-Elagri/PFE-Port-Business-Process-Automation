import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_page.dart';
import '../consult_demandes_page.dart';
import 'forgot_password_page.dart'; 
import '../../models/auth_model.dart'; 
import '../admin/admin_dashboard_page.dart';
import '../chef_escale/chef_escale_dashboard_page.dart';
import '../employe/employe_dashboard.dart';
import '../../chef-division/views/chef_division_dashboard_screen.dart';

import '../../chef-service/views/chef_service_dashboard_screen.dart';



class AuthLoginPage extends StatefulWidget {
  final String selectedCategory; // "Administrateur", "Responsable" ou "Personnel"

  const AuthLoginPage({super.key, required this.selectedCategory});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Votre couleur référence
  static const Color brandBlue = Color(0xFF2046E3);

  IconData _getCategoryIcon() {
    switch (widget.selectedCategory) {
      case 'Administrateur': return Icons.admin_panel_settings_rounded;
      case 'Responsable': return Icons.assignment_ind_rounded;
      default: return Icons.engineering_rounded;
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final result = await AuthService().login(
        _idController.text,
        _passController.text,
      );

      setState(() => _isLoading = false);

      if (result != null) {
        String userRole = result.role; // Récupère "ADMIN" depuis le backend

        // Vérification de la cohérence Catégorie choisie / Rôle réel
        if (widget.selectedCategory == 'Administrateur' && userRole == 'ADMIN') {
          // ON ENVOIE L'OBJET RESULT COMPLET
          _navigateToAdminDashboard(result);
        } 
        else if (widget.selectedCategory == 'Responsable' && userRole.startsWith('CHEF_')) {
          _navigateToResponsableDashboard(result, userRole);
        }
        else if (widget.selectedCategory == 'Personnel' && userRole == 'EMPLOYE') {
          _navigateToEmployeDashboard(result, userRole);
        } 
        else {
          _showError("Accès refusé : rôle $userRole non autorisé ici.");
        }
      } else {
        _showError("Identifiants incorrects ou serveur injoignable.");
      }
    }
  }

  void _navigateToEmployeDashboard(AuthResponse auth, String role) {

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text("Bienvenue dans l'espace Employé"),
      backgroundColor: brandBlue,
    ),
  );


  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => EmployeDashboardScreen(
        token: auth.token,
      ),
    ),
  );
}

  // NOUVELLE FONCTION DE NAVIGATION
  void _navigateToAdminDashboard(AuthResponse auth) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bienvenue dans l'espace Admin"), backgroundColor: brandBlue),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AdminDashboardPage(
          token: auth.token, // On passe le vrai token reçu du serveur
        ),
      ),
    );
  }

  void _navigateToResponsableDashboard(AuthResponse auth, String role) {
  final label = _roleFriendlyName(role);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Bienvenue dans l'espace $label"),
      backgroundColor: brandBlue,
    ),
  );

  Widget screen;

  switch (role) {
    case 'CHEF_ESCALE':
      screen = ChefEscaleDashboardScreen(token: auth.token);
      break;
    // Ajoutez d'autres rôles ici au besoin :
     case 'CHEF_DIVISION':
       screen = ChefDivisionDashboardScreen(token: auth.token);
       break;
     case 'CHEF_SERVICE':
       screen = ChefServiceDashboardScreen(token: auth.token);
       break;
    default:
      _showError("Espace $label en développement");
      return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
  }

  String _roleFriendlyName(String role) {
    switch (role) {
      case 'CHEF_ESCALE':    return 'Chef d\'escale';
      case 'CHEF_DIVISION':  return 'Chef de division';
      case 'CHEF_SERVICE':   return 'Chef de service';
      default:               return role;
    }
  }

  void _navigateToDashboard(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bienvenue dans l'espace $type"), backgroundColor: brandBlue),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        leading: const BackButton(color: Color(0xFF0A1628))
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // --- SECTION LOGO ET TITRES CENTRÉS ---
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: brandBlue.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getCategoryIcon(), size: 70, color: brandBlue),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Connexion",
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.w900, 
                          color: Color(0xFF0A1628),
                          letterSpacing: -0.5
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Espace ${widget.selectedCategory}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16, 
                          color: Colors.grey.shade600, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // --- FORMULAIRE ---
                TextFormField(
                  controller: _idController,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: "Email ou CIN",
                    labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: brandBlue),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: brandBlue, width: 2),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? "Identifiant requis" : null,
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _passController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: brandBlue),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: brandBlue, width: 2),
                    ),
                  ),
                  validator: (value) => value!.length < 4 ? "Mot de passe trop court" : null,
                ),
                
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // NAVIGATION VERS LA NOUVELLE PAGE
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  ForgotPasswordPage()),
                              );
                            }, 
                            child: const Text(
                              "Mot de passe oublié ?", 
                              style: TextStyle(color: brandBlue, fontWeight: FontWeight.bold, fontSize: 13)
                            ),
                          ),
                        ),
                
                const SizedBox(height: 30),
                
                // --- BOUTON DE CONNEXION ---
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: brandBlue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Se connecter", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                  ),
                ),

                // --- FOOTER INSCRIPTION ---
                if (widget.selectedCategory != 'Administrateur') ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Pas encore de compte ? ", style: TextStyle(color: Colors.grey.shade600)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(category: widget.selectedCategory),
                              ),
                            );
                          },
                          child: const Text(
                            "Créer un compte", 
                            style: TextStyle(color: brandBlue, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60), // Espace avant le bouton de suivi

                  // --- BOUTON SUIVI DE DEMANDE (EN BAS À GAUCHE) ---
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConsultDemandesPage()),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: brandBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: brandBlue.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Suivre mes demandes", 
                              style: TextStyle(
                                color: brandBlue, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 13
                              )
                            ),
                            const SizedBox(width: 8),
                            // Icône flèche stylisée
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: brandBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded, 
                                color: Colors.white, 
                                size: 14
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}