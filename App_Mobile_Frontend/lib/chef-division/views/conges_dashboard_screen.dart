import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../models/chef_division_models.dart';
import '../../services/chef_division_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/chart_widget.dart';
import '../widgets/section_title.dart';
import '../widgets/loading_widget.dart';

class CongesDashboardScreen extends StatelessWidget {
  final String token;

  const CongesDashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CongeDashboard>(
      future: ChefDivisionApiService().getConges(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LoadingWidget(message: 'Chargement des congés...'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Impossible de charger les congés.'));
        }
        final data = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Tableau de bord Congés',
                subtitle: 'Suivi des absences, demandes et disponibilités',
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                children: [
                  DashboardCard(
                    title: 'Absents aujourd’hui',
                    value: data.absentToday.toString(),
                    icon: Icons.person_off_rounded,
                    iconColor: ThemeConfig.errorColor,
                  ),
                  DashboardCard(
                    title: 'Demandes en attente',
                    value: data.demandesEnAttente.toString(),
                    icon: Icons.pending_actions_rounded,
                    iconColor: ThemeConfig.warningColor,
                  ),
                  DashboardCard(
                    title: 'Demandes acceptées',
                    value: data.demandesAcceptees.toString(),
                    icon: Icons.check_circle_rounded,
                    iconColor: ThemeConfig.successColor,
                  ),
                  DashboardCard(
                    title: 'Demandes refusées',
                    value: data.demandesRefusees.toString(),
                    icon: Icons.block_rounded,
                    iconColor: ThemeConfig.errorColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  DashboardCard(
                    title: 'Congés annuels',
                    value: data.congesAnnuels.toString(),
                    icon: Icons.beach_access_rounded,
                    iconColor: ThemeConfig.primaryColor,
                  ),
                  DashboardCard(
                    title: 'Congés maladie',
                    value: data.congesMaladie.toString(),
                    icon: Icons.medical_information_rounded,
                    iconColor: ThemeConfig.secondaryColor,
                  ),
                  DashboardCard(
                    title: 'Congés sans solde',
                    value: data.congesSansSolde.toString(),
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: ThemeConfig.warningColor,
                  ),
                ],
              ),
              const SectionTitle(
                title: 'Absences par catégorie',
              ),
              ChartWidget(
                title: 'Répartition des congés',
                values: [data.congesAnnuels.toDouble(), data.congesMaladie.toDouble(), data.congesSansSolde.toDouble()],
                labels: ['Annuel', 'Maladie', 'Sans solde'],
                color: ThemeConfig.secondaryColor,
              ),
              const SizedBox(height: 20),
              const SectionTitle(
                title: 'Disponibilité des équipes',
              ),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  DashboardCard(
                    title: 'Chefs d’escale absents',
                    value: data.chefsEscalesAbsents.toString(),
                    icon: Icons.person_remove_rounded,
                    iconColor: ThemeConfig.errorColor,
                  ),
                  DashboardCard(
                    title: 'Chefs d’équipe absents',
                    value: data.chefsEquipesAbsents.toString(),
                    icon: Icons.person_remove_alt_1_rounded,
                    iconColor: ThemeConfig.warningColor,
                  ),
                  DashboardCard(
                    title: 'Employés absents',
                    value: data.employesAbsents.toString(),
                    icon: Icons.person_off_rounded,
                    iconColor: ThemeConfig.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
