import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/admin_service.dart';

class CreateShiftsView extends StatefulWidget {
  final String token;
  final int planningId;
  final DateTime selectedDate;

  const CreateShiftsView({
    super.key,
    required this.token,
    required this.planningId,
    required this.selectedDate,
  });

  @override
  State<CreateShiftsView> createState() => _CreateShiftsViewState();
}

class _CreateShiftsViewState extends State<CreateShiftsView> {
  // ─── État ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;

  // ─── Service ──────────────────────────────────────────────────────────────
  final AdminApiService _api = AdminApiService();

  // ─── Constantes ───────────────────────────────────────────────────────────
  static const _primaryColor = Color(0xFF1B42C4);

  /// Définition des 3 shifts par défaut (doit correspondre aux @RequestParam du backend)
  static const List<_ShiftDefinition> _defaultShifts = [
    _ShiftDefinition(
      type: 'SHIFT_1',
      label: 'Shift 1 — Matin',
      debut: '08:00:00',
      fin: '16:00:00',
      displayHours: '08:00 → 16:00',
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFFAEEDA),
      iconColor: Color(0xFF854F0B),
    ),
    _ShiftDefinition(
      type: 'SHIFT_2',
      label: 'Shift 2 — Soir',
      debut: '16:00:00',
      fin: '00:00:00',
      displayHours: '16:00 → 00:00',
      icon: Icons.cloud_outlined,
      color: Color(0xFFE6F1FB),
      iconColor: Color(0xFF0C447C),
    ),
    _ShiftDefinition(
      type: 'SHIFT_3',
      label: 'Shift 3 — Nuit',
      debut: '00:00:00',
      fin: '08:00:00',
      displayHours: '00:00 → 08:00',
      icon: Icons.nightlight_outlined,
      color: Color(0xFFEAF3DE),
      iconColor: Color(0xFF3B6D11),
    ),
  ];

  // ─── Logique métier ───────────────────────────────────────────────────────

  /// Crée les 3 shifts en parallèle et navigue en arrière si tout réussit
  Future<void> _saveAllShifts() async {
    setState(() => _isLoading = true);

    final results = await Future.wait(
      _defaultShifts.map(
        (s) => _api.createShift(
          widget.token,
          widget.planningId,
          s.type,
          s.debut,
          s.fin,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final allSucceeded = results.every((ok) => ok);

    if (allSucceeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les 3 shifts ont été créés avec succès !'),
          backgroundColor: Color(0xFF3B6D11),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      final failed = results.where((ok) => !ok).length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$failed shift(s) n\'ont pas pu être créés. Vérifiez la connexion.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Interface ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(widget.selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Configuration · $dateLabel'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau de confirmation du planning
            _buildPlanningBanner(dateLabel),

            // Liste des shifts
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Shifts à créer'),
                    const SizedBox(height: 8),
                    ..._defaultShifts.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ShiftCard(definition: s),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoNote(),
                  ],
                ),
              ),
            ),

            // Bouton de validation
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningBanner(String dateLabel) {
    return Container(
      width: double.infinity,
      color: _primaryColor,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          const Icon(Icons.event_available, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planning #${widget.planningId}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                dateLabel,
                style:
                    TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF0C447C), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ces 3 shifts seront liés au planning #${widget.planningId}. '
              'Vous pourrez modifier leurs horaires et affecter des managers après la création.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0C447C),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _saveAllShifts,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_outlined, color: Colors.white),
          label: Text(
            _isLoading ? 'Création en cours...' : 'Valider et sauvegarder',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── Modèle immuable d'un shift à créer ──────────────────────────────────────

class _ShiftDefinition {
  final String type;
  final String label;
  final String debut;
  final String fin;
  final String displayHours;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _ShiftDefinition({
    required this.type,
    required this.label,
    required this.debut,
    required this.fin,
    required this.displayHours,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}

class _ShiftCard extends StatelessWidget {
  final _ShiftDefinition definition;
  const _ShiftCard({required this.definition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icône du shift
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: definition.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(definition.icon, color: definition.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(definition.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(definition.displayHours,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
          // Badge prêt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Prêt',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B6D11))),
          ),
        ],
      ),
    );
  }
}