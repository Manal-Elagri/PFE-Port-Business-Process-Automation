import 'package:flutter/material.dart';
import '../../../services/admin_service.dart';
import '../../../models/admin_models.dart';

class DashboardSummaryView extends StatelessWidget {
  final String token;
  final Function(String) onNavigate;

  const DashboardSummaryView({super.key, required this.token, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GlobalStats?>(
      future: AdminApiService().getStats(token),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final s = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Statistiques réelles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _statCard("Personnel", s.totalPersonnels.toString(), Icons.groups, Colors.blue),
                  _statCard("Demandes", s.demandesEnAttente.toString(), Icons.pending_actions, Colors.orange),
                  _statCard("Shifts", s.shiftsActifs.toString(), Icons.sync, Colors.green),
                  _statCard("Congés", s.employesEnConge.toString(), Icons.beach_access, Colors.red),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Actions Rapides", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _quickAction("Valider les nouveaux comptes", "Vous avez ${s.demandesEnAttente} demandes", Icons.person_add, () => onNavigate("requests")),
              _quickAction("Gérer le parc d'engins", "Suivi de l'état technique", Icons.construction, () => onNavigate("engines")),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String t, String v, IconData i, Color c) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, color: c, size: 20),
          const Spacer(),
          Text(v, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(t, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _quickAction(String t, String s, IconData i, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(i, color: const Color(0xFF1B42C4)),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(s, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}