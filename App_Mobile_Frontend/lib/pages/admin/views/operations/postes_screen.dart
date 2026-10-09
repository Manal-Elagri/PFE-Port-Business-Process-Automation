import 'package:flutter/material.dart';
import '../../../../services/admin_service.dart';
import '../../../../models/admin_models.dart';
import '../../../../config/theme_config.dart';

class PostesScreen extends StatefulWidget {
  final String token;
  const PostesScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<PostesScreen> createState() => _PostesScreenState();
}

class _PostesScreenState extends State<PostesScreen>
    with SingleTickerProviderStateMixin {
  late AdminApiService _apiService;
  List<PosteModel> postes = [];
  bool isLoading = false;
  bool showForm = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final TextEditingController numeroController = TextEditingController();
  final TextEditingController localisationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  // ── Palette ──────────────────────────────────────────────────────────
  static const _ink = Color(0xFF0F172A);       // slate-900
  static const _slate = Color(0xFF64748B);     // slate-500
  static const _border = Color(0xFFE2E8F0);    // slate-200
  static const _surface = Color(0xFFF8FAFC);   // slate-50
  static const _accent = Color(0xFF6366F1);    // indigo-500
  static const _accentSoft = Color(0xFFEEF2FF);// indigo-50
  static const _danger = Color(0xFFEF4444);
  static const _dangerSoft = Color(0xFFFEF2F2);
  static const _success = Color(0xFF10B981);
  // ─────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _apiService = AdminApiService();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadPostes();
  }

  @override
  void dispose() {
    _animController.dispose();
    numeroController.dispose();
    localisationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() => showForm = !showForm);
    if (showForm) {
      _animController.forward();
    } else {
      _animController.reverse();
      _clearControllers();
    }
  }

  void _clearControllers() {
    numeroController.clear();
    localisationController.clear();
    latitudeController.clear();
    longitudeController.clear();
  }

  void _clearForm() {
    setState(() => showForm = false);
    _animController.reverse();
    _clearControllers();
  }

  Future<void> _loadPostes() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.getPostes(widget.token);
      setState(() {
        postes = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _createPoste() async {
    if ([
      numeroController,
      localisationController,
      latitudeController,
      longitudeController
    ].any((c) => c.text.isEmpty)) {
      _showSnack('Tous les champs sont obligatoires', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      await _apiService.createPoste(
        widget.token,
        int.parse(numeroController.text),
        localisationController.text,
        double.parse(latitudeController.text),
        double.parse(longitudeController.text),
      );
      _clearForm();
      await _loadPostes();
      if (mounted) _showSnack('Poste créé avec succès');
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _updatePoste(PosteModel poste) async {
    final nCtrl = TextEditingController(text: poste.numeroPoste.toString());
    final lCtrl = TextEditingController(text: poste.localisation);
    final latCtrl = TextEditingController(text: poste.latitude.toString());
    final lonCtrl = TextEditingController(text: poste.longitude.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_location_alt_rounded,
                        color: _accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modifier le poste',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                      Text('Poste N°${poste.numeroPoste}',
                          style:
                              const TextStyle(fontSize: 13, color: _slate)),
                    ],
                  ),
                  const Spacer(),
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

              _dialogField(nCtrl, 'Numéro du poste', Icons.tag_rounded,
                  type: TextInputType.number),
              const SizedBox(height: 14),
              _dialogField(
                  lCtrl, 'Localisation', Icons.place_rounded),
              const SizedBox(height: 14),
              _dialogField(latCtrl, 'Latitude', Icons.straighten_rounded,
                  type: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 14),
              _dialogField(lonCtrl, 'Longitude', Icons.straighten_rounded,
                  type: const TextInputType.numberWithOptions(decimal: true)),

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
        await _apiService.updatePoste(
          widget.token,
          poste.id,
          int.parse(nCtrl.text),
          lCtrl.text,
          double.parse(latCtrl.text),
          double.parse(lonCtrl.text),
        );
        await _loadPostes();
        if (mounted) _showSnack('Poste mis à jour');
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) _showSnack('Erreur: $e', isError: true);
      }
    }
  }

  Future<void> _deletePoste(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
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
              const Text('Supprimer ce poste ?',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 8),
              const Text(
                  'Cette action est irréversible. Le poste sera définitivement supprimé.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _slate, height: 1.5)),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
        await _apiService.deletePoste(widget.token, id);
        await _loadPostes();
        if (mounted) _showSnack('Poste supprimé');
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) _showSnack('Erreur: $e', isError: true);
      }
    }
  }

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
                        fontSize: 13, fontWeight: FontWeight.w500))),
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

  // ── Shared widget helpers ──────────────────────────────────────────────

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

  Widget _solidBtn(String label, VoidCallback onTap) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _outlineBtn(String label, VoidCallback onTap) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _slate,
          side: const BorderSide(color: _border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _accent, strokeWidth: 2))
          : RefreshIndicator(
              onRefresh: _loadPostes,
              color: _accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    if (showForm) ...[
                      FadeTransition(
                          opacity: _fadeAnim, child: _buildFormCard()),
                      const SizedBox(height: 20),
                    ],
                    _buildPostesList(),
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
          Text('Postes',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.4)),
          Text('Gestion des points de surveillance',
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
    final withLocation =
        postes.where((p) => p.localisation.isNotEmpty).length;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.location_on_rounded,
            label: 'Total postes',
            value: postes.length.toString(),
            color: _accent,
            bg: _accentSoft,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            icon: Icons.place_rounded,
            label: 'Localisés',
            value: withLocation.toString(),
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
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
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
                    style: const TextStyle(fontSize: 11, color: _slate),
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
                child:
                    const Icon(Icons.add_location_alt_rounded, color: _accent, size: 18),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nouveau poste',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink)),
                  Text('Renseignez les informations du poste',
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
                child: _formField(numeroController, 'Numéro',
                    Icons.tag_rounded, TextInputType.number),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _formField(localisationController, 'Localisation',
                    Icons.place_rounded, TextInputType.text,
                    hint: 'Ex: Terminal A'),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _formField(
                    latitudeController,
                    'Latitude',
                    Icons.swap_vert_rounded,
                    const TextInputType.numberWithOptions(decimal: true),
                    hint: 'Ex: 36.8065'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _formField(
                    longitudeController,
                    'Longitude',
                    Icons.swap_horiz_rounded,
                    const TextInputType.numberWithOptions(decimal: true),
                    hint: 'Ex: 10.1815'),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(child: _outlineBtn('Annuler', _clearForm)),
              const SizedBox(width: 12),
              Expanded(child: _solidBtn('Créer le poste', _createPoste)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon,
      TextInputType type,
      {String? hint}) {
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
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
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

  Widget _buildPostesList() {
    if (postes.isEmpty) {
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
                  color: _accentSoft, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.location_off_rounded,
                  size: 34, color: _accent),
            ),
            const SizedBox(height: 16),
            const Text('Aucun poste enregistré',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
            const SizedBox(height: 6),
            const Text('Ajoutez votre premier poste via le bouton +',
                style: TextStyle(fontSize: 13, color: _slate)),
          ],
        ),
      );
    }

    final sorted = List<PosteModel>.from(postes)
      ..sort((a, b) => a.numeroPoste.compareTo(b.numeroPoste));

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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text('Liste des postes',
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
                  child: Text('${postes.length} entrées',
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
                _buildPosteRow(sorted[index], index),
          ),
        ],
      ),
    );
  }

  Widget _buildPosteRow(PosteModel poste, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(0),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _accentSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${poste.numeroPoste}',
                  style: const TextStyle(
                      fontSize: 15,
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
                    poste.localisation.isNotEmpty
                        ? poste.localisation
                        : 'Localisation non définie',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: poste.localisation.isNotEmpty
                            ? _ink
                            : _slate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.my_location_rounded,
                          size: 11, color: _slate),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${poste.latitude.toStringAsFixed(4)}, ${poste.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: _slate,
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
                  onTap: () => _updatePoste(poste),
                ),
                const SizedBox(width: 8),
                _iconAction(
                  icon: Icons.delete_rounded,
                  color: _danger,
                  bg: _dangerSoft,
                  onTap: () => _deletePoste(poste.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
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