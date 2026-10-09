import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../models/chef_division_models.dart';
import '../../services/chef_division_service.dart';
import '../widgets/section_title.dart';
import '../widgets/loading_widget.dart';

class ArretsDashboardScreen extends StatelessWidget {
  final String token;

  const ArretsDashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ArretDashboard>(
      future: ChefDivisionApiService().getArrets(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: LoadingWidget(message: 'Chargement des arrêts...'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text('Impossible de charger les arrêts.'),
          );
        }

        final data = snapshot.data!;
        final topCauses = data.topCauses;
        final isMobile = MediaQuery.of(context).size.width < 600;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── 1. En-tête ────────────────────────────────────────
              const SectionTitle(
                title: 'Tableau de bord Arrêts',
                subtitle: 'Analyse des arrêts et impacts',
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // ── 2. KPI principaux (4 cartes) ──────────────────────
              LayoutBuilder(builder: (context, constraints) {
                final cols = constraints.maxWidth > 700 ? 4 : 2;
                final spacing = isMobile ? 10.0 : 12.0;
                return GridView.count(
                  crossAxisCount: cols,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isMobile ? 1.55 : 1.75,
                  children: [
                    _buildMetricCard(
                      title: 'Total arrêts',
                      value: data.totalArrets.toString(),
                      icon: Icons.pause_circle_filled_rounded,
                      color: ThemeConfig.errorColor,
                    ),
                    _buildMetricCard(
                      title: "Aujourd'hui",
                      value: data.arretsToday.toString(),
                      icon: Icons.today_rounded,
                      color: ThemeConfig.primaryColor,
                    ),
                    _buildMetricCard(
                      title: 'Cette semaine',
                      value: data.arretsWeek.toString(),
                      icon: Icons.calendar_view_week_rounded,
                      color: ThemeConfig.warningColor,
                    ),
                    _buildMetricCard(
                      title: 'Temps perdu',
                      value: '${data.tempsPerduTotal} min',
                      icon: Icons.timer_off_rounded,
                      color: ThemeConfig.secondaryColor,
                    ),
                  ],
                );
              }),

              SizedBox(height: isMobile ? 24 : 32),

              // ── 3. Métriques détaillées (3 cartes) ────────────────
              const SectionTitle(
                title: 'Métriques détaillées',
                subtitle: 'Analyse approfondie',
              ),
              SizedBox(height: isMobile ? 12 : 16),
              LayoutBuilder(builder: (context, constraints) {
                final cols = constraints.maxWidth > 700 ? 3 : 2;
                final spacing = isMobile ? 10.0 : 12.0;
                return GridView.count(
                  crossAxisCount: cols,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isMobile ? 1.55 : 1.75,
                  children: [
                    _buildMetricCard(
                      title: 'Durée moyenne',
                      value: '${data.avgDuration.toStringAsFixed(1)} min',
                      icon: Icons.av_timer_rounded,
                      color: ThemeConfig.primaryColor,
                    ),
                    _buildMetricCard(
                      title: 'Taux blocage',
                      value: '${data.tauxBlocageOperations.toStringAsFixed(1)}%',
                      icon: Icons.block_rounded,
                      color: ThemeConfig.errorColor,
                    ),
                    _buildMetricCard(
                      title: 'Causes principales',
                      value: topCauses.length.toString(),
                      icon: Icons.list_alt_rounded,
                      color: ThemeConfig.secondaryColor,
                    ),
                  ],
                );
              }),

              SizedBox(height: isMobile ? 24 : 32),

              // ── 4. Top causes — barres horizontales natives ────────
              const SectionTitle(
                title: "Top causes d'arrêt",
                subtitle: 'Répartition par fréquence',
              ),
              SizedBox(height: isMobile ? 12 : 16),
              topCauses.isEmpty
                  ? _buildEmptyChart()
                  : _buildBarChart(topCauses, isMobile),

              SizedBox(height: isMobile ? 24 : 32),

              // ── 5. Liste détaillée ────────────────────────────────
              const SectionTitle(title: 'Causes détaillées'),
              SizedBox(height: isMobile ? 12 : 16),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: topCauses.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: isMobile ? 10 : 12),
                itemBuilder: (context, index) =>
                    _buildCauseListItem(context, topCauses[index], isMobile),
              ),

              SizedBox(height: isMobile ? 16 : 24),
            ],
          ),
        );
      },
    );
  }

  // ── Diagramme barres horizontales 100% natif Flutter ─────────────
  Widget _buildBarChart(List<ArretStats> causes, bool isMobile) {
    final maxVal = causes
        .map((e) => e.nombre)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: causes.asMap().entries.map((entry) {
          final index = entry.key;
          final cause = entry.value;
          final ratio = maxVal > 0 ? cause.nombre / maxVal : 0.0;
          final isLast = index == causes.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label + valeur
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        cause.cause,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cause.nombre.toString(),
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w700,
                        color: ThemeConfig.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Barre
                LayoutBuilder(builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Fond
                      Container(
                        width: constraints.maxWidth,
                        height: isMobile ? 8 : 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      // Remplissage
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400 + index * 80),
                        curve: Curves.easeOut,
                        width: constraints.maxWidth * ratio,
                        height: isMobile ? 8 : 10,
                        decoration: BoxDecoration(
                          color: ThemeConfig.errorColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── État vide ─────────────────────────────────────────────────────
  Widget _buildEmptyChart() {
    return Container(
      width: double.infinity,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        'Aucune cause disponible',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
    );
  }

  // ── Widget carte métrique ─────────────────────────────────────────
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Widget ligne cause ────────────────────────────────────────────
  Widget _buildCauseListItem(
      BuildContext context, ArretStats cause, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 16,
        vertical: isMobile ? 12 : 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              cause.cause,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: ThemeConfig.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cause.nombre.toString(),
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: ThemeConfig.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}