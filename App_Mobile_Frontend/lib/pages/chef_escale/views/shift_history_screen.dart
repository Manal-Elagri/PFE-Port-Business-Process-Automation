import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../../../services/chef_escale_service.dart';
import '../../../models/chef_escale_models.dart';

class ShiftHistoryScreen extends StatefulWidget {
  final String token;

  const ShiftHistoryScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ShiftHistoryScreen> createState() => _ShiftHistoryScreenState();
}

class _ShiftHistoryScreenState extends State<ShiftHistoryScreen> {
  final ChefEscaleApiService api = ChefEscaleApiService();

  List<HistoriqueShiftModel> history = [];
  List<HistoriqueShiftModel> filtered = [];

  bool loading = false;

  String filter = "ALL";
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ═══════════════════════════════
  // LOAD
  // ═══════════════════════════════
  Future<void> _load() async {
    setState(() => loading = true);

    final data = await api.getMyShiftHistory(widget.token);

    setState(() {
      history = data;
      filtered = data;
      loading = false;
    });
  }

  // ═══════════════════════════════
  // FILTER LOGIC
  // ═══════════════════════════════
  void _applyFilter() {
    List<HistoriqueShiftModel> temp = history;

    if (filter == "ACTIVE") {
      temp = temp.where((e) => e.active == true).toList();
    } else if (filter == "DONE") {
      temp = temp.where((e) => e.active == false).toList();
    }

    if (searchCtrl.text.isNotEmpty) {
      temp = temp.where((e) {
        final q = searchCtrl.text.toLowerCase();
        return (e.equipe?.matriculeEquipe ?? "").toLowerCase().contains(q) ||
            (e.shift?.type ?? "").toLowerCase().contains(q);
      }).toList();
    }

    setState(() => filtered = temp);
  }

  // ═══════════════════════════════
  // EXPORT PDF
  // ═══════════════════════════════
  Future<void> _exportPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: filtered.map((h) {
              return pw.Text(
                "${h.shift?.type ?? ''} - ${h.equipe?.matriculeEquipe ?? ''}",
              );
            }).toList(),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/shift_history.pdf");

    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF exporté avec succès")),
    );
  }

  // ═══════════════════════════════
  // UI CARD
  // ═══════════════════════════════
  Widget _card(HistoriqueShiftModel h) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            h.shift?.type ?? "",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text("Equipe: ${h.equipe?.matriculeEquipe ?? "-"}",
              style: const TextStyle(color: Colors.white70)),
          Text("Statut: ${h.active ? "ACTIVE" : "TERMINÉ"}",
              style: const TextStyle(color: Colors.white54)),
        ],
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
        title: const Text("Historique shifts"),
        backgroundColor: const Color(0xFF0B1220),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPDF,
          )
        ],
      ),

      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchCtrl,
              onChanged: (_) => _applyFilter(),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Rechercher...",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          // FILTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _chip("ALL"),
              _chip("ACTIVE"),
              _chip("DONE"),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: filtered.map(_card).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: filter == label,
      onSelected: (_) {
        setState(() => filter = label);
        _applyFilter();
      },
    );
  }
}