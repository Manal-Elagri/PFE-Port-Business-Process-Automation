import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/admin_models.dart';
import '../../services/admin_service.dart';
import 'views/dashboard_summary_view.dart';
import 'views/requests_management_view.dart';
import 'views/personnel_management_view.dart';
import 'views/planning_management_view.dart';
import 'views/shift_management_view.dart';
import 'views/shifts_list_view.dart'; // ← remplace shift_management_view.dart
import 'views/OperationsScreen.dart'; // ← nouvelle vue pour les opérations
import '../ai_web_view_screen.dart';
// ═════════════════════════════════════════════════════════════════════════════
// APP COLORS
// ═════════════════════════════════════════════════════════════════════════════

class AppColors {
  static const primary       = Color(0xFF1B42C4);
  static const primaryDark   = Color(0xFF0F2A8A);
  static const primaryLight  = Color(0xFF3D64E8);
  static const accent        = Color(0xFF00D4FF);
  static const accentGold    = Color(0xFFF0A500);
  static const surface       = Color(0xFFF4F7FF);
  static const cardBg        = Color(0xFFFFFFFF);
  static const textPrimary   = Color(0xFF0A1628);
  static const textSecondary = Color(0xFF5A6A8A);
  static const textLight     = Color(0xFFFFFFFF);
  static const divider       = Color(0xFFE0E8FF);
  static const success       = Color(0xFF00C48C);
  static const warning       = Color(0xFFFFA940);
  static const error         = Color(0xFFFF4D6A);
}

// ═════════════════════════════════════════════════════════════════════════════
// ADMIN DASHBOARD PAGE
// ═════════════════════════════════════════════════════════════════════════════

class AdminDashboardPage extends StatefulWidget {
  final String token;
  const AdminDashboardPage({super.key, required this.token});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _activeSection = 'dashboard';
  AdminProfile? _profile;
  bool _isLoading = true;

  // ── Nav items ──────────────────────────────────────────────────────────────
  static const List<_NavItem> _navItems = [
    _NavItem('dashboard', 'Accueil',      Icons.home_rounded),
    _NavItem('requests',  'Demandes',     Icons.assignment_rounded),
    _NavItem('employees', 'Personnel',    Icons.people_alt_rounded),
    _NavItem('operations',   'Opérations',       Icons.build_rounded),
    _NavItem('planning',  'Planning',     Icons.calendar_view_week_rounded),
    _NavItem('shifts',    'Shifts',       Icons.schedule_rounded),
    _NavItem('stats',     'Statistiques', Icons.bar_chart_rounded),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await AdminApiService().getProfile(widget.token);
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  // ── Section router ─────────────────────────────────────────────────────────
  Widget _renderActiveSection() {
    switch (_activeSection) {
      case 'requests':
        return RequestsManagementView(token: widget.token);
      case 'employees':
        return PersonnelManagementView(token: widget.token);
      case 'operations':
        return OperationsScreen(token: widget.token);
       case 'planning': // 2. CORRECTION ICI : Redirige vers PLANNING d'abord
        return PlanningManagementView(token: widget.token);
      case 'shifts':
        return ShiftsListView(token: widget.token); // ← nouvelle vue liste
      case 'stats':
        return _PlaceholderView(
            icon: Icons.bar_chart_rounded, label: 'Statistiques');
      default:
        return DashboardSummaryView(
          token: widget.token,
          onNavigate: (s) => setState(() => _activeSection = s),
        );
    }
  }

  // ── Logout dialog ──────────────────────────────────────────────────────────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        content: const Text('Voulez-vous vraiment quitter l\'espace Admin ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Déconnexion',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          _buildNavBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_activeSection),
                child: _renderActiveSection(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      color: AppColors.primaryDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Brand badge + action buttons
              Row(
                children: [
                  _buildBrandBadge(),
                  const Spacer(),
                  _IconBtn(
                    icon: Icons.notifications_rounded,
                    onTap: () {},
                    showDot: true,
                    dotColor: AppColors.accentGold,
                  ),
                  const SizedBox(width: 8),

                  _IconBtn(
                    icon: Icons.smart_toy_rounded,
                    iconColor: AppColors.accent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AiWebViewScreen(role: 'ADMIN'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: Icons.logout_rounded,
                    iconColor: AppColors.error,
                    onTap: _confirmLogout,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Avatar + name + role
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour,',
                          style: TextStyle(
                              color: AppColors.textLight.withOpacity(0.55),
                              fontSize: 12),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _profile?.nom ?? '—',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildRoleChip(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Stats strip
              Row(
                children: [
                  _StatCard(
                    label: 'Demandes',
                    value: '24',
                    sub: '↑ +3 aujourd\'hui',
                    subColor: AppColors.success,
                  ),
                  const SizedBox(width: 10),
                  const _StatCard(
                    label: 'En service',
                    value: '142',
                    sub: 'employés actifs',
                  ),
                  const SizedBox(width: 10),
                  const _StatCard(
                    label: 'Engins',
                    value: '18/21',
                    sub: 'opérationnels',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withOpacity(0.18), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: AppColors.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text(
            'MARSA MAROC – TCR',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

        Widget _buildAvatar() {
          return SizedBox(
            width: 54,
            height: 54,
            child: _profile?.imageURL != null && _profile!.imageURL!.isNotEmpty
                ? ClipOval(
                    // On garde ClipOval uniquement pour que la PHOTO soit ronde
                    child: Image.network(
                      _profile!.imageURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _buildDefaultAvatar(),
                    ),
                  )
                : Image.asset(
                    'assets/images/icon_admin.png', // Ton icône s'affiche sans aucun cercle autour
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => _buildDefaultAvatar(),
                  ),
          );
        }

      // Petit widget de secours si aucune image n'est trouvée
      Widget _buildDefaultAvatar() {
        return const Center(
          child: Icon(Icons.person_rounded, color: AppColors.accent, size: 30),
        );
      }

  Widget _buildRoleChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: AppColors.accent.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
                color: AppColors.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          const Text(
            'Administrateur système',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NAV BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildNavBar() {
    return Container(
      height: 70,
      color: AppColors.cardBg,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        itemCount: _navItems.length,
        itemBuilder: (_, i) {
          final item = _navItems[i];
          final active = _activeSection == item.id;
          return GestureDetector(
            onTap: () => setState(() => _activeSection = item.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      active ? AppColors.primary : AppColors.divider,
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    color: active
                        ? AppColors.textLight
                        : AppColors.textSecondary,
                    size: 19,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: active
                          ? AppColors.textLight
                          : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STAT CARD  (header strip)
// ═════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final Color? subColor;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.sub,
      this.subColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.white.withOpacity(0.12), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: AppColors.textLight.withOpacity(0.55),
                    fontSize: 10)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 17,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(sub,
                style: TextStyle(
                    color: subColor ??
                        AppColors.textLight.withOpacity(0.4),
                    fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ICON BUTTON  (header)
// ═════════════════════════════════════════════════════════════════════════════

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final bool showDot;
  final Color? dotColor;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.showDot = false,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.white.withOpacity(0.15), width: 0.5),
            ),
            child: Icon(icon,
                color: iconColor ?? AppColors.textLight, size: 19),
          ),
          if (showDot && dotColor != null)
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    color: dotColor, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PLACEHOLDER VIEW
// ═════════════════════════════════════════════════════════════════════════════

class _PlaceholderView extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderView(
      {required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child:
                Icon(icon, size: 42, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text(
            'Section en cours de développement',
            style: TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ═════════════════════════════════════════════════════════════════════════════

class _NavItem {
  final String id, label;
  final IconData icon;
  const _NavItem(this.id, this.label, this.icon);
}