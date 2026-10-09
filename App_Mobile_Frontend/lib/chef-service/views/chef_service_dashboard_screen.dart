import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../services/chef_service_service.dart';
import '../../models/chef_service_models.dart';
import '../widgets/loading_widget.dart';
import '../widgets/section_header.dart';
import '../chef_service_menu.dart';
import '../chef_service_routes.dart';
import 'chef_service_signatures_screen.dart';
import 'chef_service_profile_screen.dart';
import 'chef_service_conges_screen.dart';
import 'chef_service_shift_calendar_screen.dart';
import 'chef_service_shift_history_screen.dart';
import 'chef_service_shift_equipes_screen.dart';
import 'chef_service_active_equipes_screen.dart';

class ChefServiceDashboardScreen extends StatefulWidget {
  final String token;

  const ChefServiceDashboardScreen({Key? key, required this.token})
      : super(key: key);

  @override
  State<ChefServiceDashboardScreen> createState() =>
      _ChefServiceDashboardScreenState();
}

class _ChefServiceDashboardScreenState
    extends State<ChefServiceDashboardScreen> {
  final ChefServiceApiService _api = ChefServiceApiService();
  ChefServiceProfile? _profile;
  ChefServiceDashboard? _dashboard;
  bool _isLoading = true;
  int? _selectedShiftId; // ✅ FIX IMPORTANT

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final today = DateTime.now().toIso8601String().split('T').first;

      final profile = await _api.getProfile(widget.token);

      final shifts = await _api.getShiftCalendar(
        token: widget.token,
        date: today,
      );

      if (shifts.isEmpty) {
        throw Exception('Aucun shift trouvé');
      }

      final selectedShiftId = shifts.first.id;

      print('SHIFT => $selectedShiftId');

      final dashboard = await _api.getDashboard(
        token: widget.token,
        shiftId: selectedShiftId,
      );

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _dashboard = dashboard;
        _selectedShiftId = selectedShiftId; // ✅ stocké ici
      });

    } catch (e) {
      print(e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous quitter votre session ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToRoute(String route) {
    Navigator.of(context).pop(); // Ferme le drawer
    
    switch (route) {
      case ChefServiceRoutes.dashboard:
        break; // Déjà sur le dashboard
      case ChefServiceRoutes.profile:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChefServiceProfileScreen(token: widget.token)),
        );
        break;
      case ChefServiceRoutes.signatures:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChefServiceSignaturesScreen(token: widget.token)),
        );
        break;
      case ChefServiceRoutes.conges:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChefServiceCongesScreen(token: widget.token)),
        );
        break;
      case ChefServiceRoutes.shiftCalendar:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChefServiceShiftCalendarScreen(token: widget.token)),
        );
        break;
      case ChefServiceRoutes.shiftHistory:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChefServiceShiftHistoryScreen(token: widget.token, shiftId: _selectedShiftId ?? 0,)),
        );
        break;
      case ChefServiceRoutes.shiftEquipes:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChefServiceShiftEquipesScreen(token: widget.token, shiftId: _selectedShiftId ?? 0,)),
        );
        break;
      case ChefServiceRoutes.activeEquipes:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChefServiceActiveEquipesScreen(token: widget.token)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Chargement du dashboard...'),
      );
    }
    if (_dashboard == null || _profile == null) {
      return const Center(child: Text('Impossible de charger les données.'));
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final d = _dashboard!;
    final p = _profile!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chef de service'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Déconnexion',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ChefServiceMenu(
          selectedRoute: ChefServiceRoutes.dashboard,
          onSelected: _navigateToRoute,
          onLogout: _confirmLogout,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── 1. Header profil ────────────────────────────────
              _buildProfileHeader(p, isMobile),
              SizedBox(height: isMobile ? 20 : 24),

              // ── 2. Production ────────────────────────────────────
              const SectionHeader(
                title: 'Production',
                subtitle: 'Résumé des opérations',
              ),
              SizedBox(height: isMobile ? 12 : 14),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isMobile ? 1.2 : 1.4,
                children: [
                  _buildMetricCard(
                    label: 'Total ops',
                    value: d.totalOperations.toString(),
                    icon: Icons.work_outline_rounded,
                    color: ThemeConfig.primaryColor,
                  ),
                  _buildMetricCard(
                    label: 'En cours',
                    value: d.operationsEnCours.toString(),
                    icon: Icons.play_circle_outline_rounded,
                    color: ThemeConfig.secondaryColor,
                  ),
                  _buildMetricCard(
                    label: 'Terminées',
                    value: d.operationsTerminees.toString(),
                    icon: Icons.check_circle_outline_rounded,
                    color: ThemeConfig.successColor,
                  ),
                  _buildMetricCard(
                    label: 'Annulées',
                    value: d.operationsAnnulees.toString(),
                    icon: Icons.cancel_outlined,
                    color: ThemeConfig.errorColor,
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 20 : 24),

              // ── 3. Ressources ────────────────────────────────────
              const SectionHeader(
                title: 'Ressources',
                subtitle: 'Postes, portiers et engins utilisés',
              ),
              SizedBox(height: isMobile ? 12 : 14),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isMobile ? 1.2 : 1.4,
                children: [
                  _buildMetricCard(
                    label: 'Postes utilisés',
                    value: d.postesUtilises.toString(),
                    icon: Icons.location_on_outlined,
                    color: ThemeConfig.primaryColor,
                  ),
                  _buildMetricCard(
                    label: 'Portiers',
                    value: d.portiersUtilises.toString(),
                    icon: Icons.people_outline_rounded,
                    color: ThemeConfig.secondaryColor,
                  ),
                  _buildMetricCard(
                    label: 'Engins utilisés',
                    value: d.enginsUtilises.toString(),
                    icon: Icons.agriculture_outlined,
                    color: ThemeConfig.warningColor,
                  ),
                  _buildMetricCard(
                    label: 'Conteneurs',
                    value: d.totalConteneurs.toString(),
                    icon: Icons.inventory_2_outlined,
                    color: ThemeConfig.successColor,
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 20 : 24),

              // ── 4. Performance ───────────────────────────────────
              const SectionHeader(
                title: 'Performance',
                subtitle: 'Durées, arrêts et détection IA',
              ),
              SizedBox(height: isMobile ? 12 : 14),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isMobile ? 1.2 : 1.4,
                children: [
                  _buildMetricCard(
                    label: 'Durée moyenne',
                    value: '${d.dureeMoyenneMinutes.toStringAsFixed(1)} min',
                    icon: Icons.av_timer_rounded,
                    color: ThemeConfig.primaryColor,
                  ),
                  _buildMetricCard(
                    label: 'Total arrêts',
                    value: d.totalArrets.toString(),
                    icon: Icons.pause_circle_outline_rounded,
                    color: ThemeConfig.errorColor,
                  ),
                  _buildMetricCard(
                    label: 'Taux IA',
                    value: '${d.tauxDetectionIA.toStringAsFixed(1)}%',
                    icon: Icons.smart_toy_outlined,
                    color: ThemeConfig.secondaryColor,
                  ),
                  _buildMetricCard(
                    label: 'Scans today',
                    value: d.scansToday.toString(),
                    icon: Icons.qr_code_scanner_rounded,
                    color: ThemeConfig.warningColor,
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 20 : 24),

              // ── 5. Documents / Signatures ────────────────────────
              const SectionHeader(
                title: 'Documents',
                subtitle: 'Signatures et validations',
              ),
              SizedBox(height: isMobile ? 12 : 14),
              Row(
                children: [
                  Expanded(
                    child: _buildSignaturePill(
                      label: 'En attente',
                      value: d.documentsEnAttente.toString(),
                      color: ThemeConfig.warningColor,
                      icon: Icons.hourglass_empty_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSignaturePill(
                      label: 'Signés',
                      value: d.documentsSignes.toString(),
                      color: ThemeConfig.successColor,
                      icon: Icons.verified_outlined,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // ── 6. Bouton signatures ─────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChefServiceSignaturesScreen(token: widget.token),
                    ),
                  ),
                  icon: const Icon(Icons.draw_outlined, size: 18),
                  label: const Text('Voir toutes les signatures'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: ThemeConfig.primaryColor),
                    foregroundColor: ThemeConfig.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 16 : 24),
            ],
          ),
        ),
      );
  }

  // ── Header profil ──────────────────────────────────────────────────
  Widget _buildProfileHeader(ChefServiceProfile p, bool isMobile) {
    final initiales =
        '${p.prenom.isNotEmpty ? p.prenom[0] : 'C'}${p.nom.isNotEmpty ? p.nom[0] : 'S'}'
            .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 26 : 32,
            backgroundColor: ThemeConfig.primaryColor.withOpacity(0.12),
            backgroundImage: p.formattedImageUrl != null
                ? NetworkImage(p.formattedImageUrl!)
                : null,
            child: p.formattedImageUrl == null
                ? Text(
                    initiales,
                    style: TextStyle(
                      color: ThemeConfig.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 15 : 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.prenom} ${p.nom}',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    p.role.replaceAll('_', ' ').toLowerCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              foregroundColor: const Color(0xFF6B7280),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte métrique ─────────────────────────────────────────────────
  Widget _buildMetricCard({
  required String label,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFFFFFFF),

      borderRadius:
          BorderRadius.circular(14),

      border: Border.all(
        color:
            const Color(0xFFEAECF0),
      ),

      boxShadow: [
        BoxShadow(
          color:
              Colors.black.withOpacity(
            0.03,
          ),

          blurRadius: 6,

          offset:
              const Offset(0, 2),
        ),
      ],
    ),

    padding:
        const EdgeInsets.all(14),

    child: Column(

      // ← IMPORTANT
      mainAxisSize: MainAxisSize.min,

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Container(
          width: 34,
          height: 34,

          decoration: BoxDecoration(
            color:
                color.withOpacity(
              0.12,
            ),

            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),

          child: Icon(
            icon,
            color: color,
            size: 17,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          value,

          maxLines: 1,

          overflow:
              TextOverflow.ellipsis,

          style:
              const TextStyle(
            fontSize: 20,

            fontWeight:
                FontWeight.w700,

            color:
                Color(
              0xFF111827,
            ),
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          label,

          maxLines: 1,

          overflow:
              TextOverflow.ellipsis,

          style:
              const TextStyle(
            fontSize: 11,

            color:
                Color(
              0xFF9CA3AF,
            ),

            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

  // ── Pill signature ─────────────────────────────────────────────────
  Widget _buildSignaturePill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}