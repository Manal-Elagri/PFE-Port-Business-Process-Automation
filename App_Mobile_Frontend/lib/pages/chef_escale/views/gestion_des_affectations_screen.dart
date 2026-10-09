import 'package:flutter/material.dart';
import '../../../services/chef_escale_service.dart';
import '../../../models/chef_escale_models.dart';

// ─── Enum rôles personnel ─────────────────────────────────────
enum RolePersonnel {
  POINTEUR,
  OPERATEUR,
  OUVRIER,
  GRUTIER,
  TECHNICIEN,
  AGENT_CONTROLE;

  String get label {
    switch (this) {
      case RolePersonnel.POINTEUR:          return 'Pointeur';
      case RolePersonnel.OPERATEUR:         return 'Opérateur';
      case RolePersonnel.OUVRIER:           return 'Ouvrier';
      case RolePersonnel.GRUTIER:           return 'Grutier';
      case RolePersonnel.TECHNICIEN:        return 'Technicien';
      case RolePersonnel.AGENT_CONTROLE: return 'Agent de contrôle';
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────
class GestionDesAffectationsScreen extends StatefulWidget {
  final String token;

  const GestionDesAffectationsScreen({Key? key, required this.token})
      : super(key: key);

  @override
  State<GestionDesAffectationsScreen> createState() =>
      _GestionDesAffectationsScreenState();
}

class _GestionDesAffectationsScreenState
    extends State<GestionDesAffectationsScreen> {
  final ChefEscaleApiService api = ChefEscaleApiService();

  // ── State ──────────────────────────────────────────────────
  List<EquipeModel>   equipes    = [];
  List<PersonnelModel> employes  = [];
  List<PersonnelModel> chefs     = [];

  EquipeModel?    selectedEquipe;
  List<_PendingAffectation> pendingAffectations = [];
  PersonnelModel? selectedChef;
  

  bool loading = false;

  // ── Colors ─────────────────────────────────────────────────
  static const _bg         = Color(0xFFF5F6FA);
  static const _surface    = Colors.white;
  static const _border      = Color(0xFFE4E7EF);
  static const _textPrimary = Color(0xFF111827);
  static const _textMuted   = Color(0xFF6B7280);
  static const _blue        = Color(0xFF185FA5);
  static const _blueLight   = Color(0xFFE6F1FB);
  static const _amber       = Color(0xFF854F0B);
  static const _amberLight  = Color(0xFFFAEEDA);

  // ── Init ───────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => loading = true);

    final eq = await api.getMyEquipes(widget.token);
    final emp = await api.getEmployes(widget.token);
    final ch  = await api.getChefsEquipes(widget.token);

    setState(() {
      equipes  = eq ?? [];
      employes = emp;
      chefs    = ch;
      loading  = false;
    });
  }

  // ── Dialogs ────────────────────────────────────────────────
  Future<bool> _confirm(String msg) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text('Confirmation',
              style: const TextStyle(
                  color: _textPrimary, fontWeight: FontWeight.w500)),
          content: Text(msg,
              style: const TextStyle(color: _textMuted)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Annuler',
                  style: TextStyle(color: _textMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ) ??
      false;

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Future.delayed(const Duration(seconds: 1),
            () => Navigator.pop(context));
        return const Center(
          child: Icon(Icons.check_circle_rounded,
              color: Colors.green, size: 90),
        );
      },
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Une erreur est survenue'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

    // ── Ajouter une affectation à la liste ─────────────────────────
  void _ajouterAffectation(PersonnelModel p, RolePersonnel role) {
    // Éviter les doublons
    final dejaPresent = pendingAffectations.any((a) => a.personnel.id == p.id);
    if (dejaPresent) {
      _showSnack('${p.prenom} ${p.nom} est déjà dans la liste');
      return;
    }
    setState(() {
      pendingAffectations.add(_PendingAffectation(personnel: p, role: role));
    });
  }

  // ── Ouvrir le picker avec sélection de rôle ────────────────────
  void _ouvrirPickerAvecRole() {
    PersonnelModel? tempPersonnel;
    RolePersonnel? tempRole;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E7EF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text('Ajouter un personnel',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500,
                      color: Color(0xFF111827))),
              const SizedBox(height: 16),

              // ── Choix employé ──────────────────────────────
              const Text('Employé',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE4E7EF), width: 0.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PersonnelModel>(
                    value: tempPersonnel,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    hint: const Text('Sélectionner...',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                    items: employes
                      // Filtrer ceux déjà ajoutés
                      .where((e) => !pendingAffectations
                          .any((a) => a.personnel.id == e.id))
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: const Color(0xFFE6F1FB),
                                  child: Text(
                                    '${p.prenom[0]}${p.nom[0]}',
                                    style: const TextStyle(
                                        color: Color(0xFF185FA5),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('${p.prenom} ${p.nom}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF111827))),
                              ],
                            ),
                          ))
                      .toList(),
                    onChanged: (v) => setModal(() => tempPersonnel = v),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Choix rôle ─────────────────────────────────
              const Text('Rôle métier',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RolePersonnel.values.map((r) {
                  final sel = tempRole == r;
                  return GestureDetector(
                    onTap: () => setModal(() => tempRole = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFFE6F1FB)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFF185FA5)
                              : const Color(0xFFE4E7EF),
                          width: sel ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(r.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: sel
                                ? const Color(0xFF185FA5)
                                : const Color(0xFF6B7280),
                          )),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ── Bouton ajouter ─────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF185FA5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    // Désactivé si incomplet
                    disabledBackgroundColor: const Color(0xFFB5D4F4),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Ajouter à la liste',
                      style: TextStyle(fontSize: 14)),
                  onPressed: (tempPersonnel != null && tempRole != null)
                      ? () {
                          Navigator.pop(context);
                          _ajouterAffectation(tempPersonnel!, tempRole!);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Confirmer toutes les affectations ──────────────────────────
  Future<void> _confirmerToutesAffectations() async {
    if (selectedEquipe == null) {
      _showSnack('Veuillez sélectionner une équipe');
      return;
    }
    if (pendingAffectations.isEmpty) {
      _showSnack('Aucun personnel à affecter');
      return;
    }

    final ok = await _confirm(
        'Affecter ${pendingAffectations.length} personnel(s) à '
        '${selectedEquipe!.matriculeEquipe} ?');
    if (!ok) return;

    bool allOk = true;

    for (final a in pendingAffectations) {
      final res = await api.assignPersonnel(
        widget.token,
        selectedEquipe!.id,
        a.personnel.id,
        a.role.name,
      );
      if (!res) allOk = false;
    }

    if (allOk) {
      setState(() => pendingAffectations.clear());
      _showSuccess();
    } else {
      _showError();
    }
  }

  // ── Pickers ────────────────────────────────────────────────
  void _pickPersonnel(List<PersonnelModel> list,
      ValueChanged<PersonnelModel> onPick) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...list.map((p) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _blueLight,
                    child: Text(
                      '${p.prenom[0]}${p.nom[0]}',
                      style: const TextStyle(
                          color: _blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  title: Text('${p.prenom} ${p.nom}',
                      style: const TextStyle(
                          color: _textPrimary, fontSize: 14)),
                  subtitle: Text(p.role,
                      style: const TextStyle(
                          color: _textMuted, fontSize: 12)),
                  onTap: () {
                    onPick(p);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────
  

  Future<void> _assignChef() async {
    if (selectedEquipe == null) {
      _showSnack('Veuillez sélectionner une équipe');
      return;
    }
    if (selectedChef == null) {
      _showSnack('Veuillez sélectionner un chef d\'équipe');
      return;
    }

    final ok = await _confirm(
        'Affecter ${selectedChef!.prenom} ${selectedChef!.nom} '
        'comme chef d\'équipe ?');
    if (!ok) return;

    final res = await api.assignChefEquipe(
      widget.token,
      selectedEquipe!.id,
      selectedChef!.id,
    );

    res ? _showSuccess() : _showError();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Gestion des affectations',
            style: TextStyle(
                color: _textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w500)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: _border),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Équipe ─────────────────────────────────
                  _SectionLabel(text: 'Équipe'),
                  const SizedBox(height: 6),
                  _Card(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<EquipeModel>(
                        value: selectedEquipe,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: _textMuted),
                        hint: const Text('Sélectionner une équipe...',
                            style: TextStyle(color: _textMuted, fontSize: 14)),
                        items: equipes
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.matriculeEquipe,
                                      style: const TextStyle(
                                          color: _textPrimary, fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => selectedEquipe = v),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Section 1 : Personnel ──────────────────
                  _SectionCard(
                    iconData: Icons.person_add_alt_1_rounded,
                    iconBg: _blueLight,
                    iconColor: _blue,
                    title: 'Affecter un personnel',
                    children: [
                      // ── Liste des affectations en attente ──
                      if (pendingAffectations.isNotEmpty) ...[
                        ...pendingAffectations.asMap().entries.map((entry) {
                          final i = entry.key;
                          final a = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE4E7EF), width: 0.5),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: const Color(0xFFB5D4F4),
                                  child: Text(
                                    '${a.personnel.prenom[0]}${a.personnel.nom[0]}',
                                    style: const TextStyle(
                                      color: Color(0xFF0C447C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${a.personnel.prenom} ${a.personnel.nom}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF111827),
                                        ),
                                      ),

                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<RolePersonnel>(
                                          value: a.role,
                                          isDense: true,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B7280),
                                          ),
                                          items: RolePersonnel.values
                                              .map(
                                                (r) => DropdownMenuItem(
                                                  value: r,
                                                  child: Text(r.label),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (r) {
                                            if (r != null) {
                                              setState(() => pendingAffectations[i].role = r);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () =>
                                      setState(() => pendingAffectations.removeAt(i)),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 8),
                      ],

                      // ── bouton ajouter ──
                      GestureDetector(
                        onTap: _ouvrirPickerAvecRole,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF185FA5), width: 0.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 16, color: Color(0xFF185FA5)),
                              SizedBox(width: 6),
                              Text(
                                'Ajouter un personnel',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF185FA5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFE4E7EF)),
                      const SizedBox(height: 16),

                      // ── bouton confirmer ──
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF185FA5),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(
                            pendingAffectations.isEmpty
                                ? 'Confirmer l\'affectation'
                                : 'Confirmer (${pendingAffectations.length})',
                            style: const TextStyle(fontSize: 14),
                          ),
                          onPressed: pendingAffectations.isEmpty
                              ? null
                              : _confirmerToutesAffectations,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Section 2 : Chef d'équipe ──────────────
                  _SectionCard(
                    iconData: Icons.workspace_premium_rounded,
                    iconBg: _amberLight,
                    iconColor: _amber,
                    title: 'Affecter un chef d\'équipe',
                    children: [
                      _FieldLabel(text: 'Chef d\'équipe'),
                      const SizedBox(height: 6),
                      if (selectedChef != null)
                        _PersonnelChip(
                          personnel: selectedChef!,
                          avatarBg: _amberLight,
                          avatarColor: _amber,
                          onTap: () => _pickPersonnel(
                              chefs,
                              (p) => setState(() => selectedChef = p)),
                        )
                      else
                        _PickerButton(
                          label: 'Sélectionner un chef d\'équipe...',
                          icon: Icons.search_rounded,
                          onTap: () => _pickPersonnel(
                              chefs,
                              (p) => setState(() => selectedChef = p)),
                        ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _amber,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(
                              Icons.workspace_premium_rounded, size: 18),
                          label: const Text('Affecter chef d\'équipe',
                              style: TextStyle(fontSize: 14)),
                          onPressed: _assignChef,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// ─── Widgets internes ──────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
            letterSpacing: 0.3),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280)),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E7EF), width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: child,
      );
}

class _SectionCard extends StatelessWidget {
  final IconData iconData;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E7EF), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFFE4E7EF), width: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(iconData, color: iconColor, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children),
            ),
          ],
        ),
      );
}

class _PersonnelChip extends StatelessWidget {
  final PersonnelModel personnel;
  final Color avatarBg;
  final Color avatarColor;
  final VoidCallback onTap;

  const _PersonnelChip({
    required this.personnel,
    required this.avatarBg,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFFE4E7EF), width: 0.5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarBg,
                child: Text(
                  '${personnel.prenom[0]}${personnel.nom[0]}',
                  style: TextStyle(
                      color: avatarColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${personnel.prenom} ${personnel.nom}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827))),
                    Text(personnel.role,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              const Icon(Icons.swap_horiz_rounded,
                  size: 16, color: Color(0xFF6B7280)),
            ],
          ),
        ),
      );
}

class _PickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFFE4E7EF), width: 0.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      );
}

// ─── Model local pour une affectation en attente ───────────────
class _PendingAffectation {
  final PersonnelModel personnel;
  RolePersonnel role;

  _PendingAffectation({required this.personnel, required this.role});
}