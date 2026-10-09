import 'package:flutter/material.dart';
// Assure-toi que ces fichiers existent, sinon crée des fichiers vides temporaires
import 'operations/engins_screen.dart';
import 'operations/navires_screen.dart';
import 'operations/postes_screen.dart';
import 'operations/portiers_screen.dart';
import 'operations/escales_screen.dart';


// --- DÉFINITION DES COULEURS DIRECTEMENT DANS LE FICHIER ---
class _LocalColors {
  static const primary      = Color(0xFF1B42C4);
  static const surface      = Color(0xFFF4F7FF);
  static const card         = Colors.white;
  static const textPrimary  = Color(0xFF0A1628);
  static const divider      = Color(0xFFE0E8FF);
  
  // Couleurs des icônes
  static const engins       = Color(0xFFF0A500); // Orange
  static const navires      = Color(0xFF1B42C4); // Bleu
  static const postes       = Color(0xFF00A86B); // Vert
  static const portiers     = Color(0xFF534AB7); // Violet
  static const escales      = Color(0xFF0097C7); // Cyan
}


class OperationsScreen extends StatelessWidget {
  final String token;

  const OperationsScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      

      // ───────── APP BAR ─────────
     

      // ───────── BODY ─────────
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            context,
            title: "Engins",
            icon: Icons.engineering_rounded,
            color: _LocalColors.engins,
            screen: EnginsScreen(token: token),
          ),

          _tile(
            context,
            title: "Navires",
            icon: Icons.directions_boat_rounded,
            color: _LocalColors.navires,
            screen: NaviresScreen(token: token),
          ),

          _tile(
            context,
            title: "Postes",
            icon: Icons.local_shipping_rounded,
            color: _LocalColors.postes,
            screen: PostesScreen(token: token),
          ),

          _tile(
            context,
            title: "Portiers",
            icon: Icons.security_rounded,
            color: _LocalColors.portiers,
            screen: PortiersScreen(token: token),
          ),

          _tile(
            context,
            title: "Escales",
            icon: Icons.anchor_rounded,
            color: _LocalColors.escales,
            screen: EscalesScreen(token: token),
          ),
        ],
      ),
    );
  }

  // ───────── TILE UI ─────────
  Widget _tile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _LocalColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            )
          ],
          border: Border.all(
            color: _LocalColors.divider.withOpacity(0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _LocalColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}