import 'package:flutter/material.dart';
import '../../../../services/admin_service.dart';
import '../../../../models/admin_models.dart';

class NaviresScreen extends StatefulWidget {
  final String token;
  const NaviresScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<NaviresScreen> createState() => _NaviresScreenState();
}

class _NaviresScreenState extends State<NaviresScreen> {
  late AdminApiService _apiService;
  List<NavireModel> navires = [];
  bool isLoading = false;
  bool showForm = false;

  final TextEditingController nomController = TextEditingController();
  final TextEditingController numeroIMOController = TextEditingController();

  // ── Palette (identique à PostesScreen) ───────────────────────────────
  static const _ink       = Color(0xFF0F172A);
  static const _slate     = Color(0xFF64748B);
  static const _border    = Color(0xFFE2E8F0);
  static const _surface   = Color(0xFFF8FAFC);
  static const _accent    = Color(0xFF6366F1);
  static const _accentSoft= Color(0xFFEEF2FF);
  static const _danger    = Color(0xFFEF4444);
  static const _dangerSoft= Color(0xFFFEF2F2);
  static const _success   = Color(0xFF10B981);
  // ─────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _apiService = AdminApiService();
    _loadNavires();
  }

  @override
  void dispose() {
    nomController.dispose();
    numeroIMOController.dispose();
    super.dispose();
  }

  // ── Toggle form ───────────────────────────────────────────────────────

  void _toggleForm() {
    setState(() => showForm = !showForm);
    if (!showForm) _clearControllers();
  }

  void _clearForm() {
    setState(() => showForm = false);
    _clearControllers();
  }

  void _clearControllers() {
    nomController.clear();
    numeroIMOController.clear();
  }

  // ── API calls ─────────────────────────────────────────────────────────

  Future<void> _loadNavires() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.getAllNavires(widget.token);
      setState(() {
        navires = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _createNavire() async {
    if (nomController.text.trim().isEmpty ||
        numeroIMOController.text.trim().isEmpty) {
      _showSnack('Tous les champs sont obligatoires', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      await _apiService.createNavire(
        widget.token,
        nomController.text.trim(),
        numeroIMOController.text.trim(),
      );
      _clearForm();
      await _loadNavires();
      if (mounted) _showSnack('Navire créé avec succès');
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _updateNavire(NavireModel navire) async {
    final nomCtrl = TextEditingController(text: navire.nom);
    final imoCtrl = TextEditingController(text: navire.numeroIMO);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dialog header ──
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: _accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Modifier le navire',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _ink)),
                        Text(
                          navire.nom,
                          style: const TextStyle(
                              fontSize: 12, color: _slate),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, false),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: _slate),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: _border, height: 1),
              const SizedBox(height: 24),

              _dialogField(nomCtrl, 'Nom du navire',
                  Icons.directions_boat_rounded),
              const SizedBox(height: 14),
              _dialogField(imoCtrl, 'Numéro IMO', Icons.tag_rounded),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: _outlineBtn(
                        'Annuler', () => Navigator.pop(ctx, false)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _solidBtn(
                        'Enregistrer', () => Navigator.pop(ctx, true)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      setState(() => isLoading = true);
      try {
        await _apiService.updateNavire(
          widget.token,
          navire.id,
          nomCtrl.text.trim(),
          imoCtrl.text.trim(),
        );
        await _loadNavires();
        if (mounted) _showSnack('Navire mis à jour');
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) _showSnack('Erreur: $e', isError: true);
      }
    }
  }

  Future<void> _deleteNavire(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: _dangerSoft,
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _danger, size: 28),
              ),
              const SizedBox(height: 18),
              const Text('Supprimer ce navire ?',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _ink)),
              const SizedBox(height: 8),
              const Text(
                'Cette action est irréversible. Le navire sera définitivement supprimé.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 13, color: _slate, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _outlineBtn(
                          'Annuler', () => Navigator.pop(ctx, false))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Supprimer',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      try {
        await _apiService.deleteNavire(widget.token, id);
        await _loadNavires();
        if (mounted) _showSnack('Navire supprimé');
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) _showSnack('Erreur: $e', isError: true);
      }
    }
  }

  // ── Snackbar ──────────────────────────────────────────────────────────

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: isError ? _danger : _success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Shared widget helpers ─────────────────────────────────────────────

  Widget _dialogField(
      TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _slate,
                letterSpacing: 0.3)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 14, color: _ink),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 17, color: _slate),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
            filled: true,
            fillColor: _surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _slate,
                letterSpacing: 0.4)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 13, color: _ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
            prefixIcon: Icon(icon, size: 16, color: _slate),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            filled: true,
            fillColor: _surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _solidBtn(String label, VoidCallback onTap) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _outlineBtn(String label, VoidCallback onTap) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _slate,
          side: const BorderSide(color: _border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: _accent, strokeWidth: 2))
          : RefreshIndicator(
              onRefresh: _loadNavires,
              color: _accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      child: showForm
                          ? Column(
                              children: [
                                AnimatedOpacity(
                                  opacity: showForm ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 280),
                                  child: _buildFormCard(),
                                ),
                                const SizedBox(height: 20),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    _buildNaviresList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Navires',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.4)),
          Text('Gestion de la flotte maritime',
              style: TextStyle(fontSize: 11, color: _slate, height: 1.3)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _border, height: 1),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.directions_boat_rounded,
            label: 'Total navires',
            value: navires.length.toString(),
            color: _accent,
            bg: _accentSoft,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            icon: Icons.tag_rounded,
            label: 'Numéros IMO',
            value: navires
                .where((n) => n.numeroIMO.isNotEmpty)
                .length
                .toString(),
            color: _success,
            bg: const Color(0xFFECFDF5),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        height: 1)),
                const SizedBox(height: 2),
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: _slate),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.directions_boat_rounded,
                    color: _accent, size: 18),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nouveau navire',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink)),
                  Text('Renseignez les informations du navire',
                      style: TextStyle(fontSize: 12, color: _slate)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 20),

          // 2-column row
          Row(
            children: [
              Expanded(
                child: _formField(
                  nomController,
                  'Nom du navire',
                  Icons.directions_boat_rounded,
                  hint: 'Ex: MSC Céleste',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _formField(
                  numeroIMOController,
                  'Numéro IMO',
                  Icons.tag_rounded,
                  hint: 'Ex: IMO 9321483',
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(child: _outlineBtn('Annuler', _clearForm)),
              const SizedBox(width: 12),
              Expanded(
                  child: _solidBtn('Créer le navire', _createNavire)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNaviresList() {
    if (navires.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.directions_boat_outlined,
                  size: 34, color: _accent),
            ),
            const SizedBox(height: 16),
            const Text('Aucun navire enregistré',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
            const SizedBox(height: 6),
            const Text('Ajoutez votre premier navire via le bouton +',
                style: TextStyle(fontSize: 13, color: _slate)),
          ],
        ),
      );
    }

    final sorted = List<NavireModel>.from(navires)
      ..sort((a, b) => a.nom.compareTo(b.nom));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text('Flotte',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${navires.length} navire(s)',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _accent)),
                ),
              ],
            ),
          ),

          const Divider(color: _border, height: 1),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            separatorBuilder: (_, __) =>
                const Divider(color: _border, height: 1, indent: 20),
            itemBuilder: (context, index) =>
                _buildNavireRow(sorted[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildNavireRow(NavireModel navire) {
    // Initiales du nom pour le badge
    final initials = navire.nom
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Avatar avec initiales
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _accent),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  navire.nom,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.tag_rounded,
                        size: 11, color: _slate),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        navire.numeroIMO.isNotEmpty
                            ? navire.numeroIMO
                            : 'Numéro IMO non défini',
                        style: TextStyle(
                            fontSize: 11,
                            color: navire.numeroIMO.isNotEmpty
                                ? _slate
                                : _slate.withOpacity(0.6),
                            fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconAction(
                icon: Icons.edit_rounded,
                color: _accent,
                bg: _accentSoft,
                onTap: () => _updateNavire(navire),
              ),
              const SizedBox(width: 8),
              _iconAction(
                icon: Icons.delete_rounded,
                color: _danger,
                bg: _dangerSoft,
                onTap: () => _deleteNavire(navire.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _toggleForm,
      backgroundColor: _accent,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          showForm ? Icons.close_rounded : Icons.add_rounded,
          key: ValueKey(showForm),
        ),
      ),
      label: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          showForm ? 'Fermer' : 'Ajouter',
          key: ValueKey(showForm),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}