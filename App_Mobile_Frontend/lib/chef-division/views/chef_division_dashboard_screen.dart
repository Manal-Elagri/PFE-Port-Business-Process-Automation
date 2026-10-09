import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../chef_division_menu.dart';
import '../chef_division_routes.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_title.dart';
import '../widgets/loading_widget.dart';
import '../../config/theme_config.dart';
import '../../services/chef_division_service.dart';
import '../../models/chef_division_models.dart';
import 'profile_screen.dart';
import 'signatures_history_screen.dart';
import 'conges_dashboard_screen.dart';
import 'arrets_dashboard_screen.dart';
import 'engins_kpi_screen.dart';
import 'escales_kpi_screen.dart';
import 'equipes_kpi_screen.dart';

class ChefDivisionDashboardScreen extends StatefulWidget {
  final String token;

  const ChefDivisionDashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ChefDivisionDashboardScreen> createState() => _ChefDivisionDashboardScreenState();
}

class _ChefDivisionDashboardScreenState extends State<ChefDivisionDashboardScreen> {
  final ChefDivisionApiService _api = ChefDivisionApiService();
  ChefDivisionProfile? _profile;
  ChefDivisionDashboard? _dashboard;
  bool _isLoading = true;
  String _selectedRoute = ChefDivisionRoutes.dashboard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final values = await Future.wait([
        _api.getProfile(widget.token),
        _api.getDashboard(widget.token),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = values[0] as ChefDivisionProfile;
        _dashboard = values[1] as ChefDivisionDashboard;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement dashboard: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String get _fullName {
    if (_profile == null) return 'Chef de division';
    final first = _profile!.prenom;
    final last = _profile!.nom;
    return '$first $last'.trim();
  }

  String get _roleLabel => _profile?.role.replaceAll('_', ' ').toLowerCase() ?? 'Chef de division';

  void _navigateTo(String route) {
    setState(() => _selectedRoute = route);
    if (route == ChefDivisionRoutes.signatures) return;
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final avatarSize = isMobile ? 56.0 : 72.0;
    final nameSize = isMobile ? 18.0 : 22.0;
    final padding = isMobile ? 16.0 : 24.0;
    final spacing = isMobile ? 12.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeConfig.primaryColor,
            ThemeConfig.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                _profile == null
                    ? 'CD'
                    : '${_profile!.prenom.isNotEmpty ? _profile!.prenom[0] : 'C'}${_profile!.nom.isNotEmpty ? _profile!.nom[0] : 'D'}',
                style: TextStyle(
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fullName,
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _roleLabel,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: isMobile ? 40 : 48,
            height: isMobile ? 40 : 48,
            child: IconButton.filled(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final dashboard = _dashboard!;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? 12.0 : 20.0;
    final spacing = isMobile ? 16.0 : 32.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: spacing),
          const SectionTitle(
            title: 'Performance globale',
            subtitle: 'Résumé des opérations',
          ),
          const SizedBox(height: 16),
          _buildPerformanceGrid(dashboard, isMobile),
          SizedBox(height: isMobile ? 24 : 32),
          const SectionTitle(
            title: 'Qualité & Fiabilité',
            subtitle: 'Indicateurs de performance',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 2;
            final cardSpacing = isMobile ? 10.0 : 12.0;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: cardSpacing,
              mainAxisSpacing: cardSpacing,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isMobile ? 1.3 : 1.5,
              children: [
                _buildCompactQualityCard(
                  label: 'Annulation',
                  value: dashboard.tauxAnnulation.toStringAsFixed(1),
                  color: ThemeConfig.errorColor,
                  progress: dashboard.tauxAnnulation / 100,
                  icon: Icons.cancel_rounded,
                ),
                _buildCompactQualityCard(
                  label: 'Retard',
                  value: dashboard.tauxRetard.toStringAsFixed(1),
                  color: ThemeConfig.warningColor,
                  progress: dashboard.tauxRetard / 100,
                  icon: Icons.schedule_rounded,
                ),
                _buildCompactQualityCard(
                  label: 'Arrêt',
                  value: dashboard.tauxArret.toStringAsFixed(1),
                  color: ThemeConfig.primaryColor,
                  progress: dashboard.tauxArret / 100,
                  icon: Icons.pause_circle_rounded,
                ),
              ],
            );
          }),
          SizedBox(height: isMobile ? 24 : 32),
          const SectionTitle(
            title: 'Scan IA',
            subtitle: 'Performance du module d\'intelligence artificielle',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 2 : 2;
            final cardSpacing = isMobile ? 10.0 : 12.0;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: cardSpacing,
              mainAxisSpacing: cardSpacing,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isMobile ? 1.4 : 1.6,
              children: [
                _buildCompactMetricCard(
                  title: 'Détection IA',
                  value: '${dashboard.tauxDetectionIA.toStringAsFixed(1)}%',
                  icon: Icons.smart_toy_rounded,
                  color: ThemeConfig.infoColor,
                ),
                _buildCompactMetricCard(
                  title: 'Scans auj.',
                  value: dashboard.scansToday.toString(),
                  icon: Icons.camera_alt_rounded,
                  color: ThemeConfig.primaryColor,
                ),
                _buildCompactMetricCard(
                  title: 'Scans sem.',
                  value: dashboard.scansWeek.toString(),
                  icon: Icons.calendar_view_week_rounded,
                  color: ThemeConfig.secondaryColor,
                ),
                _buildCompactMetricCard(
                  title: 'Erreurs',
                  value: dashboard.erreursIA.toString(),
                  icon: Icons.error_outline_rounded,
                  color: ThemeConfig.errorColor,
                ),
              ],
            );
          }),
          SizedBox(height: isMobile ? 24 : 32),
          const SectionTitle(
            title: 'Documents',
            subtitle: 'Statut des documents et signatures',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 2 : 2;
            final cardSpacing = isMobile ? 10.0 : 12.0;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: cardSpacing,
              mainAxisSpacing: cardSpacing,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isMobile ? 1.4 : 1.6,
              children: [
                _buildCompactMetricCard(
                  title: 'En attente',
                  value: dashboard.documentsEnAttente.toString(),
                  icon: Icons.pending_actions_rounded,
                  color: ThemeConfig.warningColor,
                ),
                _buildCompactMetricCard(
                  title: 'Signés',
                  value: dashboard.documentsSignes.toString(),
                  icon: Icons.check_circle_rounded,
                  color: ThemeConfig.successColor,
                ),
              ],
            );
          }),
          SizedBox(height: isMobile ? 16 : 24),
          Align(
            alignment: Alignment.centerRight,
            //child: FilledButton.icon(
             // onPressed: () => setState(() => _selectedRoute = ChefDivisionRoutes.signatures),
              //icon: const Icon(Icons.history_rounded),
             // label: const Text('Voir historique'),
           // ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid(ChefDivisionDashboard dashboard, bool isMobile) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 2 : 2;
      final cardSpacing = isMobile ? 10.0 : 12.0;
      
      return GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: cardSpacing,
        mainAxisSpacing: cardSpacing,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: isMobile ? 1.4 : 1.6,
        children: [
          _buildCompactMetricCard(
            title: 'Aujourd\'hui',
            value: dashboard.operationsToday.toString(),
            icon: Icons.local_shipping_rounded,
            color: ThemeConfig.primaryColor,
          ),
          _buildCompactMetricCard(
            title: 'Cette semaine',
            value: dashboard.operationsWeek.toString(),
            icon: Icons.calendar_month_rounded,
            color: ThemeConfig.secondaryColor,
          ),
          _buildCompactMetricCard(
            title: 'Chargements',
            value: dashboard.chargements.toString(),
            icon: Icons.upload_rounded,
            color: ThemeConfig.successColor,
          ),
          _buildCompactMetricCard(
            title: 'Déchargements',
            value: dashboard.dechargements.toString(),
            icon: Icons.download_rounded,
            color: ThemeConfig.warningColor,
          ),
        ],
      );
    });
  }

  Widget _buildCompactMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactQualityCard({
    required String label,
    required String value,
    required Color color,
    required double progress,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Text(
                '$value%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 200;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: isMobile ? 40 : 48,
              height: isMobile ? 40 : 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isMobile ? 20 : 24),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQualityCard({
    required String label,
    required String value,
    required Color color,
    required double progress,
    required IconData icon,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 200;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: isMobile ? 34 : 40,
                  height: isMobile ? 34 : 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: isMobile ? 16 : 20),
                ),
                Text(
                  '$value%',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 6 : 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: isMobile ? 6 : 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDocumentCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 200;
      return Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: isMobile ? 48 : 60,
              height: isMobile ? 48 : 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: isMobile ? 22 : 28),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSelectedScreen() {
    switch (_selectedRoute) {
      case ChefDivisionRoutes.profile:
        return ProfileScreen(token: widget.token, profile: _profile);
      //case ChefDivisionRoutes.signatures:
       // return SignaturesHistoryScreen(token: widget.token);
      //case ChefDivisionRoutes.conges:
       // return CongesDashboardScreen(token: widget.token);
      case ChefDivisionRoutes.arrets:
        return ArretsDashboardScreen(token: widget.token);
      case ChefDivisionRoutes.engins:
        return EnginsKpiScreen(token: widget.token);
      case ChefDivisionRoutes.escales:
        return EscalesKpiScreen(token: widget.token);
      case ChefDivisionRoutes.equipes:
        return EquipesKpiScreen(token: widget.token);
      case ChefDivisionRoutes.dashboard:
      default:
        return _dashboard == null ? const LoadingWidget() : _buildDashboardContent(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 900;

      return Scaffold(
        appBar: AppBar(
          title: Text('Chef de division'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadData,
            ),
          ],
        ),
        drawer: isWide
            ? null
            : Drawer(
                child: ChefDivisionMenu(
                  selectedRoute: _selectedRoute,
                  onSelected: (route) {
                    Navigator.of(context).pop();
                    _navigateTo(route);
                  },
                ),
              ),
        body: _isLoading
            ? const LoadingWidget(message: 'Chargement des données...')
            : isWide
                ? Row(
                    children: [
                      SizedBox(
                        width: 280,
                        child: ChefDivisionMenu(
                          selectedRoute: _selectedRoute,
                          onSelected: _navigateTo,
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: _buildSelectedScreen()),
                    ],
                  )
                : _buildSelectedScreen(),
      );
    });
  }
}
