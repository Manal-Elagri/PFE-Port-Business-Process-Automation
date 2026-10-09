import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../models/chef_division_models.dart';
import '../../services/chef_division_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/section_title.dart';
import '../widgets/loading_widget.dart';

class EscalesKpiScreen extends StatelessWidget {
  final String token;

  const EscalesKpiScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EscaleKPI>>(
      future: ChefDivisionApiService().getEscales(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LoadingWidget(message: 'Chargement des escales...'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Impossible de charger les escales.'));
        }
        final escales = snapshot.data!;
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
                  title: 'Escales KPI',
                  subtitle: 'Suivi des opérations par escale',
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
                      title: 'Total escales',
                      value: escales.length.toString(),
                      icon: Icons.anchor_rounded,
                      iconColor: ThemeConfig.primaryColor,
                    ),
                    DashboardCard(
                      title: 'Opérations totales',
                      value: escales.fold<int>(0, (sum, item) => sum + item.totalOperations).toString(),
                      icon: Icons.sync_alt_rounded,
                      iconColor: ThemeConfig.secondaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Tableau des escales'),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('N° Escale')),
                        DataColumn(label: Text('Navire')),
                        DataColumn(label: Text('Opérations')),
                      ],
                      rows: escales
                          .map((escale) => DataRow(cells: [
                                DataCell(Text(escale.numeroEscale)),
                                DataCell(Text(escale.nomNavire)),
                                DataCell(Text(escale.totalOperations.toString())),
                              ]))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Cards mobiles'),
                const SizedBox(height: 8),
                Column(
                  children: escales
                      .map(
                        (escale) => Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          margin: const EdgeInsets.only(bottom: 14),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(escale.numeroEscale, style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 6),
                                      Text(escale.nomNavire, style: Theme.of(context).textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                                Text('${escale.totalOperations}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ThemeConfig.primaryColor)),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
