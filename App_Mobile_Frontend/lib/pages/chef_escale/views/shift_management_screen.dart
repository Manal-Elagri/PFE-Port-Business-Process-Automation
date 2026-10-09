import 'package:flutter/material.dart';

import '../../../services/chef_escale_service.dart';
import '../../../models/chef_escale_models.dart';

class ShiftManagementScreen extends StatefulWidget {
  final String token;

  const ShiftManagementScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  final ChefEscaleApiService api = ChefEscaleApiService();

  List<EquipeModel> equipes = [];
  List<ShiftModel> shifts = [];

  EquipeModel? selectedEquipe;
  ShiftModel? selectedShift;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ═══════════════════════════════
  // LOAD DATA
  // ═══════════════════════════════
  Future<void> _loadData() async {
    setState(() => loading = true);

    final eq = await api.getMyEquipes(widget.token);
    final sh = await api.getActiveShifts(widget.token);

    setState(() {
      equipes = eq ?? [];
      shifts = sh;
      loading = false;
    });
  }

  // ═══════════════════════════════
  // CONFIRM DIALOG
  // ═══════════════════════════════
  Future<bool> _confirm(String msg) async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Confirmation"),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Confirmer"),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ═══════════════════════════════
  // SUCCESS ANIMATION
  // ═══════════════════════════════
  void _success() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });

        return const Center(
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 100,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════
  // ASSIGN SHIFT
  // ═══════════════════════════════
  Future<void> _assign() async {
    if (selectedEquipe == null || selectedShift == null) return;

    final ok = await _confirm("Affecter cette équipe à ce shift ?");

    if (!ok) return;

    final res = await api.assignEquipeToShift(
      widget.token,
      selectedEquipe!.id,
      selectedShift!.id,
    );

    if (res) _success();
  }

  // ═══════════════════════════════
  // REMOVE SHIFT
  // ═══════════════════════════════
  Future<void> _remove() async {
    if (selectedEquipe == null) return;

    final ok = await _confirm("Retirer cette équipe du shift ?");

    if (!ok) return;

    final res = await api.removeEquipeFromShift(
      widget.token,
      selectedEquipe!.id,
    );

    if (res) _success();
  }

  // ═══════════════════════════════
  // DROPDOWN EQUIPES
  // ═══════════════════════════════
  Widget _equipeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<EquipeModel>(
        value: selectedEquipe,
        isExpanded: true,
        dropdownColor: const Color(0xFF111827),
        underline: const SizedBox(),
        hint: const Text(
          "Sélectionner équipe",
          style: TextStyle(color: Colors.white70),
        ),
        items: equipes.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(
              "${e.matriculeEquipe}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => selectedEquipe = v),
      ),
    );
  }

  // ═══════════════════════════════
  // DROPDOWN SHIFTS
  // ═══════════════════════════════
  Widget _shiftDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<ShiftModel>(
        value: selectedShift,
        isExpanded: true,
        dropdownColor: const Color(0xFF111827),
        underline: const SizedBox(),
        hint: const Text(
          "Sélectionner shift actif",
          style: TextStyle(color: Colors.white70),
        ),
        items: shifts.map((s) {
          return DropdownMenuItem(
            value: s,
            child: Text(
              "${s.type} (${s.heureDebut} - ${s.heureFin})",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => selectedShift = v),
      ),
    );
  }

  // ═══════════════════════════════
  // BUILD
  // ═══════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      appBar: AppBar(
        title: const Text("Shift Management"),
        backgroundColor: const Color(0xFF0B1220),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  _equipeDropdown(),

                  const SizedBox(height: 15),

                  _shiftDropdown(),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: _assign,
                    child: const Text("Affecter équipe → shift"),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _remove,
                    child: const Text("Retirer équipe du shift"),
                  ),
                ],
              ),
            ),
    );
  }
}