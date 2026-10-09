import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/admin_service.dart';
import '../../../models/admin_models.dart';


class RequestsManagementView extends StatefulWidget {
  final String token;

  const RequestsManagementView({super.key, required this.token});
 
  @override
  State<RequestsManagementView> createState() => _RequestsManagementViewState();
}
 
class _RequestsManagementViewState extends State<RequestsManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<DemandeInscription> _pending = [];
  List<DemandeInscription> _all = [];
  bool _loading = true;
  final Set<int> _processing = {};

  // On crée une instance du service
  final AdminApiService _apiService = AdminApiService();
 
  // ── Palette ────────────────────────────────────────────────────────────────
  static const _navy    = Color(0xFF0F2A8A);
  static const _primary = Color(0xFF1B42C4);
  static const _surface = Color(0xFFF4F7FF);
  static const _card    = Color(0xFFFFFFFF);
  static const _border  = Color(0xFFE0E8FF);
  static const _textPri = Color(0xFF0A1628);
  static const _textSec = Color(0xFF5A6A8A);
  static const _success = Color(0xFF00C48C);
  static const _warning = Color(0xFFFFA940);
  static const _error   = Color(0xFFFF4D6A);
 
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }
 
  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
 
  Future<void> _load() async {
    setState(() => _loading = true);

    final results = await Future.wait([
      _apiService.getPendingRequests(widget.token),
      _apiService.getAllRequests(widget.token),
    ]);
    if (mounted) {
      setState(() {
        _pending = results[0] as List<DemandeInscription>;
        _all = results[1] as List<DemandeInscription>;
        _loading = false;
      });
    }
  }
 
  Future<void> _approve(int id) async {
    setState(() => _processing.add(id));
    final ok = await _apiService.approveRequest (widget.token, id);
    if (ok) {
      _showSnack('Demande approuvée', _success);
      await _load();
    } else {
      _showSnack('Erreur lors de l\'approbation', _error);
    }
    setState(() => _processing.remove(id));
  }
 
  Future<void> _reject(int id) async {
    setState(() => _processing.add(id));
    final ok = await _apiService.rejectRequest(widget.token, id);
    if (ok) {
      _showSnack('Demande refusée', _error);
      await _load();
    } else {
      _showSnack('Erreur lors du refus', _error);
    }
    setState(() => _processing.remove(id));
  }
 
  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }
 
  // ── Confirm dialog ─────────────────────────────────────────────────────────
  void _confirmAction({
    required String title,
    required String body,
    required Color confirmColor,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: _textSec)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(confirmLabel,
                style: TextStyle(
                    color: confirmColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
 
  // ── Detail bottom sheet ────────────────────────────────────────────────────
  void _showDetail(DemandeInscription d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DetailSheet(
        demande: d,
        isPending: d.statut == 'EN_ATTENTE',
        processing: _processing.contains(d.id),
        onApprove: () {
          Navigator.pop(context);
          _confirmAction(
            title: 'Approuver la demande',
            body: 'Confirmer l\'approbation de ${d.prenom} ${d.nom} ?',
            confirmColor: _success,
            confirmLabel: 'Approuver',
            onConfirm: () => _approve(d.id),
          );
        },
        onReject: () {
          Navigator.pop(context);
          _confirmAction(
            title: 'Refuser la demande',
            body: 'Confirmer le refus de ${d.prenom} ${d.nom} ?',
            confirmColor: _error,
            confirmLabel: 'Refuser',
            onConfirm: () => _reject(d.id),
          );
        },
      ),
    );
  }
 
  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab bar
        Container(
          color: _card,
          child: TabBar(
            controller: _tabs,
            labelColor: _primary,
            unselectedLabelColor: _textSec,
            indicatorColor: _primary,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'En attente (${_pending.length})'),
              Tab(text: 'Toutes (${_all.length})'),
            ],
          ),
        ),
 
        // ── Content
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _primary))
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _buildList(_pending, showActions: true),
                    _buildList(_all, showActions: false),
                  ],
                ),
        ),
      ],
    );
  }
 
  Widget _buildList(List<DemandeInscription> items,
      {required bool showActions}) {
    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.assignment_turned_in_rounded,
        label: showActions
            ? 'Aucune demande en attente'
            : 'Aucune demande trouvée',
      );
    }
    return RefreshIndicator(
      color: _primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => _RequestCard(
          demande: items[i],
          showActions: showActions,
          processing: _processing.contains(items[i].id),
          onTap: () => _showDetail(items[i]),
          onApprove: () => _confirmAction(
            title: 'Approuver la demande',
            body:
                'Confirmer l\'approbation de ${items[i].prenom} ${items[i].nom} ?',
            confirmColor: _success,
            confirmLabel: 'Approuver',
            onConfirm: () => _approve(items[i].id),
          ),
          onReject: () => _confirmAction(
            title: 'Refuser la demande',
            body:
                'Confirmer le refus de ${items[i].prenom} ${items[i].nom} ?',
            confirmColor: _error,
            confirmLabel: 'Refuser',
            onConfirm: () => _reject(items[i].id),
          ),
        ),
      ),
    );
  }
}
 
// ═════════════════════════════════════════════════════════════════════════════
// REQUEST CARD
// ═════════════════════════════════════════════════════════════════════════════
 
class _RequestCard extends StatelessWidget {
  final DemandeInscription demande;
  final bool showActions;
  final bool processing;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;
 
  static const _primary = Color(0xFF1B42C4);
  static const _card    = Color(0xFFFFFFFF);
  static const _border  = Color(0xFFE0E8FF);
  static const _textPri = Color(0xFF0A1628);
  static const _textSec = Color(0xFF5A6A8A);
  static const _success = Color(0xFF00C48C);
  static const _error   = Color(0xFFFF4D6A);
  static const _warning = Color(0xFFFFA940);
 
  const _RequestCard({
    required this.demande,
    required this.showActions,
    required this.processing,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
  });
 
  Color get _statusColor => switch (demande.statut) {
        'ACCEPTEE' => _success,
        'REFUSEE'  => _error,
        _          => _warning,
      };
 
  String get _statusLabel => switch (demande.statut) {
        'ACCEPTEE' => 'Approuvée',
        'REFUSEE'  => 'Refusée',
        _          => 'En attente',
      };
 
  String get _initials =>
      '${demande.prenom.isNotEmpty ? demande.prenom[0] : ''}${demande.nom.isNotEmpty ? demande.nom[0] : ''}';
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row
              Row(
                children: [
                  // Avatar
                  // Avatar avec gestion d'image réseau
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _primary.withOpacity(0.2), width: 1),
                    ),
                    child: ClipOval(
                      child: (demande.formattedImageUrl != null) // 👈 Utilisation de l'URL formatée
                          ? Image.network(
                              demande.formattedImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Affiche l'erreur dans la console pour comprendre pourquoi ça rate
                                print("DEBUG: Échec chargement image demande: ${demande.formattedImageUrl}");
                                return _buildInitialsAvatar();
                              },
                            )
                          : _buildInitialsAvatar(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. NOM ET EMAIL (C'est cette partie qui manquait)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${demande.prenom} ${demande.nom}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _textPri),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          demande.email,
                          style: const TextStyle(fontSize: 11, color: _textSec),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
 
              // ── Role chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  demande.roleDemande.replaceAll('_', ' '),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF185FA5),
                      fontWeight: FontWeight.w500),
                ),
              ),
 
              // ── Action buttons (pending only)
              if (showActions && demande.statut == 'EN_ATTENTE') ...[
                const SizedBox(height: 12),
                const Divider(height: 0.5, thickness: 0.5, color: _border),
                const SizedBox(height: 12),
                processing
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _primary),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _ActionBtn(
                              label: 'Refuser',
                              color: _error,
                              onTap: onReject,
                              outlined: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionBtn(
                              label: 'Approuver',
                              color: _success,
                              onTap: onApprove,
                            ),
                          ),
                        ],
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
  return Container(
    color: _primary.withOpacity(0.1),
    alignment: Alignment.center,
    child: Text(_initials,
        style: const TextStyle(
            color: _primary, fontWeight: FontWeight.bold, fontSize: 14)),
  );
}
}
 
// ═════════════════════════════════════════════════════════════════════════════
// DETAIL BOTTOM SHEET
// ═════════════════════════════════════════════════════════════════════════════
 
class _DetailSheet extends StatelessWidget {
  final DemandeInscription demande;
  final bool isPending;
  final bool processing;
  final VoidCallback onApprove;
  final VoidCallback onReject;
 
  static const _primary = Color(0xFF1B42C4);
  static const _border  = Color(0xFFE0E8FF);
  static const _textPri = Color(0xFF0A1628);
  static const _textSec = Color(0xFF5A6A8A);
  static const _success = Color(0xFF00C48C);
  static const _error   = Color(0xFFFF4D6A);
 
  const _DetailSheet({
    required this.demande,
    required this.isPending,
    required this.processing,
    required this.onApprove,
    required this.onReject,
  });
 
   @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle de fermeture
            Center(
              child: Container(width: 36, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 25),

            // --- NOUVELLE SECTION PHOTO ---
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                    child: (demande.formattedImageUrl != null)
                        ? Image.network(
                            demande.formattedImageUrl!, 
                            fit: BoxFit.cover, 
                            errorBuilder: (c, e, s) {
                              print("DEBUG Detail: Échec image ${demande.formattedImageUrl}");
                              return const Icon(Icons.person, size: 50, color: Colors.grey);
                            }
                          )
                        : const Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  ),
                  const SizedBox(height: 12),
                  Text('${demande.prenom} ${demande.nom}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPri)),
                  Text(demande.roleDemande.replaceAll('_', ' '),
                      style: const TextStyle(fontSize: 13, color: _primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text('Informations complémentaires', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const Divider(),
            _row('Email professionnel', demande.email),
            _row('CIN / Identifiant', demande.cin),
            _row('Téléphone', demande.telephone),
            _row('Statut actuel', demande.statut),

            if (isPending) ...[
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(child: _ActionBtn(label: 'Refuser', color: _error, onTap: onReject, outlined: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _ActionBtn(label: 'Approuver', color: _success, onTap: onApprove)),
                ],
              ),
            ],
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
 
  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: _textSec)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textPri)),
          ),
        ],
      ),
    );
  }
}
 
// ═════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═════════════════════════════════════════════════════════════════════════════
 
class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;
 
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: outlined ? 1 : 0),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: outlined ? color : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
 
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B42C4).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 38, color: const Color(0xFF1B42C4)),
          ),
          const SizedBox(height: 14),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5A6A8A))),
        ],
      ),
    );
  }
}