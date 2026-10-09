import 'package:flutter/material.dart';
import '../../../../services/admin_service.dart';
import '../../../../models/admin_models.dart';

class PortiersScreen extends StatefulWidget {
  final String token;
  const PortiersScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<PortiersScreen> createState() => _PortiersScreenState();
}

class _PortiersScreenState extends State<PortiersScreen> {
  late AdminApiService _apiService;
  List<PortierModel> portiers = [];
  bool isLoading = false;
  bool showForm  = false;

  final TextEditingController codeController          = TextEditingController();
  final TextEditingController nombreCamerasController = TextEditingController();

  // ── Palette ───────────────────────────────────────────────────────────
  static const _ink        = Color(0xFF0F172A);
  static const _slate      = Color(0xFF64748B);
  static const _border     = Color(0xFFE2E8F0);
  static const _surface    = Color(0xFFF8FAFC);
  static const _accent     = Color(0xFF6366F1);
  static const _accentSoft = Color(0xFFEEF2FF);
  static const _danger     = Color(0xFFEF4444);
  static const _dangerSoft = Color(0xFFFEF2F2);
  static const _success    = Color(0xFF10B981);
  static const _successSoft= Color(0xFFECFDF5);
  static const _warn       = Color(0xFFF59E0B);
  static const _warnSoft   = Color(0xFFFFFBEB);
  // ─────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _apiService = AdminApiService();
    _loadPortiers();
  }

  @override
  void dispose() {
    codeController.dispose();
    nombreCamerasController.dispose();
    super.dispose();
  }

  // ── Form helpers ──────────────────────────────────────────────────────

  void _toggleForm() => setState(() => showForm = !showForm);

  void _clearForm() {
    codeController.clear();
    nombreCamerasController.clear();
    setState(() => showForm = false);
  }

  // ── API calls ─────────────────────────────────────────────────────────

  Future<void> _loadPortiers() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.getAllPortiers(widget.token);
      setState(() {
        portiers  = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _createPortier() async {
    if (codeController.text.trim().isEmpty ||
        nombreCamerasController.text.trim().isEmpty) {
      _showSnack('Tous les champs sont obligatoires', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      await _apiService.createPortier(
        widget.token,
        codeController.text.trim(),
        int.parse(nombreCamerasController.text.trim()),
      );
      _clearForm();
      await _loadPortiers();
      if (mounted) _showSnack('Portier créé avec succès');
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _updatePortier(PortierModel portier) async {
    final codeCtrl = TextEditingController(text: portier.code);
    final camCtrl  =
        TextEditingController(text: portier.nombreCameras.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: _accentSoft,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.edit_rounded,
                        color: _accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Modifier le portier',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _ink)),
                        Text('Code : ${portier.code}',
                            style: const TextStyle(
                                fontSize: 12, color: _slate)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, false),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: _slate),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: _border, height: 1),
              const SizedBox(height: 20),

              _fieldLabel('Code du portier'),
              const SizedBox(height: 6),
              _dialogField(codeCtrl, Icons.vpn_key_rounded),

              const SizedBox(height: 14),

              _fieldLabel('Nombre de caméras'),
              const SizedBox(height: 6),
              _dialogField(camCtrl, Icons.videocam_rounded,
                  type: TextInputType.number),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: _outlineBtn(
                        'Annuler', () => Navigator.pop(ctx, false)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _solidBtn(
                        'Enregistrer', () => Navigator.pop(ctx, true)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      final cameras = int.tryParse(camCtrl.text.trim());
      if (cameras == null) {
        _showSnack('Nombre de caméras invalide', isError: true);
        return;
      }
      setState(() => isLoading = true);
      try {
        await _apiService.updatePortier(
            widget.token, portier.id, cameras);
        await _loadPortiers();
        if (mounted) _showSnack('Portier mis à jour');
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) _showSnack('Erreur: $e', isError: true);
      }
    }
  }

  Future<void> _deletePortier(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: _dangerSoft,
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _danger, size: 28),
              ),
              const SizedBox(height: 18),
              const Text('Supprimer ce portier ?',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _ink)),
              const SizedBox(height: 8),
              const Text(
                'Cette action est irréversible. Le portier sera définitivement supprimé.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: _slate, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _outlineBtn('Annuler',
                          () => Navigator.pop(ctx, false))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Supprimer',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      try {
        await _apiService.deletePortier(widget.token, id);
        await _loadPortiers();
        if (mounted) _showSnack('Portier supprimé');
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) _showSnack('Erreur: $e', isError: true);
      }
    }
  }

  // ── Snackbar ──────────────────────────────────────────────────────────

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(msg,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: isError ? _danger : _success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Shared widget helpers ─────────────────────────────────────────────

  Widget _fieldLabel(String t) => Text(t,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _slate,
          letterSpacing: 0.4));

  Widget _dialogField(TextEditingController ctrl, IconData icon,
      {TextInputType? type}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(fontSize: 14, color: _ink),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 17, color: _slate),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(IconData icon, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
      prefixIcon: Icon(icon, size: 16, color: _slate),
      prefixIconConstraints:
          const BoxConstraints(minWidth: 40, minHeight: 40),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      filled: true,
      fillColor: _surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
    );
  }

  Widget _solidBtn(String label, VoidCallback onTap) =>
      ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _outlineBtn(String label, VoidCallback onTap) =>
      OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _slate,
          side: const BorderSide(color: _border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
      );

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: _accent, strokeWidth: 2))
          : RefreshIndicator(
              onRefresh: _loadPortiers,
              color: _accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      child: showForm
                          ? Column(children: [
                              AnimatedOpacity(
                                opacity: showForm ? 1.0 : 0.0,
                                duration:
                                    const Duration(milliseconds: 280),
                                child: _buildFormCard(),
                              ),
                              const SizedBox(height: 20),
                            ])
                          : const SizedBox.shrink(),
                    ),
                    _buildPortiersList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Portiers',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.4)),
          Text('Gestion des portiers de sécurité',
              style: TextStyle(
                  fontSize: 11, color: _slate, height: 1.3)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _border, height: 1),
      ),
    );
  }

  Widget _buildStatsRow() {
    final total       = portiers.length;
    final totalCams   = portiers.fold<int>(0, (s, p) => s + p.nombreCameras);
    final moyenne     = total > 0
        ? (totalCams / total).toStringAsFixed(1)
        : '0';

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.security_rounded,
            label: 'Total portiers',
            value: total.toString(),
            color: _accent,
            bg: _accentSoft,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.videocam_rounded,
            label: 'Total caméras',
            value: totalCams.toString(),
            color: _warn,
            bg: _warnSoft,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.bar_chart_rounded,
            label: 'Moy. caméras',
            value: moyenne,
            color: _success,
            bg: _successSoft,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  height: 1)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: _slate),
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.security_rounded,
                    color: _accent, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nouveau portier',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _ink)),
                    Text('Renseignez les informations du portier',
                        style:
                            TextStyle(fontSize: 12, color: _slate)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 20),

          // 2-column row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Code du portier'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: codeController,
                      style: const TextStyle(
                          fontSize: 13, color: _ink),
                      decoration: _inputDeco(
                          Icons.vpn_key_rounded,
                          hint: 'Ex: PTR-001'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Nombre de caméras'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nombreCamerasController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontSize: 13, color: _ink),
                      decoration: _inputDeco(
                          Icons.videocam_rounded,
                          hint: 'Ex: 4'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                  child: _outlineBtn('Annuler', _clearForm)),
              const SizedBox(width: 12),
              Expanded(
                  child: _solidBtn(
                      'Créer le portier', _createPortier)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortiersList() {
    if (portiers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.security_rounded,
                  size: 34, color: _accent),
            ),
            const SizedBox(height: 16),
            const Text('Aucun portier enregistré',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
            const SizedBox(height: 6),
            const Text(
                'Ajoutez votre premier portier via le bouton +',
                style: TextStyle(fontSize: 13, color: _slate)),
          ],
        ),
      );
    }

    final sorted = List<PortierModel>.from(portiers)
      ..sort((a, b) => a.code.compareTo(b.code));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text('Liste des portiers',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${portiers.length} entrée(s)',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _accent)),
                ),
              ],
            ),
          ),
          const Divider(color: _border, height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(
                color: _border, height: 1, indent: 20),
            itemBuilder: (_, i) => _buildPortierRow(sorted[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildPortierRow(PortierModel portier) {
    // Couleur selon le nombre de caméras
    final camColor = portier.nombreCameras == 0
        ? _danger
        : portier.nombreCameras < 3
            ? _warn
            : _success;
    final camBg = portier.nombreCameras == 0
        ? _dangerSoft
        : portier.nombreCameras < 3
            ? _warnSoft
            : _successSoft;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Badge code
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.security_rounded,
                color: _accent, size: 20),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portier ${portier.code}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _ink),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                // Caméra pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: camBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: camColor.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_rounded,
                              size: 11, color: camColor),
                          const SizedBox(width: 4),
                          Text(
                            '${portier.nombreCameras} caméra${portier.nombreCameras > 1 ? 's' : ''}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: camColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconAction(
                icon: Icons.edit_rounded,
                color: _accent,
                bg: _accentSoft,
                onTap: () => _updatePortier(portier),
              ),
              const SizedBox(width: 8),
              _iconAction(
                icon: Icons.delete_rounded,
                color: _danger,
                bg: _dangerSoft,
                onTap: () => _deletePortier(portier.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _toggleForm,
      backgroundColor: _accent,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          showForm ? Icons.close_rounded : Icons.add_rounded,
          key: ValueKey(showForm),
        ),
      ),
      label: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          showForm ? 'Fermer' : 'Ajouter',
          key: ValueKey(showForm),
          style:
              const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}