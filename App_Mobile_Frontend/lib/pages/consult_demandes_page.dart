import 'package:flutter/material.dart';
import '../services/register_service.dart';

class ConsultDemandesPage extends StatefulWidget {
  const ConsultDemandesPage({super.key});

  @override
  State<ConsultDemandesPage> createState() => _ConsultDemandesPageState();
}

class _ConsultDemandesPageState extends State<ConsultDemandesPage> {
  final _codeController = TextEditingController();
  Map<String, dynamic>? _demande;
  bool _isLoading = false;
  bool _hasSearched = false;

  static const Color brandBlue = Color(0xFF2046E3);
  static const Color navy = Color(0xFF0A1628);

  void _searchDemande() async {
    if (_codeController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final result = await RegisterService().getRequestByReference(_codeController.text.trim());

    setState(() {
      _demande = result;
      _isLoading = false;
    });

    if (result == null) {
      _showSnackBar("Aucune demande trouvée pour ce code.", Colors.orange);
    }
  }

  void _confirmCancel(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Annuler la demande ?"),
        content: const Text("Êtes-vous sûr de vouloir supprimer cette demande d'inscription ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Retour")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelDemande(id);
            },
            child: const Text("Oui, Annuler", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _cancelDemande(int id) async {
    bool success = await RegisterService().cancelRequest(id);
    if (success) {
      setState(() {
        _demande = null;
        _hasSearched = false;
        _codeController.clear();
      });
      _showSnackBar("Demande annulée avec succès.", Colors.green);
    } else {
      _showSnackBar("Erreur lors de l'annulation.", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EN_ATTENTE': return Colors.orange;
      case 'ACCEPTEE': return Colors.green;
      case 'REFUSEE': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Suivi de Demande", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.manage_search_rounded, size: 60, color: brandBlue),
                  const SizedBox(height: 16),
                  const Text(
                    "Consultez l'état de votre dossier",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Entrez le code de référence REQ-... reçu lors de votre inscription.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  
                  // --- SEARCH BAR ---
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: brandBlue.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: TextField(
                      controller: _codeController,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "Code de référence (ex: REQ-2025...)",
                        hintStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                        prefixIcon: const Icon(Icons.qr_code_scanner, color: brandBlue),
                        filled: true,
                        fillColor: const Color(0xFFF4F6FB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        suffixIcon: IconButton(
                          icon: const CircleAvatar(backgroundColor: brandBlue, radius: 20, child: Icon(Icons.send, color: Colors.white, size: 18)),
                          onPressed: _searchDemande,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- RESULT SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isLoading 
                ? const CircularProgressIndicator(color: brandBlue)
                : _demande != null 
                  ? _buildResultCard() 
                  : _buildEmptyState(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    String status = _demande!['statut'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Détails de la demande", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: navy)),
              _buildStatusBadge(status),
            ],
          ),
          const Divider(height: 40),
          _infoTile(Icons.person_outline_rounded, "Demandeur", "${_demande!['prenom']} ${_demande!['nom']}"),
          _infoTile(Icons.work_outline_rounded, "Poste visé", _demande!['roleDemande'].toString().replaceAll('_', ' ')),
          _infoTile(Icons.alternate_email_rounded, "Contact", _demande!['email'] ?? "Non renseigné"),
          _infoTile(Icons.numbers_rounded, "Code Ref.", _demande!['codeReference']),
          
          if (status == 'EN_ATTENTE') ...[
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _confirmCancel(_demande!['id']),
                icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                label: const Text("Annuler ma demande", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.red.shade100)),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: _getStatusColor(status)),
          const SizedBox(width: 8),
          Text(
            status.replaceAll('_', ' '),
            style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: brandBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navy)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (!_hasSearched) {
      return Column(
        children: [
          Opacity(opacity: 0.5, child: Icon(Icons.search_off_rounded, size: 100, color: Colors.grey.shade300)),
          const SizedBox(height: 16),
          const Text("En attente de recherche...", style: TextStyle(color: Colors.grey)),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}