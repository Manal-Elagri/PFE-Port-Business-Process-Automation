import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/chef_escale_service.dart';
import '../../models/chef_escale_models.dart';

import 'views/gestion_equipes_screen.dart';
import 'views/gestion_des_affectations_screen.dart';
import 'views/shift_management_screen.dart';
import 'views/shift_history_screen.dart';
import 'views/calendar_screen.dart';
import 'views/statistiques_screen.dart';

class ChefEscaleDashboardScreen extends StatefulWidget {
  final String token;
  const ChefEscaleDashboardScreen({Key? key, required this.token})
      : super(key: key);

  @override
  State<ChefEscaleDashboardScreen> createState() =>
      _ChefEscaleDashboardScreenState();
}

class _ChefEscaleDashboardScreenState
    extends State<ChefEscaleDashboardScreen> {
  late ChefEscaleApiService _api;
  ChefEscaleProfile? _profile;
  ChefEscaleDashboardStats? _stats;
  bool _isLoading = true;
  int _selectedIndex = 0;

  // ── Palette ───────────────────────────────────────────────────────
  static const _ink       = Color(0xFF0D1B2A);
  static const _slate     = Color(0xFF64748B);
  static const _muted     = Color(0xFF94A3B8);
  static const _border    = Color(0xFFE8EDF2);
  static const _surface   = Color(0xFFF5F7FA);
  static const _white     = Colors.white;
  static const _accent    = Color(0xFF2563EB);
  static const _accentBg  = Color(0xFFEFF6FF);
  static const _green     = Color(0xFF059669);
  static const _greenBg   = Color(0xFFECFDF5);
  static const _amber     = Color(0xFFD97706);
  static const _amberBg   = Color(0xFFFFFBEB);
  static const _violet    = Color(0xFF7C3AED);
  static const _violetBg  = Color(0xFFF5F3FF);

  @override
  void initState() {
    super.initState();
    _api = ChefEscaleApiService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getProfile(widget.token),
        _api.getDashboard(widget.token),
      ]);
      if (mounted) {
        setState(() {
          _profile = results[0] as ChefEscaleProfile?;
          _stats   = results[1] as ChefEscaleDashboardStats?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String get _fullName {
    if (_profile == null) return '—';
    final p = _profile!.prenom.trim();
    final n = _profile!.nom.trim();
    if (p.isEmpty && n.isEmpty) return '—';
    return '$p $n'.trim();
  }

  String get _initials {
    final p = _profile?.prenom.trim() ?? '';
    final n = _profile?.nom.trim() ?? '';
    if (p.isEmpty && n.isEmpty) return '?';
    return '${p.isNotEmpty ? p[0] : ''}${n.isNotEmpty ? n[0] : ''}'
        .toUpperCase();
  }

  void _confirmLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Color(0xFFDC2626), size: 26),
            ),
            const SizedBox(height: 16),
            const Text('Déconnexion',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
            const SizedBox(height: 8),
            const Text(
              'Voulez-vous quitter l\'espace Chef d\'Escale ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _slate),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: _border),
                    ),
                    child: const Text('Annuler',
                        style: TextStyle(
                            color: _slate, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Déconnexion',
                        style: TextStyle(
                            color: _white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: _surface,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: _accent, strokeWidth: 2))
          : _selectedIndex == 0
              ? _buildHomeTab()
              : _buildSubScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_rounded,             Icons.home_outlined,            'Accueil'),
      _NavItem(Icons.groups_rounded,           Icons.groups_outlined,          'Équipes'),
      _NavItem(Icons.assignment_ind_rounded,   Icons.assignment_ind_outlined,  'Affectations'),
      _NavItem(Icons.swap_horiz_rounded,       Icons.swap_horiz_outlined,      'Shifts'),
      _NavItem(Icons.more_horiz_rounded,       Icons.more_horiz_outlined,      'Plus'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _white,
        border: const Border(top: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final sel = _selectedIndex == i ||
                  (i == 4 && _selectedIndex >= 4);
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i == 4) {
                      _showMoreSheet();
                    } else {
                      setState(() => _selectedIndex = i);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? _accentBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          sel ? items[i].activeIcon : items[i].icon,
                          size: 22,
                          color: sel ? _accent : _muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: sel
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: sel ? _accent : _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final extras = [
          _MoreItem(4, Icons.history_rounded,       'Historique',    _amber,   _amberBg),
          _MoreItem(5, Icons.calendar_month_rounded,'Calendrier',    _green,   _greenBg),
          _MoreItem(6, Icons.bar_chart_rounded,     'Statistiques',  _violet,  _violetBg),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              ...extras.map((e) => ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    leading: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                          color: e.bg,
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(e.icon, color: e.color, size: 20),
                    ),
                    title: Text(e.label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _ink)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: _muted),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _selectedIndex = e.index);
                    },
                  )),
              const Divider(color: _border, height: 24),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.logout_rounded,
                      color: Color(0xFFDC2626), size: 20),
                ),
                title: const Text('Déconnexion',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626))),
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Sub screen router ─────────────────────────────────────────────
  Widget _buildSubScreen() {
    switch (_selectedIndex) {
      case 1:
        return GestionEquipesScreen(token: widget.token);
      case 2:
        return GestionDesAffectationsScreen(token: widget.token);
      case 3:
        return ShiftManagementScreen(token: widget.token);
      case 4:
        return ShiftHistoryScreen(token: widget.token);
      case 5:
        return CalendarScreen(token: widget.token);
      case 6:
        if (_stats == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return StatistiquesScreen(
            token: widget.token, stats: _stats!);
      default:
        return _buildHomeTab();
    }
  }

  // ── Home Tab ──────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: _accent,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _accent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroHeader(),
            ),
           
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats
                _buildStatsRow(),
                const SizedBox(height: 28),

                // Quick actions
                _sectionTitle('Accès rapide'),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 28),

                // Today info
                _sectionTitle('Aujourd\'hui'),
                const SizedBox(height: 12),
                _buildTodayCard(),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          _buildAvatar(size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()},',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 2),
                Text(
                  _fullName,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Text(
                    _profile?.role ?? 'Chef d\'Escale',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Date badge
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('EEE', 'fr')
                    .format(DateTime.now())
                    .toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2),
              ),
              Text(
                DateFormat('dd', 'fr').format(DateTime.now()),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1),
              ),
              Text(
                DateFormat('MMM', 'fr').format(DateTime.now()),
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildAvatar(size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _fullName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required double size}) {
    final imageUrl = _profile?.formattedImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsCircle(size),
        ),
      );
    }
    return _initialsCircle(size);
  }

  Widget _initialsCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
            color: Colors.white.withOpacity(0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
              fontSize: size * 0.33,
              fontWeight: FontWeight.w800,
              color: Colors.white),
        ),
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final s = _stats;
    final items = [
      _Stat('Équipes',    s?.totalEquipes.toString()    ?? '—', Icons.groups_rounded,         _accent,  _accentBg),
      _Stat('Personnels', s?.totalPersonnels.toString() ?? '—', Icons.badge_rounded,          _violet,  _violetBg),
      _Stat('Shifts',     s?.totalShifts.toString()     ?? '—', Icons.access_time_rounded,    _green,   _greenBg),
      _Stat('Mouvements', s?.totalMouvements.toString() ?? '—', Icons.swap_horiz_rounded,     _amber,   _amberBg),
    ];

    return Row(
      children: items
          .map((item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildStatCard(item),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildStatCard(_Stat c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(c.icon, color: c.color, size: 17),
          ),
          const SizedBox(height: 8),
          Text(
            c.value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _ink,
                height: 1),
          ),
          const SizedBox(height: 3),
          Text(
            c.label,
            style: const TextStyle(fontSize: 9.5, color: _muted),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _ink,
          letterSpacing: -0.2),
    );
  }

  // ── Quick actions ─────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _Action(1, Icons.groups_rounded,          'Équipes',       'Gérer les équipes',      _accent,  _accentBg),
      _Action(2, Icons.assignment_ind_rounded,  'Affectations',  'Affecter le personnel',  _violet,  _violetBg),
      _Action(3, Icons.swap_horiz_rounded,      'Shifts',        'Gérer les shifts',       _amber,   _amberBg),
      _Action(5, Icons.calendar_month_rounded,  'Calendrier',    'Voir le planning',       _green,   _greenBg),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: actions.map((a) => GestureDetector(
        onTap: () => setState(() => _selectedIndex = a.index),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: a.bg,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(a.icon, color: a.color, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _ink)),
                  Text(a.subtitle,
                      style: const TextStyle(
                          fontSize: 10, color: _muted),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  // ── Today card ────────────────────────────────────────────────────
  Widget _buildTodayCard() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr').format(now);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: _accentBg,
                borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.calendar_today_rounded,
                color: _accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr.substring(0, 1).toUpperCase() +
                      dateStr.substring(1),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _ink),
                ),
                const SizedBox(height: 4),
                Text(
                  'Connecté en tant que ${_profile?.role ?? 'Chef d\'Escale'}',
                  style: const TextStyle(
                      fontSize: 11, color: _muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border)),
              child: const Icon(Icons.refresh_rounded,
                  size: 16, color: _muted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data classes ───────────────────────────────────────────────────────
class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _NavItem(this.activeIcon, this.icon, this.label);
}

class _Stat {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _Stat(this.label, this.value, this.icon, this.color, this.bg);
}

class _Action {
  final int index;
  final IconData icon;
  final String title, subtitle;
  final Color color, bg;
  const _Action(this.index, this.icon, this.title, this.subtitle, this.color, this.bg);
}

class _MoreItem {
  final int index;
  final IconData icon;
  final String label;
  final Color color, bg;
  const _MoreItem(this.index, this.icon, this.label, this.color, this.bg);
}