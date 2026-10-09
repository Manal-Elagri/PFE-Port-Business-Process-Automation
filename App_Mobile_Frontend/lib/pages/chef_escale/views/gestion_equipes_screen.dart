import 'package:flutter/material.dart';
import '../../../services/chef_escale_service.dart';
import '../../../models/chef_escale_models.dart';

class GestionEquipesScreen extends StatefulWidget {
  final String token;
  const GestionEquipesScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<GestionEquipesScreen> createState() => _GestionEquipesScreenState();
}

class _GestionEquipesScreenState extends State<GestionEquipesScreen> {
  final ChefEscaleApiService _api = ChefEscaleApiService();

  List<EquipeModel>  _equipes      = [];
  List<ShiftModel>   _activeShifts = [];
  ShiftModel?        _selectedShift;
  bool               _loading  = false;
  bool               _showForm = false;

  final _matriculeCtrl = TextEditingController();

  // ── Palette ───────────────────────────────────────────────────────
  static const _ink        = Color(0xFF0F172A);
  static const _slate      = Color(0xFF64748B);
  static const _border     = Color(0xFFE2E8F0);
  static const _surface    = Color(0xFFF8FAFC);
  static const _accent     = Color(0xFF6366F1);
  static const _accentSoft = Color(0xFFEEF2FF);
  static const _danger     = Color(0xFFEF4444);
  static const _dangerSoft = Color(0xFFFEF2F2);
  static const _success    = Color(0xFF10B981);
  static const _successSoft= Color(0xFFECFDF5);
  static const _warn       = Color(0xFFF59E0B);
  static const _warnSoft   = Color(0xFFFFFBEB);
  // ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _matriculeCtrl.dispose();
    super.dispose();
  }

  // ── Load ──────────────────────────────────────────────────────────
  // On charge les équipes ET les shifts séparément (pas de Future.wait
  // pour éviter le cast List<dynamic>)
  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // 1. Charger les shifts actifs
      final shifts = await _api.getActiveShifts(widget.token);

      // 2. Charger toutes mes équipes SANS filtrage
      //    Le backend /equipes/chef retourne déjà les équipes du chef connecté
      final equipes = await _api.getMyEquipes(widget.token);

      setState(() {
        _activeShifts = shifts;
        // ✅ Affiche TOUTES les équipes retournées par le backend
        _equipes  = equipes ?? [];
        _loading  = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showSnack('Erreur de chargement: $e', isError: true);
    }
  }

  // ── Create ────────────────────────────────────────────────────────
  Future<void> _create() async {
    if (_selectedShift == null) {
      _showSnack('Veuillez sélectionner un shift', isError: true);
      return;
    }
    if (_matriculeCtrl.text.trim().isEmpty) {
      _showSnack('Le matricule est obligatoire', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await _api.createEquipe(
        widget.token,
        _selectedShift!.id,
        _matriculeCtrl.text.trim(),
      );

      if (res != null) {
        _matriculeCtrl.clear();
        setState(() {
          _selectedShift = null;
          _showForm      = false;
        });
        await _load();
        _showSnack('Équipe "${res.matriculeEquipe}" créée avec succès');
      } else {
        setState(() => _loading = false);
        _showSnack('Échec de la création', isError: true);
      }
    } catch (e) {
      setState(() => _loading = false);
      _showSnack('Erreur: $e', isError: true);
    }
  }

  // ── Update ────────────────────────────────────────────────────────
  Future<void> _showUpdate(EquipeModel equipe) async {
    final ctrl = TextEditingController(text: equipe.matriculeEquipe);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: _accentSoft,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.edit_rounded,
                        color: _accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Modifier l\'équipe',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _ink)),
                        Text(equipe.matriculeEquipe,
                            style: const TextStyle(
                                fontSize: 12, color: _slate)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, false),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: _slate),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: _border, height: 1),
              const SizedBox(height: 20),

              _fieldLabel('Nouveau matricule'),
              const SizedBox(height: 6),
              TextField(
                controller: ctrl,
                style: const TextStyle(fontSize: 14, color: _ink),
                decoration: _inputDeco(Icons.badge_rounded,
                    hint: 'Ex: EQ-001'),
              ),

              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: _outlineBtn(
                      'Annuler', () => Navigator.pop(ctx, false))),
                  const SizedBox(width: 12),
                  Expanded(child: _solidBtn(
                      'Enregistrer', () => Navigator.pop(ctx, true))),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      if (ctrl.text.trim().isEmpty) {
        _showSnack('Le matricule est obligatoire', isError: true);
        return;
      }
      setState(() => _loading = true);
      try {
        final res = await _api.updateEquipe(
            widget.token, equipe.id, ctrl.text.trim());
        if (res != null) {
          await _load();
          _showSnack('Équipe mise à jour avec succès');
        } else {
          setState(() => _loading = false);
          _showSnack('Échec de la mise à jour', isError: true);
        }
      } catch (e) {
        setState(() => _loading = false);
        _showSnack('Erreur: $e', isError: true);
      }
    }
    ctrl.dispose();
  }

  // ── Delete ────────────────────────────────────────────────────────
  Future<void> _delete(EquipeModel equipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                    color: _dangerSoft,
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _danger, size: 28),
              ),
              const SizedBox(height: 18),
              const Text('Supprimer cette équipe ?',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _ink)),
              const SizedBox(height: 8),
              Text(
                'L\'équipe "${equipe.matriculeEquipe}" sera définitivement supprimée.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _slate, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _outlineBtn(
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
      setState(() => _loading = true);
      try {
        final ok = await _api.deleteEquipe(widget.token, equipe.id);
        if (ok) {
          // Suppression locale immédiate sans recharger
          setState(() {
            _equipes.removeWhere((e) => e.id == equipe.id);
            _loading = false;
          });
          _showSnack('Équipe "${equipe.matriculeEquipe}" supprimée');
        } else {
          setState(() => _loading = false);
          _showSnack('Échec de la suppression', isError: true);
        }
      } catch (e) {
        setState(() => _loading = false);
        _showSnack('Erreur: $e', isError: true);
      }
    }
  }

  // ── Snackbar ──────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: Colors.white, size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: isError ? _danger : _success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Widget helpers ────────────────────────────────────────────────
  Widget _fieldLabel(String t) => Text(t,
      style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: _slate, letterSpacing: 0.4));

  InputDecoration _inputDeco(IconData icon, {String? hint}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: Color(0xFFCBD5E1), fontSize: 13),
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
      );

  // ── Shift dropdown ────────────────────────────────────────────────
  Widget _shiftDropdown({
    required ShiftModel? value,
    required ValueChanged<ShiftModel?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ShiftModel>(
          value: value,
          isExpanded: true,
          hint: Row(children: const [
            Icon(Icons.access_time_rounded, size: 16, color: _slate),
            SizedBox(width: 8),
            Text('Sélectionner un shift',
                style: TextStyle(
                    color: Color(0xFFCBD5E1), fontSize: 13)),
          ]),
          items: _activeShifts.map((ShiftModel s) {
            return DropdownMenuItem<ShiftModel>(
              value: s,
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _shiftBg(s.type),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _shiftLabel(s.type),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _shiftColor(s.type)),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${s.heureDebut.length >= 5 ? s.heureDebut.substring(0, 5) : s.heureDebut}'
                    ' – '
                    '${s.heureFin.length >= 5 ? s.heureFin.substring(0, 5) : s.heureFin}',
                    style: const TextStyle(
                        fontSize: 13, color: _ink),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (s.planningDate != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    s.planningDate!.length >= 10
                        ? s.planningDate!.substring(5, 10)
                        : s.planningDate!,
                    style: const TextStyle(
                        fontSize: 10, color: _slate),
                  ),
                ],
              ]),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _solidBtn(String label, VoidCallback onTap) =>
      ElevatedButton(
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

  Widget _outlineBtn(String label, VoidCallback onTap) =>
      OutlinedButton(
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

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
      );

  // ── Shift colors ──────────────────────────────────────────────────
  String _shiftLabel(String t) {
    switch (t) {
      case 'SHIFT_1': return 'S1';
      case 'SHIFT_2': return 'S2';
      case 'SHIFT_3': return 'S3';
      default:        return t.replaceFirst('SHIFT_', 'S');
    }
  }

  Color _shiftColor(String t) {
    switch (t) {
      case 'SHIFT_1': return _accent;
      case 'SHIFT_2': return _success;
      case 'SHIFT_3': return _warn;
      default:        return _slate;
    }
  }

  Color _shiftBg(String t) {
    switch (t) {
      case 'SHIFT_1': return _accentSoft;
      case 'SHIFT_2': return _successSoft;
      case 'SHIFT_3': return _warnSoft;
      default:        return _surface;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: _accent, strokeWidth: 2))
          : RefreshIndicator(
              onRefresh: _load,
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
                      child: _showForm
                          ? Column(children: [
                              AnimatedOpacity(
                                opacity: _showForm ? 1.0 : 0.0,
                                duration:
                                    const Duration(milliseconds: 280),
                                child: _buildFormCard(),
                              ),
                              const SizedBox(height: 20),
                            ])
                          : const SizedBox.shrink(),
                    ),
                    _buildEquipesList(),
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
          Text('Équipes',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.4)),
          Text('Gestion de mes équipes',
              style: TextStyle(
                  fontSize: 11, color: _slate, height: 1.3)),
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
            icon: Icons.groups_rounded,
            label: 'Total équipes',
            value: _equipes.length.toString(),
            color: _accent,
            bg: _accentSoft,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            icon: Icons.access_time_rounded,
            label: 'Shifts actifs',
            value: _activeShifts.length.toString(),
            color: _success,
            bg: _successSoft,
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
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
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
                    style: const TextStyle(
                        fontSize: 11, color: _slate),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Form card ─────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return StatefulBuilder(
      builder: (ctx, setSt) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.group_add_rounded,
                      color: _accent, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nouvelle équipe',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                      Text('Créer une équipe pour un shift',
                          style: TextStyle(
                              fontSize: 12, color: _slate)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: _border, height: 1),
            const SizedBox(height: 20),

            _fieldLabel('Matricule de l\'équipe'),
            const SizedBox(height: 6),
            TextField(
              controller: _matriculeCtrl,
              style: const TextStyle(fontSize: 13, color: _ink),
              decoration: _inputDeco(Icons.badge_rounded,
                  hint: 'Ex: EQ-001'),
            ),

            const SizedBox(height: 14),

            _fieldLabel('Shift associé'),
            const SizedBox(height: 6),

            // ✅ Affiche un warning si aucun shift actif
            _activeShifts.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _warnSoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _warn.withOpacity(0.4)),
                    ),
                    child: Row(children: const [
                      Icon(Icons.warning_amber_rounded,
                          size: 16, color: _warn),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Aucun shift actif disponible. Tirez vers le bas pour rafraîchir.',
                          style: TextStyle(
                              fontSize: 12,
                              color: _warn,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ]),
                  )
                : _shiftDropdown(
                    value: _selectedShift,
                    onChanged: (ShiftModel? v) =>
                        setSt(() => _selectedShift = v),
                  ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(child: _outlineBtn('Annuler', () {
                  setState(() {
                    _showForm      = false;
                    _selectedShift = null;
                  });
                  _matriculeCtrl.clear();
                })),
                const SizedBox(width: 12),
                Expanded(child: _solidBtn('Créer', _create)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Equipes list ──────────────────────────────────────────────────
  Widget _buildEquipesList() {
    if (_equipes.isEmpty) {
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
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.groups_rounded,
                  size: 34, color: _accent),
            ),
            const SizedBox(height: 16),
            const Text('Aucune équipe',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
            const SizedBox(height: 6),
            const Text(
                'Créez votre première équipe via le bouton +',
                style: TextStyle(fontSize: 13, color: _slate)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text('Mes équipes',
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
                  child: Text('${_equipes.length} équipe(s)',
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
            itemCount: _equipes.length,
            separatorBuilder: (_, __) =>
                const Divider(color: _border, height: 1, indent: 20),
            itemBuilder: (_, i) => _buildEquipeRow(_equipes[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipeRow(EquipeModel equipe) {
    final shift = equipe.shift;
    final color = shift != null ? _shiftColor(shift.type) : _slate;
    final bg    = shift != null ? _shiftBg(shift.type) : _surface;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Badge shift
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                shift != null ? _shiftLabel(shift.type) : '—',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipe.matriculeEquipe.isNotEmpty
                      ? equipe.matriculeEquipe
                      : 'Équipe #${equipe.id}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _ink),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                if (shift != null)
                  Row(children: [
                    const Icon(Icons.schedule_rounded,
                        size: 11, color: _slate),
                    const SizedBox(width: 4),
                    Text(
                      '${shift.heureDebut.length >= 5 ? shift.heureDebut.substring(0, 5) : shift.heureDebut}'
                      ' – '
                      '${shift.heureFin.length >= 5 ? shift.heureFin.substring(0, 5) : shift.heureFin}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: _slate,
                          fontFamily: 'monospace'),
                    ),
                  ]),

                if (shift?.planningDate != null) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 11, color: _slate),
                    const SizedBox(width: 4),
                    Text(
                      shift!.planningDate!,
                      style: const TextStyle(
                          fontSize: 11, color: _slate),
                    ),
                  ]),
                ],

                if (equipe.chefEquipe != null) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.person_rounded,
                        size: 11, color: _slate),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${equipe.chefEquipe!.prenom} ${equipe.chefEquipe!.nom}',
                        style: const TextStyle(
                            fontSize: 11, color: _slate),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconBtn(
                icon: Icons.edit_rounded,
                color: _accent,
                bg: _accentSoft,
                onTap: () => _showUpdate(equipe),
              ),
              const SizedBox(width: 8),
              _iconBtn(
                icon: Icons.delete_rounded,
                color: _danger,
                bg: _dangerSoft,
                onTap: () => _delete(equipe),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => setState(() => _showForm = !_showForm),
      backgroundColor: _accent,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _showForm ? Icons.close_rounded : Icons.add_rounded,
          key: ValueKey(_showForm),
        ),
      ),
      label: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          _showForm ? 'Fermer' : 'Ajouter',
          key: ValueKey(_showForm),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}