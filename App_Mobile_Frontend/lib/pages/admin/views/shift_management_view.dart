import 'package:flutter/material.dart';
import '../../../services/admin_service.dart';
import '../../../models/admin_models.dart';

class ShiftManagementView extends StatefulWidget {
  final String token;
  final int shiftId;
  

  const ShiftManagementView({
    super.key,
    required this.token,
    required this.shiftId,
    
  });

  

  @override
  State<ShiftManagementView> createState() => _ShiftManagementViewState();
}

enum _ShiftStatus { enCours, termine, pretACommencer, planifie, inconnu }


class _ShiftManagementViewState extends State<ShiftManagementView> {
  final AdminApiService _api = AdminApiService();
  static const _primaryColor = Color(0xFF1B42C4);
  static const _darkBlue = Color(0xFF0A2166);
  static const _primaryBlue = Color(0xFF1238A8);
  static const _accentBlue = Color(0xFF185FA5);
  static const _lightBlue = Color(0xFFE6F1FB);
  static const _tealBg = Color(0xFFE1F5EE);
  static const _tealText = Color(0xFF0F6E56);
  static const _amberBg = Color(0xFFFAEEDA);
  static const _amberText = Color(0xFF854F0B);
  static const _purpleBg = Color(0xFFEEEDFE);
  static const _purpleText = Color(0xFF534AB7);
  static const _redBorder = Color(0xFFF7C1C1);
  static const _redText = Color(0xFFA32D2D);
  static const _redBg = Color(0xFFFCEBEB);
  static const _successGreen = Color(0xFF34D399);


  // ← NOUVEAU : état du shift chargé depuis l'API
  ShiftModel? _shift;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShift(); // ← charger au démarrage
  }

  // ← NOUVEAU : charge les infos du shift (managers inclus)
  Future<void> _loadShift() async {
    final shift = await _api.getShiftById(widget.token, widget.shiftId);
    if (mounted) setState(() { _shift = shift; _isLoading = false; });
  }
  // ── HELPERS ────────────────────────────────────────────────────

  String _getLabel(String type) {
    switch (type) {
      case 'SHIFT_1': return 'Matin';
      case 'SHIFT_2': return 'Soir';
      case 'SHIFT_3': return 'Nuit';
      default: return type;
    }
  }

  String _getTimeRange(String type) {
    switch (type) {
      case 'SHIFT_1': return '08:00 → 16:00';
      case 'SHIFT_2': return '16:00 → 00:00';
      case 'SHIFT_3': return '00:00 → 08:00';
      default: return '--:-- → --:--';
    }
  }

  // ─── Statut dynamique du shift ────────────────────────────────────────────

  /// Retourne le statut du shift basé sur la date du planning + heures
  _ShiftStatus _computeStatus() {
    if (_shift == null) return _ShiftStatus.inconnu;

    // On a besoin de la date du planning — elle vient de ShiftModel
    // Assurez-vous que ShiftModel a un champ 'planningDate' (voir point ci-dessous)
    final dateStr = _shift!.planningDate; // ex: "2026-06-09"
    if (dateStr == null) return _ShiftStatus.inconnu;

    final date = DateTime.parse(dateStr);
    final debut = _parseTime(_shift!.heureDebut); // "08:00:00"
    final fin = _parseTime(_shift!.heureFin);     // "16:00:00"

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';

    // Construire les DateTime complets
    DateTime startDt = DateTime(date.year, date.month, date.day, debut.hour, debut.minute);
    DateTime endDt   = DateTime(date.year, date.month, date.day, fin.hour,   fin.minute);

    // Shift de nuit (fin < debut) → fin passe au lendemain
    if (fin.hour < debut.hour) {
      endDt = endDt.add(const Duration(days: 1));
    }

    if (now.isAfter(endDt)) return _ShiftStatus.termine;
    if (now.isAfter(startDt) && now.isBefore(endDt)) return _ShiftStatus.enCours;
    if (dateStr == todayStr && now.isBefore(startDt)) return _ShiftStatus.pretACommencer;
    if (date.isAfter(now)) return _ShiftStatus.planifie;
    return _ShiftStatus.termine;
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // ── ACTIONS ────────────────────────────────────────────────────

  Future<void> _handleUpdateTimes() async {
    final debutCtrl = TextEditingController(text: '08:00:00');
    final finCtrl = TextEditingController(text: '16:00:00');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Modifier les horaires',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField('Début (HH:mm:ss)', debutCtrl, Icons.play_arrow_rounded),
            const SizedBox(height: 12),
            _buildDialogField('Fin (HH:mm:ss)', finCtrl, Icons.stop_rounded),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await _api.updateShift(widget.token, widget.shiftId, debutCtrl.text, finCtrl.text);
      _showFeedback(ok, 'Horaires mis à jour avec succès');
    }
  }

  Future<void> _handleAssignManagers() async {
  // ── Vérification : managers déjà affectés ──
  if (_shift?.chefService != null && _shift?.chefDivision != null) {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Managers déjà affectés'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ce shift a déjà des managers assignés :',
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 12),
            _managerInfoRow(
              Icons.manage_accounts,
              'Chef de Service',
              '${_shift!.chefService!.nom} ${_shift!.chefService!.prenom}',
            ),
            const SizedBox(height: 8),
            _managerInfoRow(
              Icons.supervisor_account,
              'Chef de Division',
              '${_shift!.chefDivision!.nom} ${_shift!.chefDivision!.prenom}',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Voulez-vous les remplacer ?',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600),
            child: const Text('Remplacer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    // Si l'utilisateur a annulé, on arrête
    if (!mounted) return;
  }

  // ── Chargement des listes ──
  final results = await Future.wait([
    _api.getPersonnelByRole(widget.token, 'chefs-services'),
    _api.getPersonnelByRole(widget.token, 'chefs-divisions'),
  ]);

  final chefsService = results[0];
  final chefsDivision = results[1];

  if (!mounted) return;

  PersonnelModel? selectedChefS;
  PersonnelModel? selectedChefD;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setStateDialog) => AlertDialog(
        title: const Text('Affecter les managers'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chef de Service',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PersonnelModel>(
                    isExpanded: true,
                    hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Sélectionner un chef de service'),
                    ),
                    value: selectedChefS,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    borderRadius: BorderRadius.circular(8),
                    items: chefsService.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.nom} ${p.prenom}',
                          style: const TextStyle(fontSize: 14)),
                    )).toList(),
                    onChanged: (val) => setStateDialog(() => selectedChefS = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Chef de Division',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PersonnelModel>(
                    isExpanded: true,
                    hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Sélectionner un chef de division'),
                    ),
                    value: selectedChefD,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    borderRadius: BorderRadius.circular(8),
                    items: chefsDivision.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.nom} ${p.prenom}',
                          style: const TextStyle(fontSize: 14)),
                    )).toList(),
                    onChanged: (val) => setStateDialog(() => selectedChefD = val),
                  ),
                ),
              ),
              if (selectedChefS != null || selectedChefD != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F1FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedChefS != null)
                        Row(children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFF0C447C), size: 14),
                          const SizedBox(width: 6),
                          Text('Service: ${selectedChefS!.nom} ${selectedChefS!.prenom}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF0C447C))),
                        ]),
                      if (selectedChefD != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFF0C447C), size: 14),
                          const SizedBox(width: 6),
                          Text('Division: ${selectedChefD!.nom} ${selectedChefD!.prenom}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF0C447C))),
                        ]),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: (selectedChefS != null && selectedChefD != null)
                ? () => Navigator.pop(ctx, true)
                : null,
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Affecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true && mounted) {
    final ok = await _api.assignManagers(
      widget.token, widget.shiftId,
      selectedChefS!.id, selectedChefD!.id,
    );
    if (ok) {
      await _loadShift(); // ← recharge le shift pour mettre à jour l'affichage
    }
    _showFeedback(ok, 'Managers affectés avec succès');
  }
  }

  // ← NOUVEAU : widget utilitaire pour afficher un manager
  Widget _managerInfoRow(IconData icon, String role, String nom) {
  return Row(
    children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F1FB),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: const Color(0xFF1B42C4), size: 16),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          Text(nom, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    ],
  );
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: _redText, size: 20),
            SizedBox(width: 8),
            Text('Confirmer la suppression',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        content: const Text(
          'Cette action est irréversible. Toutes les affectations et l\'historique associés à ce shift seront définitivement supprimés.',
          style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _redText,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await _api.deleteShift(widget.token, widget.shiftId);
      if (ok && mounted) {
        Navigator.pop(context);
        _showFeedback(true, 'Shift supprimé');
      } else {
        _showFeedback(false, 'Erreur lors de la suppression');
      }
    }
  }

  // ── BUILD ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          _buildTopBar(),
          _buildHero(),
          _buildStatusBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Actions'),
                const SizedBox(height: 8),
                _buildActionsCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('Managers affectés'),
                const SizedBox(height: 8),
                _buildManagersCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('Zone de danger'),
                const SizedBox(height: 8),
                _buildDangerZone(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TOP BAR ─────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      color: _darkBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion des shifts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(_shift?.type ?? '').replaceAll('_', ' ')} — ${_getLabel(_shift?.type ?? '')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.5),
            ),
            child: const Text(
              'Actif',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO ────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      color: _primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horaires',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeRange(_shift?.type ?? ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildStatPill('12', 'Agents'),
              const SizedBox(width: 10),
              _buildStatPill('2', 'Managers'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.20), width: 0.5),
      ),
      child: Column(
        children: [
          Text(number,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── STATUS BAR ──────────────────────────────────────────────────

  Widget _buildStatusBar() {
  final status = _computeStatus();

  final Map<_ShiftStatus, Map<String, dynamic>> config = {
    _ShiftStatus.enCours: {
      'label': 'En cours aujourd\'hui',
      'color': const Color(0xFF34D399), // vert
      'icon': Icons.play_circle_outline,
    },
    _ShiftStatus.termine: {
      'label': 'Shift terminé',
      'color': const Color(0xFF9CA3AF), // gris
      'icon': Icons.check_circle_outline,
    },
    _ShiftStatus.pretACommencer: {
      'label': 'Prêt à commencer',
      'color': const Color(0xFFFBBF24), // amber
      'icon': Icons.schedule_rounded,
    },
    _ShiftStatus.planifie: {
      'label': 'Planifié',
      'color': const Color(0xFF60A5FA), // bleu clair
      'icon': Icons.event_outlined,
    },
    _ShiftStatus.inconnu: {
      'label': 'Statut inconnu',
      'color': const Color(0xFF9CA3AF),
      'icon': Icons.help_outline,
    },
  };

  final cfg = config[status]!;
  final Color dotColor = cfg['color'] as Color;
  final String label = cfg['label'] as String;
  final IconData icon = cfg['icon'] as IconData;

  return Container(
    color: _darkBlue,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        // Point animé seulement si en cours
        status == _ShiftStatus.enCours
            ? _PulsingDot(color: dotColor)
            : Container(
                width: 7, height: 7,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
        const SizedBox(width: 8),
        Icon(icon, color: dotColor, size: 14),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        Text('#SH-00${widget.shiftId}',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
                fontFamily: 'monospace',
                letterSpacing: 0.5)),
      ],
    ),
  );
}

  // ── SECTION TITLE ───────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9CA3AF),
      ),
    );
  }

  // ── ACTIONS CARD ────────────────────────────────────────────────

  Widget _buildActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.schedule_rounded,
            iconBg: _lightBlue,
            iconColor: _accentBlue,
            title: 'Modifier les horaires',
            subtitle: 'Début, fin et pauses',
            onTap: _handleUpdateTimes,
            showDivider: true,
          ),
          _buildActionRow(
            icon: Icons.person_add_alt_1_rounded,
            iconBg: _tealBg,
            iconColor: _tealText,
            title: 'Affecter des managers',
            subtitle: 'Chef service & division',
            onTap: _handleAssignManagers,
            showDivider: true,
          ),
          _buildActionRow(
            icon: Icons.history_rounded,
            iconBg: _amberBg,
            iconColor: _amberText,
            title: 'Historique',
            subtitle: 'Toutes les modifications',
            onTap: () async {
            final history = await _api.getShiftHistory(widget.token, widget.shiftId);
            if (!mounted) return;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => _HistorySheet(history: history),
            );
          },
            showDivider: true,
          ),
          _buildActionRow(
            icon: Icons.file_download_outlined,
            iconBg: _purpleBg,
            iconColor: _purpleText,
            title: 'Exporter les données',
            subtitle: 'Rapport PDF / Excel',
            onTap: () {
            if (_shift == null) return;
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Exporter les données',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Shift #${widget.shiftId} — ${_shift!.type}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(height: 20),
                // PDF
                _exportOption(
                  icon: Icons.picture_as_pdf_outlined,
                  color: const Color(0xFFA32D2D),
                  bg: const Color(0xFFFCEBEB),
                  label: 'Exporter en PDF',
                  subtitle: 'Rapport complet du shift',
                  onTap: () {
                    Navigator.pop(context);
                    _showFeedback(true, 'Export PDF — fonctionnalité à venir');
                  },
                ),
                const SizedBox(height: 10),
                // Excel
                _exportOption(
                  icon: Icons.table_chart_outlined,
                  color: const Color(0xFF3B6D11),
                  bg: const Color(0xFFEAF3DE),
                  label: 'Exporter en Excel',
                  subtitle: 'Données tabulaires (CSV)',
                  onTap: () {
                    Navigator.pop(context);
                    _showFeedback(true, 'Export Excel — fonctionnalité à venir');
                  },
                ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _exportOption({
  required IconData icon,
  required Color color,
  required Color bg,
  required String label,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
        ],
      ),
    ),
  );
}

  Widget _buildActionRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 20),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 0.5, indent: 68, color: Color(0xFFE5E7EB)),
      ],
    );
  }

  // ── MANAGERS CARD ───────────────────────────────────────────────

  Widget _buildManagersCard() {
  if (_shift == null) {
    return const SizedBox();
  }

  if (_shift!.chefService == null &&
      _shift!.chefDivision == null) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Aucun manager affecté',
      ),
    );
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFFE5E7EB),
        width: 0.5,
      ),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    child: Column(
      children: [
        if (_shift!.chefService != null)
          _managerInfoRow(
            Icons.manage_accounts,
            'Chef de Service',
            '${_shift!.chefService!.nom} ${_shift!.chefService!.prenom}',
          ),

        if (_shift!.chefService != null &&
            _shift!.chefDivision != null)
          const Divider(),

        if (_shift!.chefDivision != null)
          _managerInfoRow(
            Icons.supervisor_account,
            'Chef de Division',
            '${_shift!.chefDivision!.nom} ${_shift!.chefDivision!.prenom}',
          ),
      ],
    ),
  );
  }

  Widget _buildManagerRow({
    required String initials,
    required String name,
    required String email,
    required String role,
    required Color avatarBg,
    required Color avatarColor,
    required Color badgeBg,
    required Color badgeColor,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: avatarBg,
                child: Text(initials,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: avatarColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Text(email,
                        style:
                            const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(role,
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor)),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
      ],
    );
  }

  // ── DANGER ZONE ─────────────────────────────────────────────────

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _redBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: _redText, size: 17),
              SizedBox(width: 6),
              Text('Action irréversible',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: _redText)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'La suppression de ce shift est définitive. Toutes les affectations et l\'historique associés seront perdus.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 17, color: _redText),
              label: const Text('Supprimer ce shift',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _redText)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF09595), width: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ).copyWith(
                overlayColor: MaterialStateProperty.all(_redBg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DIALOG HELPERS ──────────────────────────────────────────────

  Widget _buildDialogField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, size: 18, color: _accentBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildPickerLabel(String label) {
    return Text(label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)));
  }

  Widget _buildPicker(
    List<PersonnelModel> items,
    PersonnelModel? current,
    Function(PersonnelModel?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<PersonnelModel>(
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text('Sélectionner...', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
        value: current,
        items: items
            .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text('${p.nom} ${p.prenom}',
                      style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ── SNACKBAR ────────────────────────────────────────────────────

  void _showFeedback(bool ok, String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(ok ? msg : 'Une erreur est survenue',
                style: const TextStyle(fontSize: 13)),
          ],
        ),
        backgroundColor: ok ? const Color(0xFF0F6E56) : _redText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7, height: 7,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  final List<dynamic> history;
  const _HistorySheet({required this.history});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          // Poignée
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.history_rounded,
                    color: Color(0xFF1B42C4), size: 20),
                const SizedBox(width: 8),
                const Text('Historique du shift',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${history.length} événement(s)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_toggle_off_outlined,
                            size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text('Aucun historique disponible',
                            style: TextStyle(color: Colors.grey.shade400)),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: ctrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final entry = history[i] as Map<String, dynamic>;
                      final equipe = entry['equipe'] as Map<String, dynamic>?;
                      final chefEscale = entry['chefEscale'] as Map<String, dynamic>?;
                      final dateDebut = entry['dateDebut']?.toString() ?? '—';
                      final dateFin = entry['dateFin']?.toString() ?? 'En cours';
                      final active = entry['active'] as bool? ?? false;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.grey.shade200, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F1FB),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.group_outlined,
                                      color: Color(0xFF1B42C4), size: 15),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    equipe != null
                                        ? 'Équipe #${equipe['id']}'
                                        : 'Équipe inconnue',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? const Color(0xFFEAF3DE)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    active ? 'Active' : 'Terminée',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: active
                                          ? const Color(0xFF3B6D11)
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1, color: Color(0xFFE5E7EB)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _historyInfoItem(Icons.play_arrow_rounded,
                                    'Début', dateDebut),
                                const SizedBox(width: 16),
                                _historyInfoItem(Icons.stop_rounded,
                                    'Fin', dateFin),
                              ],
                            ),
                            if (chefEscale != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 13, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Affecté par : ${chefEscale['nom'] ?? ''} ${chefEscale['prenom'] ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  Widget _historyInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
            Text(value,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}