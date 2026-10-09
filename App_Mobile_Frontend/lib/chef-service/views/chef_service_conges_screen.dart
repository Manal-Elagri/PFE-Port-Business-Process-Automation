import 'package:flutter/material.dart';
import '../../services/chef_service_service.dart';
import '../../models/chef_division_models.dart';
import '../../config/theme_config.dart';
import '../widgets/loading_widget.dart';
import '../widgets/stat_card.dart';

class ChefServiceCongesScreen extends StatelessWidget {
  final String token;
  const ChefServiceCongesScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Congés'),
        elevation: 0,
      ),
      body: FutureBuilder<CongeDashboard>(
        future: ChefServiceApiService().getCongeDashboard(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: LoadingWidget(message: 'Chargement congés...'));
          if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
          final d = snapshot.data!;
          final isMobile = MediaQuery.of(context).size.width < 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isMobile ? 4 : 1.4,
                  children: [
                    StatCard(label: 'Absent aujourd\'hui', value: d.absentToday.toString(), detail: '', color: ThemeConfig.primaryColor, progress: (d.absentToday / 10).clamp(0.0, 1.0)),
                    StatCard(label: 'Demandes en attente', value: d.demandesEnAttente.toString(), detail: '', color: ThemeConfig.warningColor, progress: (d.demandesEnAttente / 10).clamp(0.0, 1.0)),
                    StatCard(label: 'Demandes acceptées', value: d.demandesAcceptees.toString(), detail: '', color: ThemeConfig.successColor, progress: (d.demandesAcceptees / 10).clamp(0.0, 1.0)),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isMobile ? 4 : 1.4,
                  children: [
                    StatCard(label: 'Congés annuels', value: d.congesAnnuels.toString(), detail: '', color: ThemeConfig.primaryColor, progress: (d.congesAnnuels / 30).clamp(0.0, 1.0)),
                    StatCard(label: 'Maladie', value: d.congesMaladie.toString(), detail: '', color: ThemeConfig.errorColor, progress: (d.congesMaladie / 30).clamp(0.0, 1.0)),
                    StatCard(label: 'Sans solde', value: d.congesSansSolde.toString(), detail: '', color: ThemeConfig.warningColor, progress: (d.congesSansSolde / 30).clamp(0.0, 1.0)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
