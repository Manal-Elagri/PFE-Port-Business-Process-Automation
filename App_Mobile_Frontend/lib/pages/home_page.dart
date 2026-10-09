import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'role_selection_page.dart';
import 'ai_assistant_page.dart';


// ─── COULEURS ─────────────────────────────────────────────────────────────────
class AppColors {
  static const navy      = Color(0xFF0A1628);
  static const navyMid   = Color(0xFF112244);
  static const blue      = Color(0xFF1A3FBF);
  static const blueLight = Color(0xFF3A60E0);
  static const cyan      = Color(0xFF00C8F0);
  static const gold      = Color(0xFFE8A000);
  static const goldLight = Color(0xFFFFCC55);
  static const surface   = Color(0xFFF4F6FB);
  static const white     = Color(0xFFFFFFFF);
  static const textDark  = Color(0xFF08142A);
  static const textGray  = Color(0xFF4A5A7A);
  static const textLight = Color(0xFF9AABCC);
  static const divider   = Color(0xFFDDE5F8);
  static const success   = Color(0xFF00A86B);
  static const cardBg    = Color(0xFFFFFFFF);
}

// ─── PAGE PRINCIPALE AVEC NAVIGATION ─────────────────────────────────────────
class PublicHomePage extends StatefulWidget {
  const PublicHomePage({super.key});

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    _AIAssistantTab(),
    _SettingsTab(),
     Scaffold(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.navy.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Accueil',
                selected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),

               _NavItem(
                icon: Icons.account_circle_rounded, // Icône de profil
                label: 'Profil',
                selected: false, // On ne le laisse pas sélectionné car on change de page
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                  );
                   },
              ),
              
               _NavItem(
                  icon: Icons.smart_toy_rounded,
                  label: 'Assistant IA',
                  selected: false, // On ne le sélectionne pas, car c'est une redirection
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AIAssistantPage()),
                    );
                  },
                ),
             
               _NavItem(
                icon: Icons.settings_rounded,
                label: 'Paramètres',
                selected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _MarsaLogo extends StatelessWidget {
  final double size;
  const _MarsaLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: Center(
        child: Text('M',
          style: TextStyle(color: AppColors.blue, fontSize: size * 0.6, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ─── NAV ITEM ─────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.blue.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: selected ? AppColors.blue : AppColors.textLight),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? AppColors.blue : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONGLET 1 — ACCUEIL
// ═══════════════════════════════════════════════════════════════════════════════
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _heroAnim;
  late AnimationController _waveAnim;
  late VideoPlayerController _videoController;

  bool _isVideoInitialized = false;
  double _scrollOffset = 0;
  int _activeGallery = 0;
  final PageController _galleryCtrl = PageController();

  final _galleryItems = const [
    _GalleryItem('assets/images/tcr_aerial.jpg', 'Terminal TCR', 'Vue aérienne — 56 ha'),
    _GalleryItem('assets/images/tcr_cranes.jpg', 'Équipements', '8 grues Ship-to-Shore'),
    _GalleryItem('assets/images/marsa_team.png', 'Notre équipe', 'Excellence & Innovation'),
    _GalleryItem('assets/images/tcr_operations.jpg', 'Opérations', '24/7 Activités'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() => setState(() => _scrollOffset = _scrollController.offset));

    _heroAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _waveAnim = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _startAutoPlay();
    });

    _videoController = VideoPlayerController.asset('assets/videos/port_intro.mp4')
      ..initialize().then((_) {
        if (mounted) setState(() => _isVideoInitialized = true);
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
      });
  }

  void _startAutoPlay() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      final next = (_activeGallery + 1) % _galleryItems.length;
      _galleryCtrl.animateToPage(next, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
      return true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroAnim.dispose();
    _waveAnim.dispose();
    _galleryCtrl.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHero(),
            _buildStats(),
            _buildAboutSection(),
            _buildServicesSection(),
            _buildMarsaCard(),
            _buildContactSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final scrolled = _scrollOffset > 50;
    return AppBar(
      backgroundColor: scrolled ? AppColors.navy.withOpacity(0.97) : Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _MarsaLogo(size: 32),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('MARSA MAROC',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.8)),
                Text('Terminal TCR · Casablanca',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9.5, letterSpacing: 0.3)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navy,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            minimumSize: Size.zero,
          ),
          child: const Text('Connexion',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.3)),
        ),
        ),
      ],
    );
  }

  // ── HERO ───────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return SizedBox(
      height: 560,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _isVideoInitialized
              ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              )
              : Image.asset(
                'assets/images/port_casablanca.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0A1628), Color(0xFF1A3FBF)],
                    ),
                  ),
                ),
              ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.navy.withOpacity(0.25),
                  AppColors.navy.withOpacity(0.5),
                  AppColors.navy.withOpacity(0.92),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AnimatedBuilder(
              animation: _waveAnim,
              builder: (_, __) => CustomPaint(
                size: const Size(double.infinity, 100),
                painter: _WavePainter(_waveAnim.value),
              ),
            ),
          ),

          Positioned(
            bottom: 60, left: 20, right: 20,
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: _heroAnim, curve: const Interval(0.2, 1.0, curve: Curves.easeOut))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.gold.withOpacity(0.45)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 5, height: 5,
                          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('1er port du Maroc — Casablanca',
                          style: TextStyle(color: AppColors.goldLight, fontSize: 10,
                            fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Trafics Conteneur\net Roulier',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800,
                      height: 1.1, letterSpacing: -0.8)),
                  const SizedBox(height: 8),
                  Text('Plateforme d\'automatisation\ndes processus portuaires.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _HeroButton(label: 'En savoir plus', icon: Icons.arrow_forward_rounded, primary: true, onTap: () {}),
                      const SizedBox(width: 12),
                      _HeroButton(label: 'Nous contacter', icon: Icons.mail_outline_rounded, primary: false, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS ─────────────────────────────────────────────────────────────────
  Widget _buildStats() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const _StatTile(value: '350K', unit: 'EVP/an', label: 'Capacité', icon: Icons.inventory_2_rounded, color: AppColors.blue),
                  _VDivider(),
                  const _StatTile(value: '56', unit: 'ha', label: 'Superficie', icon: Icons.map_rounded, color: AppColors.gold),
                  _VDivider(),
                  const _StatTile(value: '24/7', unit: '', label: 'Opérations', icon: Icons.schedule_rounded, color: AppColors.success),
                ],
              ),
              const SizedBox(height: 10),
              Container(height: 0.8, color: AppColors.divider),
              const SizedBox(height: 10),
              Row(
                children: [
                  const _StatTile(value: '8', unit: 'STS', label: 'Grues quai', icon: Icons.precision_manufacturing_rounded, color: Color(0xFF7C3AED)),
                  _VDivider(),
                  const _StatTile(value: '1200', unit: 'm', label: 'Linéaire quai', icon: Icons.anchor_rounded, color: Color(0xFF0097C7)),
                  _VDivider(),
                  const _StatTile(value: '98%', unit: '', label: 'Conformité', icon: Icons.verified_rounded, color: AppColors.success),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ABOUT (GALERIE) ────────────────────────────────────────────────────────
  Widget _buildAboutSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(tag: 'À propos', title: 'Découvrez TCR'),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _galleryCtrl,
                onPageChanged: (i) => setState(() => _activeGallery = i),
                itemCount: _galleryItems.length,
                itemBuilder: (_, i) => _GalleryPage(item: _galleryItems[i]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_galleryItems.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _activeGallery == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _activeGallery == i ? AppColors.blue : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Text(
              'Le Terminal à Conteneurs de Récupération (TCR) est une infrastructure stratégique du port de Casablanca. Géré par Marsa Maroc, il constitue un maillon essentiel dans la chaîne logistique nationale.',
              style: TextStyle(color: AppColors.textGray, fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── SERVICES (DESIGN PROFESSIONNEL) ───────────────────────────────────────
  Widget _buildServicesSection() {
    final services = [
      const _Service(Icons.inventory_2_rounded, 'Conteneurs vides', 'Réception et restitution rapide', AppColors.blue),
      const _Service(Icons.directions_boat_rounded, 'Accueil navires', 'Coordination des escales', Color(0xFF00A876)),
      const _Service(Icons.local_shipping_rounded, 'Transport terrestre', 'Interface logistique', AppColors.gold),
      const _Service(Icons.security_rounded, 'Contrôle & conformité', 'Inspection douanière', Color(0xFF7C3AED)),
      const _Service(Icons.analytics_rounded, 'Suivi temps réel', 'Tableau de bord digital', Color(0xFF0097C7)),
      const _Service(Icons.workspace_premium_rounded, 'Certification ISO', 'ISO 9001 & ISPS', AppColors.success),
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(tag: 'Nos Services', title: 'Solutions intégrées'),
          const SizedBox(height: 6),
          GridView.builder(
             // 2. SUPPRIME L'ESPACE INUTILE EN HAUT DE LA GRILLE
            padding: EdgeInsets.zero, 
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: services.length,
            itemBuilder: (_, i) => _ServiceCard(service: services[i]),
          ),
        ],
      ),
    );
  }

  // ── MARSA MAROC (CARTE UNIFIÉE) ──────────────────────────────────────────
  Widget _buildMarsaCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(tag: 'À propos', title: 'Marsa Maroc'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('M',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Marsa Maroc',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          Text('Opérateur portuaire national',
                            style: TextStyle(fontSize: 12, color: AppColors.textGray)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Marsa Maroc est l\'opérateur portuaire de référence au Maroc. Présente dans 11 ports du Royaume, elle gère des terminaux à conteneurs avec les plus hauts standards internationaux.',
                  style: TextStyle(fontSize: 13, color: AppColors.textGray, height: 1.6),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _MarsaInfoItem('2006', 'Fondée en')),
                    const SizedBox(width: 8),
                    Expanded(child: _MarsaInfoItem('5 800+', 'Collaborateurs')),
                    const SizedBox(width: 8),
                    Expanded(child: _MarsaInfoItem('11', 'Ports gérés')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CONTACT (SECTION AMÉLIORÉE) ───────────────────────────────────────────
  Widget _buildContactSection() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(tag: 'Contact', title: 'Prenez contact'),
          const SizedBox(height: 16),
          _ContactCardModern(
            icon: Icons.location_on_rounded,
            title: 'Adresse',
            content: 'TCR — Port de Casablanca\n20000 Casablanca, Maroc',
            color: AppColors.blue,
          ),
          const SizedBox(height: 12),
          _ContactCardModern(
            icon: Icons.phone_rounded,
            title: 'Téléphone',
            content: '+212 (0) 522 23 10 11\nDisponible 24/7',
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _ContactCardModern(
            icon: Icons.email_rounded,
            title: 'Email',
            content: 'tcr@marsamaroc.co.ma',
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }

  // ── FOOTER ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MarsaLogo(size: 24),
              const SizedBox(width: 8),
              const Text('MARSA MAROC',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Terminal TCR — Port de Casablanca',
            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10.5), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 8),
          Text('© 2026 Marsa Maroc. Tous droits réservés.',
            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMPOSANTS RÉUTILISABLES
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String tag;
  final String title;

  const _SectionHeader({required this.tag, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blue.withOpacity(0.3)),
          ),
          child: Text(tag,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.blue, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 8),
        Text(title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.2)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.value, required this.unit, required this.label,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          if (unit.isNotEmpty)
            Text(unit, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
          const SizedBox(height: 3),
          Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textGray),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.divider);
  }
}

class _Service {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _Service(this.icon, this.title, this.description, this.color);
}

class _ServiceCard extends StatelessWidget {
  final _Service service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: service.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(service.icon, color: service.color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(service.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(service.description,
            style: const TextStyle(fontSize: 11, color: AppColors.textGray, height: 1.4),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _MarsaInfoItem extends StatelessWidget {
  final String value;
  final String label;

  const _MarsaInfoItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.blue)),
          const SizedBox(height: 4),
          Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textGray),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ContactCardModern extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _ContactCardModern({
    required this.icon, required this.title, required this.content, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(content,
                  style: const TextStyle(fontSize: 12, color: AppColors.textGray, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _HeroButton({
    required this.label, required this.icon, required this.primary, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: primary ? AppColors.gold : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: !primary ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: primary ? AppColors.navy : Colors.white,
                )),
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: primary ? AppColors.navy : Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryItem {
  final String image;
  final String title;
  final String subtitle;

  const _GalleryItem(this.image, this.title, this.subtitle);
}

class _GalleryPage extends StatelessWidget {
  final _GalleryItem item;

  const _GalleryPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(item.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
          return Container(color: AppColors.surface);
        }),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, AppColors.navy.withOpacity(0.6)],
            ),
          ),
        ),
        Positioned(
          bottom: 12, left: 12, right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(item.subtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final double wavePhase;

  _WavePainter(this.wavePhase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    const amplitude = 8.0;
    const frequency = 2.0;

    path.moveTo(0, size.height * 0.5);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.5 +
          amplitude * math.sin((x / size.width + wavePhase) * frequency * math.pi);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.wavePhase != wavePhase;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONGLETS SECONDAIRES
// ═══════════════════════════════════════════════════════════════════════════════

class _AIAssistantTab extends StatelessWidget {
  const _AIAssistantTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant IA')),
      body: const Center(child: Text('Assistant IA - À venir')),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text('Paramètres', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PROFIL CLIQUABLE
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(color: AppColors.navy.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Utilisateur TCR", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Cliquer pour se connecter", 
                          style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
