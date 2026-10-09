import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/admin_service.dart';
import '../../../models/admin_models.dart';
import 'shift_management_view.dart';

class ShiftsListView extends StatefulWidget {
  final String token;
  const ShiftsListView({super.key, required this.token});

  @override
  State<ShiftsListView> createState() => _ShiftsListViewState();
}

class _ShiftsListViewState extends State<ShiftsListView>
    with SingleTickerProviderStateMixin {
  final AdminApiService _api = AdminApiService();

  // ─── Onglets ──────────────────────────────────────────────────────────────
  late TabController _tabController;

  // ─── Données ──────────────────────────────────────────────────────────────
  // Toutes les données : Map<dateString, List<ShiftModel>>
  Map<String, List<ShiftModel>> _shiftsByDate = {};
  bool _isLoading = true;

  // Onglet Historique : date sélectionnée dans le calendrier
  DateTime _selectedDate = DateTime.now();
  DateTime _calendarMonth = DateTime.now();

  static const _primaryColor = Color(0xFF1B42C4);

  // ─── Init ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllShifts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Chargement ───────────────────────────────────────────────────────────
  Future<void> _loadAllShifts() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final plannings = await _api.getAllPlannings(widget.token);
      final Map<String, List<ShiftModel>> byDate = {};

      for (final planning in plannings) {
        final planningId = planning['id'] as int;
        final dateStr = planning['date'] as String; // ex: "2026-06-09"
        final shifts = await _api.getShiftsByPlanning(widget.token, planningId);
        shifts.sort((a, b) => a.type.compareTo(b.type));
        byDate[dateStr] = shifts;
      }

      if (mounted) setState(() { _shiftsByDate = byDate; _isLoading = false; });
    } catch (e) {
      print('Erreur chargement shifts: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  List<ShiftModel> get _todayShifts => _shiftsByDate[_todayStr] ?? [];

  List<ShiftModel> get _selectedDateShifts {
    final key = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _shiftsByDate[key] ?? [];
  }

  /// Dates passées (avant aujourd'hui) qui ont un planning
  Set<String> get _datesWithPlanning => _shiftsByDate.keys.toSet();

  IconData _shiftIcon(String type) {
    switch (type) {
      case 'SHIFT_1': return Icons.wb_sunny_outlined;
      case 'SHIFT_2': return Icons.cloud_outlined;
      case 'SHIFT_3': return Icons.nightlight_outlined;
      default: return Icons.schedule;
    }
  }

  Color _shiftBg(String type) {
    switch (type) {
      case 'SHIFT_1': return const Color(0xFFFAEEDA);
      case 'SHIFT_2': return const Color(0xFFE6F1FB);
      case 'SHIFT_3': return const Color(0xFFEAF3DE);
      default: return Colors.grey.shade100;
    }
  }

  Color _shiftIconColor(String type) {
    switch (type) {
      case 'SHIFT_1': return const Color(0xFF854F0B);
      case 'SHIFT_2': return const Color(0xFF0C447C);
      case 'SHIFT_3': return const Color(0xFF3B6D11);
      default: return Colors.grey;
    }
  }

  String _shiftLabel(String type) {
    switch (type) {
      case 'SHIFT_1': return 'Matin';
      case 'SHIFT_2': return 'Soir';
      case 'SHIFT_3': return 'Nuit';
      default: return type;
    }
  }

  bool _isManagerAssigned(ShiftModel shift) =>
      shift.chefService != null && shift.chefDivision != null;

  // ─── Navigation vers détail ───────────────────────────────────────────────
  void _openShift(ShiftModel shift) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShiftManagementView(
          token: widget.token,
          shiftId: shift.id,
        ),
      ),
    ).then((_) => _loadAllShifts());
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    return Column(
      children: [
        // ── Barre d'onglets ──
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: _primaryColor,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "Aujourd'hui"),
              Tab(text: 'Historique'),
            ],
          ),
        ),

        // ── Contenu ──
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTodayTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Onglet Aujourd'hui ───────────────────────────────────────────────────
  Widget _buildTodayTab() {
    final shifts = _todayShifts;
    final dateLabel = DateFormat('EEEE d MMMM yyyy').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: _loadAllShifts,
      color: _primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.today_outlined,
                    color: _primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  dateLabel,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (shifts.isEmpty)
            _buildEmptyState(
              icon: Icons.event_busy_outlined,
              title: "Aucun shift aujourd'hui",
              subtitle: "Créez un planning depuis l'onglet Planning",
            )
          else ...[
            _buildSectionLabel('Shifts du jour — ${shifts.length} shift(s)'),
            const SizedBox(height: 8),
            ...shifts.map((s) => _buildShiftCard(s)),
          ],
        ],
      ),
    );
  }

  // ─── Onglet Historique (calendrier) ──────────────────────────────────────
  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _loadAllShifts,
      color: _primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionLabel('Sélectionner une date'),
          const SizedBox(height: 8),
          _buildCalendar(),
          const SizedBox(height: 16),
          _buildSectionLabel(
            'Shifts du ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
          ),
          const SizedBox(height: 8),
          if (_selectedDateShifts.isEmpty)
            _buildEmptyState(
              icon: Icons.search_off_outlined,
              title: 'Aucun shift pour cette date',
              subtitle: 'Sélectionnez une date avec un planning existant',
            )
          else
            ..._selectedDateShifts.map((s) => _buildShiftCard(s)),
        ],
      ),
    );
  }

  // ─── Calendrier custom ────────────────────────────────────────────────────
  Widget _buildCalendar() {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth =
        DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=lundi, 7=dimanche
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final selectedStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final monthLabel = DateFormat('MMMM yyyy').format(_calendarMonth);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Navigation mois
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _calendarMonth = DateTime(
                      _calendarMonth.year, _calendarMonth.month - 1);
                }),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey.shade600,
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  _calendarMonth = DateTime(
                      _calendarMonth.year, _calendarMonth.month + 1);
                }),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey.shade600,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Jours de la semaine
          Row(
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),

          // Grille des jours
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: (startWeekday - 1) + daysInMonth,
            itemBuilder: (_, index) {
              if (index < startWeekday - 1) return const SizedBox();

              final day = index - (startWeekday - 1) + 1;
              final date = DateTime(
                  _calendarMonth.year, _calendarMonth.month, day);
              final dateStr = DateFormat('yyyy-MM-dd').format(date);

              final isToday = dateStr == todayStr;
              final isSelected = dateStr == selectedStr;
              final hasPlanning = _datesWithPlanning.contains(dateStr);
              final isPast = date.isBefore(
                  DateTime.now().subtract(const Duration(days: 1)));

              Color bg = Colors.transparent;
              Color textColor = Colors.grey.shade700;
              FontWeight fw = FontWeight.normal;

              if (isSelected) {
                bg = _primaryColor;
                textColor = Colors.white;
                fw = FontWeight.w600;
              } else if (isToday) {
                bg = const Color(0xFFE6F1FB);
                textColor = _primaryColor;
                fw = FontWeight.w600;
              } else if (hasPlanning) {
                bg = const Color(0xFFF0F7FF);
                textColor = _primaryColor;
                fw = FontWeight.w500;
              } else if (isPast) {
                textColor = Colors.grey.shade400;
              }

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text('$day',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: fw,
                              color: textColor)),
                      // Point indicateur si planning existe
                      if (hasPlanning && !isSelected)
                        Positioned(
                          bottom: 3,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: _primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Légende
          Row(
            children: [
              _calendarLegend(_primaryColor, 'Planning existant'),
              const SizedBox(width: 14),
              _calendarLegend(const Color(0xFFE6F1FB),
                  "Aujourd'hui", textColor: _primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarLegend(Color color, String label,
      {Color textColor = _primaryColor}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  // ─── Carte shift ──────────────────────────────────────────────────────────
  Widget _buildShiftCard(ShiftModel shift) {
    final assigned = _isManagerAssigned(shift);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _openShift(shift),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Icône shift
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _shiftBg(shift.type),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_shiftIcon(shift.type),
                      color: _shiftIconColor(shift.type), size: 20),
                ),
                const SizedBox(width: 12),

                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${shift.type} — ${_shiftLabel(shift.type)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${shift.heureDebut} → ${shift.heureFin}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                      if (assigned) ...[
                        const SizedBox(height: 3),
                        Text(
                          'CS: ${shift.chefService!.nom} · CD: ${shift.chefDivision!.nom}',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF3B6D11)),
                        ),
                      ] else ...[
                        const SizedBox(height: 3),
                        Text('Aucun manager affecté',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.red.shade400)),
                      ],
                    ],
                  ),
                ),

                // Badge + chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: assigned
                            ? const Color(0xFFEAF3DE)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        assigned ? 'Affecté' : 'En attente',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: assigned
                              ? const Color(0xFF3B6D11)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(Icons.chevron_right,
                        color: Colors.grey.shade400, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Utilitaires UI ───────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade400),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}