import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../models/chef_division_models.dart';
import '../../services/chef_division_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/section_title.dart';
import '../widgets/loading_widget.dart';

class EquipesKpiScreen extends StatelessWidget {
  final String token;

  const EquipesKpiScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EquipeKPI>>(
      future: ChefDivisionApiService().getBestTeams(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LoadingWidget(message: 'Chargement des équipes...'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Impossible de charger les équipes.'));
        }
        final teams = snapshot.data!;
        final isMobile = MediaQuery.of(context).size.width < 600;

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 20,
              isMobile ? 12 : 20,
              isMobile ? 12 : 20,
              MediaQuery.of(context).viewPadding.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Équipes KPI',
                  subtitle: 'Classement et performances par équipe',
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: isMobile ? 1 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  children: [
                    DashboardCard(
                      title: 'Équipes suivies',
                      value: teams.length.toString(),
                      icon: Icons.groups_rounded,
                      iconColor: ThemeConfig.primaryColor,
                    ),
                    DashboardCard(
                      title: 'Total conteneurs',
                      value: teams.fold<int>(0, (sum, item) => sum + item.totalConteneurs).toString(),
                      icon: Icons.inventory_2_rounded,
                      iconColor: ThemeConfig.secondaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Top équipes'),
                const SizedBox(height: 8),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: teams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        leading: CircleAvatar(
                          backgroundColor: ThemeConfig.secondaryColor.withOpacity(0.14),
                          foregroundColor: ThemeConfig.secondaryColor,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(team.matriculeEquipe, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text('${team.totalOperations} opérations • ${team.totalConteneurs} conteneurs', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
