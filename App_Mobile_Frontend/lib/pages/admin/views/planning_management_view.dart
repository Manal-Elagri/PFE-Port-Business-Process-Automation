import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_shifts_view.dart';
import '../../../services/admin_service.dart';

class PlanningManagementView extends StatefulWidget {
  final String token;
  const PlanningManagementView({super.key, required this.token});

  @override
  State<PlanningManagementView> createState() => _PlanningManagementViewState();
}

class _PlanningManagementViewState extends State<PlanningManagementView> {
  // ─── État ─────────────────────────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // ─── Service ──────────────────────────────────────────────────────────────
  final AdminApiService _api = AdminApiService();

  // ─── Constantes visuelles ─────────────────────────────────────────────────
  static const _primaryColor = Color(0xFF1B42C4);

  // ─── Logique métier ───────────────────────────────────────────────────────

  /// Formate la date sélectionnée pour l'affichage (ex : "Samedi 7 juin 2025")
  String get _formattedDateLabel =>
  DateFormat('dd/MM/yyyy').format(_selectedDate);
  /// Crée le planning sur le backend et navigue vers la création des shifts
  Future<void> _handleCreatePlanning() async {
    setState(() => _isLoading = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final result = await _api.createPlanning(widget.token, dateStr);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null) {
      final int planningId = result['id'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateShiftsView(
            token: widget.token,
            planningId: planningId,
            selectedDate: _selectedDate,
          ),
        ),
      );
    } else {
      _showError('Ce planning existe déjà ou la connexion est impossible.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Interface ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Planification'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête bleu avec date sélectionnée
            _buildHeader(),

            // Calendrier
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Sélectionner une date'),
                    const SizedBox(height: 8),
                    _buildCalendar(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Shifts qui seront créés'),
                    const SizedBox(height: 8),
                    _buildShiftPreview(),
                  ],
                ),
              ),
            ),

            // Bouton d'action
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: _primaryColor,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formattedDateLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionnez une date pour initialiser un planning',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: CalendarDatePicker(
        initialDate: _selectedDate,
        firstDate: DateTime(2025),
        lastDate: DateTime(2030),
        onDateChanged: (d) => setState(() => _selectedDate = d),
      ),
    );
  }

  Widget _buildShiftPreview() {
    final shifts = [
      _ShiftPreviewData(
        label: 'Shift 1 — Matin',
        hours: '08:00 → 16:00',
        icon: Icons.wb_sunny_outlined,
        color: const Color(0xFFFAEEDA),
        iconColor: const Color(0xFF854F0B),
      ),
      _ShiftPreviewData(
        label: 'Shift 2 — Soir',
        hours: '16:00 → 00:00',
        icon: Icons.cloud_outlined,
        color: const Color(0xFFE6F1FB),
        iconColor: const Color(0xFF0C447C),
      ),
      _ShiftPreviewData(
        label: 'Shift 3 — Nuit',
        hours: '00:00 → 08:00',
        icon: Icons.nightlight_outlined,
        color: const Color(0xFFEAF3DE),
        iconColor: const Color(0xFF3B6D11),
      ),
    ];

    return Column(
      children: shifts
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ShiftPreviewTile(data: s),
              ))
          .toList(),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleCreatePlanning,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add_circle_outline, color: Colors.white),
          label: Text(
            _isLoading ? 'Création en cours...' : 'Initialiser les 3 shifts',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

// ─── Données de prévisualisation d'un shift ───────────────────────────────────

class _ShiftPreviewData {
  final String label;
  final String hours;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _ShiftPreviewData({
    required this.label,
    required this.hours,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}

class _ShiftPreviewTile extends StatelessWidget {
  final _ShiftPreviewData data;
  const _ShiftPreviewTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(data.hours,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline,
              color: Color(0xFF3B6D11), size: 18),
        ],
      ),
    );
  }
}