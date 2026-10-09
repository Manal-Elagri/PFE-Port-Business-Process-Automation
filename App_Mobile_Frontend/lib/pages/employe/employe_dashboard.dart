import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/employe_service.dart';
import '../../models/employe_models.dart';

import 'views/gestion_conges_screen.dart';
import 'views/gestion_affectations_screen.dart';
import 'views/operations_screen.dart';
import 'views/history_screen.dart';
import 'views/calendar_screen.dart';

class EmployeDashboardScreen extends StatefulWidget {
  final String token;
  const EmployeDashboardScreen({Key? key, required this.token})
      : super(key: key);

  @override
  State<EmployeDashboardScreen> createState() =>
      _EmployeDashboardScreenState();
}

class _EmployeDashboardScreenState
    extends State<EmployeDashboardScreen> {
  late EmployeApiService _api;
  EmployeProfile? _profile;
  bool _isLoading = true;
  int _selectedIndex = 0;

  // ── Palette (teal–vert, distincte du chef d'escale bleu) ──────────
  static const _ink        = Color(0xFF0D1B2A);
  static const _slate      = Color(0xFF64748B);
  static const _muted      = Color(0xFF94A3B8);
  static const _border     = Color(0xFFE8EDF2);
  static const _surface    = Color(0xFFF4F7F6);
  static const _white      = Colors.white;

  // Accent principal : teal
  static const _teal       = Color(0xFF0A7EA4);
  static const _tealEnd    = Color(0xFF0D9E78);
  static const _tealBg     = Color(0xFFE0F7F0);
  static const _tealDark   = Color(0xFF0A6E54);

  // Accents secondaires
  static const _violet     = Color(0xFF534AB7);
  static const _violetBg   = Color(0xFFEEEDFE);
  static const _amber      = Color(0xFFBA7517);
  static const _amberBg    = Color(0xFFFAEEDA);
  static const _green      = Color(0xFF3B6D11);
  static const _greenBg    = Color(0xFFEAF3DE);

  @override
  void initState() {
    super.initState();
    _api = EmployeApiService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getProfile(widget.token),
      ]);
      if (mounted) {
        setState(() {
          _profile = results[0] as EmployeProfile?;
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

  bool get _isPointeur => _profile?.role == 'POINTEUR';

  // ── Logout ────────────────────────────────────────────────────────
  void _confirmLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              'Voulez-vous quitter l\'espace Employé ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _slate),
            ),
            const SizedBox(height: 24),
            Row(children: [
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
            ]),
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
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _surface,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: _teal, strokeWidth: 2))
          : _selectedIndex == 0
              ? _buildHomeTab()
              : _buildSubScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_rounded, Icons.home_outlined, 'Accueil'),
      _NavItem(Icons.calendar_today_rounded,
          Icons.calendar_today_outlined, 'Congés'),
      _NavItem(Icons.people_rounded, Icons.people_outlined, 'Affectations'),
      if (_isPointeur)
        _NavItem(Icons.assignment_rounded,
            Icons.assignment_outlined, 'Opérations'),
      _NavItem(Icons.more_horiz_rounded,
          Icons.more_horiz_outlined, 'Plus'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _white,
        border: const Border(top: BorderSide(color: _border, width: 0.5)),
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
                  (i == items.length - 1 &&
                      _selectedIndex >= items.length - 1);
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i == items.length - 1) {
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
                          color: sel ? _tealBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          sel ? items[i].activeIcon : items[i].icon,
                          size: 22,
                          color: sel ? _teal : _muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? _teal : _muted,
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

  // ── More sheet ────────────────────────────────────────────────────
  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final extras = [
          _MoreItem(4, Icons.history_rounded, 'Historique',
              _amber, _amberBg),
          _MoreItem(5, Icons.calendar_month_rounded, 'Calendrier',
              _green, _greenBg),
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
                      child:
                          Icon(e.icon, color: e.color, size: 20),
                    ),
                    title: Text(e.label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _ink)),
                    trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: _muted),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _selectedIndex = e.index);
                    },
                  )),
              const Divider(color: _border, height: 24),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4),
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
        return GestionCongesScreen(token: widget.token);
      case 2:
        return GestionAffectationsScreen(token: widget.token);
      case 3:
        if (_isPointeur) return OperationsScreen(token: widget.token);
        return _buildHomeTab();
      case 4:
        return HistoryScreen(token: widget.token);
      case 5:
        return CalendarScreen(token: widget.token);
      default:
        return _buildHomeTab();
    }
  }

  // ── Home Tab ──────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: _teal,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _teal,
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
                _buildProfileCard(),
                const SizedBox(height: 28),
                _sectionLabel('Actions rapides'),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 28),
                _sectionLabel('Aujourd\'hui'),
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

  // ── Hero Header ───────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A7EA4), Color(0xFF0B9086), Color(0xFF0D9E78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Row : avatar + nom + date
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_greeting()},',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fullName,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Text(
                        _profile?.role ?? 'Employé',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Date bloc
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'fr')
                        .format(DateTime.now())
                        .toUpperCase(),
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.65),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2),
                  ),
                  Text(
                    DateFormat('dd', 'fr').format(DateTime.now()),
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1),
                  ),
                  Text(
                    DateFormat('MMM', 'fr').format(DateTime.now()),
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Stat pills ──────────────────────────────────────────
          Row(
            children: [
              _buildHeroStat('5', 'Congés restants'),
              const SizedBox(width: 8),
              _buildHeroStat('2', 'Affectations'),
              const SizedBox(width: 8),
              _buildHeroStat('1', 'En attente'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
          width: size, height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsCircle(size),
        ),
      );
    }
    return _initialsCircle(size);
  }

  Widget _initialsCircle(double size) {
    return Container(
      width: size, height: size,
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

  // ── Profile Card ──────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Avatar teal
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: _tealBg,
                borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _tealDark),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _ink),
                ),
                const SizedBox(height: 3),
                Text(
                  _profile?.email ?? '—',
                  style: const TextStyle(
                      fontSize: 12, color: _muted),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _tealBg,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    _profile?.role ?? 'Employé',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _tealDark),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: _muted),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _muted,
          letterSpacing: 0.8),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = _isPointeur
        ? [
            _Action(1, Icons.calendar_today_rounded, 'Mes Congés',
                'Demander un congé', _teal, _tealBg),
            _Action(2, Icons.people_rounded, 'Affectations',
                'Voir mes postes', _violet, _violetBg),
            _Action(3, Icons.assignment_rounded, 'Opérations',
                'Opérations du jour', _amber, _amberBg),
            _Action(5, Icons.calendar_month_rounded, 'Calendrier',
                'Voir le planning', _green, _greenBg),
          ]
        : [
            _Action(1, Icons.calendar_today_rounded, 'Mes Congés',
                'Demander un congé', _teal, _tealBg),
            _Action(2, Icons.people_rounded, 'Affectations',
                'Voir mes postes', _violet, _violetBg),
            _Action(4, Icons.history_rounded, 'Historique',
                'Consulter l\'activité', _amber, _amberBg),
            _Action(5, Icons.calendar_month_rounded, 'Calendrier',
                'Voir le planning', _green, _greenBg),
          ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: actions
          .map((a) => GestureDetector(
                onTap: () => setState(() => _selectedIndex = a.index),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                            color: a.bg,
                            borderRadius:
                                BorderRadius.circular(10)),
                        child: Icon(a.icon,
                            color: a.color, size: 17),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(a.title,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _ink)),
                          const SizedBox(height: 1),
                          Text(a.subtitle,
                              style: const TextStyle(
                                  fontSize: 10, color: _muted),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Icon(Icons.arrow_forward_rounded,
                              size: 13, color: _muted),
                        ],
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ── Today Card ────────────────────────────────────────────────────
  Widget _buildTodayCard() {
    final now = DateTime.now();
    final dateStr =
        DateFormat('EEEE d MMMM yyyy', 'fr').format(now);
    final capitalized =
        dateStr[0].toUpperCase() + dateStr.substring(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: _tealBg,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calendar_today_rounded,
                color: _teal, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalized,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _ink),
                ),
                const SizedBox(height: 4),
                Text(
                  'Connecté en tant que ${_profile?.role ?? 'Employé'}',
                  style: const TextStyle(
                      fontSize: 11, color: _muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border, width: 0.5)),
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

class _Action {
  final int index;
  final IconData icon;
  final String title, subtitle;
  final Color color, bg;
  const _Action(this.index, this.icon, this.title, this.subtitle,
      this.color, this.bg);
}

class _MoreItem {
  final int index;
  final IconData icon;
  final String label;
  final Color color, bg;
  const _MoreItem(
      this.index, this.icon, this.label, this.color, this.bg);
}