import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/admin_service.dart';
import '../../../models/admin_models.dart';


const _tabs = [
  {'label': 'Chefs Division', 'endpoint': 'chefs-divisions'},
  {'label': 'Chefs Service',  'endpoint': 'chefs-services'},
  {'label': 'Chefs Escale',   'endpoint': 'chefs-escales'},
  {'label': 'Chefs Équipe',   'endpoint': 'chefs-equipes'},
  {'label': 'Employés',       'endpoint': 'employes'},
];
 
// ═════════════════════════════════════════════════════════════════════════════
// VIEW
// ═════════════════════════════════════════════════════════════════════════════
 
class PersonnelManagementView extends StatefulWidget {
  final String token;
  const PersonnelManagementView({super.key, required this.token});
 
  @override
  State<PersonnelManagementView> createState() =>
      _PersonnelManagementViewState();
}
 
class _PersonnelManagementViewState extends State<PersonnelManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final Map<int, List<PersonnelModel>> _cache = {};
  final Map<int, bool> _loading = {};
  String _search = '';
 
 // On crée une instance du service
  final AdminApiService _apiService = AdminApiService();
 
  static const _primary = Color(0xFF1B42C4);
  static const _surface = Color(0xFFF4F7FF);
  static const _card    = Color(0xFFFFFFFF);
  static const _border  = Color(0xFFE0E8FF);
  static const _textPri = Color(0xFF0A1628);
  static const _textSec = Color(0xFF5A6A8A);
  static const _error   = Color(0xFFFF4D6A);
 
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _loadTab(_tabCtrl.index);
    });
    _loadTab(0);
  }
 
  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }
 
  // Remplace ta fonction _loadTab par celle-ci
  Future<void> _loadTab(int i) async {
    if (_cache.containsKey(i)) return;
    
    setState(() => _loading[i] = true);
    
    try {
      // On demande juste les données au backend
      final data = await _apiService.getPersonnelByRole(
          widget.token, _tabs[i]['endpoint']!);
      
      if (mounted) {
        setState(() {
          _cache[i] = data;
          _loading[i] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading[i] = false);
        _showSnack('Erreur lors du chargement', _error);
      }
    }
  }
 
  Future<void> _refreshTab(int i) async {
    setState(() {
      _cache.remove(i);
      _loading[i] = true;
    });
    await _loadTab(i);
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
 
  void _confirmDelete(PersonnelModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer personnel',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        content: Text(
            'Supprimer ${p.prenom} ${p.nom} ? Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler',
                  style: TextStyle(color: _textSec))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
                  final ok = await _apiService.deletePersonnel(widget.token, p.id); 
              if (ok) {
                _showSnack('Personnel supprimé', _error);
                _refreshTab(_tabCtrl.index);
              } else {
                _showSnack('Erreur lors de la suppression', _error);
              }
            },
            child: const Text('Supprimer',
                style: TextStyle(
                    color: _error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
 
  void _showEditSheet(PersonnelModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EditPersonnelSheet(
        personnel: p,
        token: widget.token,
        onSaved: () {
          _showSnack('Modifications enregistrées', const Color(0xFF00C48C));
          _refreshTab(_tabCtrl.index);
        },
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search bar
        Container(
          color: _card,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Rechercher un agent…',
              hintStyle: const TextStyle(color: _textSec, fontSize: 13),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: _textSec, size: 20),
              filled: true,
              fillColor: _surface,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 1),
              ),
            ),
          ),
        ),
 
        // ── Tab bar
        Container(
          color: _card,
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: _primary,
            unselectedLabelColor: _textSec,
            indicatorColor: _primary,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600),
            tabs: _tabs
                .map((t) => Tab(text: t['label']))
                .toList(),
          ),
        ),
 
        // ── Content
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: List.generate(
              _tabs.length,
              (i) => _buildTab(i),
            ),
          ),
        ),
      ],
    );
  }
 
  Widget _buildTab(int i) {
    if (_loading[i] == true && !_cache.containsKey(i)) {
      return const Center(
          child: CircularProgressIndicator(color: _primary));
    }
    final list = (_cache[i] ?? [])
        .where((p) =>
            _search.isEmpty ||
            '${p.prenom} ${p.nom}'.toLowerCase().contains(_search) ||
            p.email.toLowerCase().contains(_search))
        .toList();
 
    if (list.isEmpty) {
      return _EmptyState(
          icon: Icons.people_alt_rounded,
          label: _search.isEmpty ? 'Aucun agent' : 'Aucun résultat');
    }
 
    return RefreshIndicator(
      color: _primary,
      onRefresh: () => _refreshTab(i),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, j) => _PersonnelCard(
          personnel: list[j],
          onEdit: () => _showEditSheet(list[j]),
          onDelete: () => _confirmDelete(list[j]),
        ),
      ),
    );
  }
}
 
// ═════════════════════════════════════════════════════════════════════════════
// PERSONNEL CARD
// ═════════════════════════════════════════════════════════════════════════════
 
class _PersonnelCard extends StatelessWidget {
  final PersonnelModel personnel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
 
  static const _primary = Color(0xFF1B42C4);
  static const _card    = Color(0xFFFFFFFF);
  static const _border  = Color(0xFFE0E8FF);
  static const _textPri = Color(0xFF0A1628);
  static const _textSec = Color(0xFF5A6A8A);
  static const _error   = Color(0xFFFF4D6A);
 
  const _PersonnelCard({
    required this.personnel,
    required this.onEdit,
    required this.onDelete,
  });
 
  String get _initials =>
      '${personnel.prenom.isNotEmpty ? personnel.prenom[0] : ''}${personnel.nom.isNotEmpty ? personnel.nom[0] : ''}';
 
  @override
  Widget build(BuildContext context) {

    // utilisez : personnel.imageURL?.replaceAll('localhost', '127.0.0.1')
    final String? imageUrl = personnel.formattedImageUrl;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      // Si l'image n'est pas trouvée sur le serveur, on met les initiales
                      errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
                    )
                  : _buildInitialsAvatar(),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${personnel.prenom} ${personnel.nom}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPri)),
                const SizedBox(height: 2),
                Text(personnel.email,
                    style: const TextStyle(
                        fontSize: 11, color: _textSec)),
                const SizedBox(height: 4),
                Text(personnel.telephone,
                    style: const TextStyle(
                        fontSize: 11, color: _textSec)),
              ],
            ),
          ),
          // Actions
          Column(
            children: [
              _IconCircle(
                icon: Icons.edit_rounded,
                color: _primary,
                onTap: onEdit,
              ),
              const SizedBox(height: 8),
              _IconCircle(
                icon: Icons.delete_outline_rounded,
                color: _error,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

   // Widget pour afficher les initiales proprement
  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(_initials,
          style: const TextStyle(
              color: _primary, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}



 
// ═════════════════════════════════════════════════════════════════════════════
// EDIT SHEET
// ═════════════════════════════════════════════════════════════════════════════
 
class _EditPersonnelSheet extends StatefulWidget {
  final PersonnelModel personnel;
  final String token;
  final VoidCallback onSaved;
  const _EditPersonnelSheet({
    required this.personnel,
    required this.token,
    required this.onSaved,
  });
 
  @override
  State<_EditPersonnelSheet> createState() => _EditPersonnelSheetState();
}
 
class _EditPersonnelSheetState extends State<_EditPersonnelSheet> {
  late final _nom   = TextEditingController(text: widget.personnel.nom);
  late final _prenom= TextEditingController(text: widget.personnel.prenom);
  late final _email = TextEditingController(text: widget.personnel.email);
  late final _tel   = TextEditingController(text: widget.personnel.telephone);
  bool _saving = false;
 
  static const _primary = Color(0xFF1B42C4);
  static const _border  = Color(0xFFE0E8FF);
  static const _surface = Color(0xFFF4F7FF);
  static const _textPri = Color(0xFF0A1628);
  static const _success = Color(0xFF00C48C);
 
  @override
  void dispose() {
    _nom.dispose(); _prenom.dispose();
    _email.dispose(); _tel.dispose();
    super.dispose();
  }
 
  Future<void> _save() async {
    setState(() => _saving = true);
     final ok = await AdminApiService().updatePersonnel(
      widget.token,
      widget.personnel.id,
      {
        'nom': _nom.text,
        'prenom': _prenom.text,
        'email': _email.text,
        'telephone': _tel.text,
        'rolePersonnel': widget.personnel.role,
      },
    );
    if (mounted) setState(() => _saving = false);
    if (ok && mounted) {
    Navigator.pop(context);
    widget.onSaved();
    }
   }
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Modifier le personnel',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPri)),
            const SizedBox(height: 16),
            _field(_prenom, 'Prénom'),
            const SizedBox(height: 10),
            _field(_nom, 'Nom'),
            const SizedBox(height: 10),
            _field(_email, 'Email', keyboard: TextInputType.emailAddress),
            const SizedBox(height: 10),
            _field(_tel, 'Téléphone', keyboard: TextInputType.phone),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Text('Enregistrer',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
 
  Widget _field(TextEditingController c, String hint,
      {TextInputType? keyboard}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0A1628)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFF5A6A8A), fontSize: 13),
        filled: true,
        fillColor: _surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1),
        ),
      ),
    );
  }
}
 
// ═════════════════════════════════════════════════════════════════════════════
// SHARED
// ═════════════════════════════════════════════════════════════════════════════
 
class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconCircle(
      {required this.icon, required this.color, required this.onTap});
 
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 17),
        ),
      );
}
 
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});
 
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF1B42C4).withOpacity(0.08),
                  shape: BoxShape.circle),
              child:
                  Icon(icon, size: 38, color: const Color(0xFF1B42C4)),
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