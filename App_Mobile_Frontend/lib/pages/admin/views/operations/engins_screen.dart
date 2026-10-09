import 'package:flutter/material.dart';
import '../../../../services/admin_service.dart';
import '../../../../models/admin_models.dart';
import '../../../../config/theme_config.dart';


class EnginsScreen extends StatefulWidget {
  final String token;
  const EnginsScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<EnginsScreen> createState() => _EnginsScreenState();
}

class _EnginsScreenState extends State<EnginsScreen> {
  late AdminApiService _apiService;
  List<EnginModel> engins = [];
  bool isLoading = false;
  bool showForm = false;
  bool isEditMode = false;
  int? editingEnginId;

  final TextEditingController typeController = TextEditingController();
  final TextEditingController capaciteController = TextEditingController();
  EtatEngin selectedEtat = EtatEngin.ACTIF;

  @override
  void initState() {
    super.initState();
    _apiService = AdminApiService();
    _loadEngins();
  }

  Future<void> _loadEngins() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.getEngins(widget.token);
      setState(() {
        engins = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _createEngin() async {
    if (typeController.text.isEmpty || capaciteController.text.isEmpty) {
      _showErrorSnackBar('Tous les champs sont obligatoires');
      return;
    }

    setState(() => isLoading = true);
    try {
      await _apiService.createEngin(
        widget.token,
        typeController.text,
        selectedEtat.name,
        double.parse(capaciteController.text),
      );
      typeController.clear();
      capaciteController.clear();
      selectedEtat = EtatEngin.ACTIF;
      setState(() => showForm = false);
      _loadEngins();
      if (mounted) _showSuccessSnackBar('Engin créé avec succès');
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showErrorSnackBar('Erreur: $e');
    }
  }

  void _editEngin(EnginModel engin) {
    setState(() {
      isEditMode = true;
      editingEnginId = engin.id;
      typeController.text = engin.type;
      capaciteController.text = engin.capacite.toString();
      selectedEtat = engin.etat;
      showForm = true;
    });
  }

  Future<void> _updateEngin(int id, String newEtat) async {
    setState(() => isLoading = true);
    try {
      // newEtat est une String du popup menu (ACTIF, PANNE, MAINTENANCE)
      await _apiService.updateEngin(widget.token, id, newEtat);
      _loadEngins();
      if (mounted) _showSuccessSnackBar('Engin mis à jour');
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _saveEditedEngin() async {
    if (typeController.text.isEmpty || capaciteController.text.isEmpty) {
      _showErrorSnackBar('Tous les champs sont obligatoires');
      return;
    }

    setState(() => isLoading = true);
    try {
      await _apiService.updateEngin(
        widget.token,
        editingEnginId!,
        selectedEtat.name,
      );
      // Update type and capacite via API if the method exists, otherwise reload
      _clearForm();
      _loadEngins();
      if (mounted) _showSuccessSnackBar('Engin modifié avec succès');
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _deleteEngin(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet engin ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      try {
        await _apiService.deleteEngin(widget.token, id);
        _loadEngins();
        if (mounted) _showSuccessSnackBar('Engin supprimé');
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) _showErrorSnackBar('Erreur: $e');
      }
    }
  }

  Color _getEtatColor(EtatEngin etat) {
    switch (etat) {
      case EtatEngin.ACTIF:
        return Colors.green;
      case EtatEngin.PANNE:
        return Colors.red;
      case EtatEngin.MAINTENANCE:
        return Colors.orange;
    }
  }

  String _getEtatLabel(EtatEngin etat) {
    switch (etat) {
      case EtatEngin.ACTIF:
        return 'Actif';
      case EtatEngin.PANNE:
        return 'Panne';
      case EtatEngin.MAINTENANCE:
        return 'Maintenance';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: ThemeConfig.errorColor),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: ThemeConfig.successColor),
    );
  }

  void _clearForm() {
    setState(() {
      typeController.clear();
      capaciteController.clear();
      selectedEtat = EtatEngin.ACTIF;
      isEditMode = false;
      editingEnginId = null;
      showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Engins', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: ThemeConfig.primaryColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text('${engins.length} engin(s)', style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (showForm) _buildFormCard(),
                  const SizedBox(height: 16),
                  _buildStatistiques(),
                  const SizedBox(height: 16),
                  _buildEnginsList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (showForm) {
            _clearForm();
          } else {
            setState(() => showForm = true);
          }
        },
        backgroundColor: ThemeConfig.primaryColor,
        foregroundColor: Colors.black,
        icon: Icon(showForm ? Icons.close : Icons.add),
        label: Text(showForm ? 'Annuler' : 'Nouvel Engin'),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditMode ? 'Modifier l\'Engin' : 'Ajouter un Engin',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeConfig.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),

            _buildFormField(
              controller: typeController,
              label: 'Type d\'Engin',
              hint: 'Ex: Grue, Pelle, Compacteur',
              icon: Icons.construction,
            ),
            const SizedBox(height: 14),
            _buildFormField(
              controller: capaciteController,
              label: 'Capacité',
              hint: 'Ex: 50, 100, 200',
              icon: Icons.storage,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _buildStateDropdown(),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isEditMode ? _saveEditedEngin : _createEngin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isEditMode ? 'Modifier' : 'Créer',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearForm,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: ThemeConfig.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ThemeConfig.textPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: ThemeConfig.textPrimaryColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: ThemeConfig.primaryColor, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeConfig.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeConfig.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeConfig.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildStateDropdown() {
    return DropdownButtonFormField<EtatEngin>(
      value: selectedEtat,
      items: const [
        DropdownMenuItem(
          value: EtatEngin.ACTIF,
          child: Text('Actif'),
        ),
        DropdownMenuItem(
          value: EtatEngin.PANNE,
          child: Text('Panne'),
        ),
        DropdownMenuItem(
          value: EtatEngin.MAINTENANCE,
          child: Text('Maintenance'),
        ),
      ],
      onChanged: (value) => setState(() => selectedEtat = value ?? EtatEngin.ACTIF),
      style: const TextStyle(color: ThemeConfig.textPrimaryColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'État',
        prefixIcon: Icon(Icons.info, color: ThemeConfig.primaryColor, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeConfig.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeConfig.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ThemeConfig.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildStatistiques() {
    final actifs = engins.where((e) => e.etat == EtatEngin.ACTIF).length;
    final pannes = engins.where((e) => e.etat == EtatEngin.PANNE).length;
    final maintenance = engins.where((e) => e.etat == EtatEngin.MAINTENANCE).length;

    return Row(
      children: [
        _buildStatCard('Actifs', actifs.toString(), Colors.green),
        const SizedBox(width: 12),
        _buildStatCard('Pannes', pannes.toString(), Colors.red),
        const SizedBox(width: 12),
        _buildStatCard('Maintenance', maintenance.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(
                label == 'Actifs' ? Icons.check_circle : label == 'Pannes' ? Icons.error : Icons.build,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeConfig.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnginsList() {
    if (engins.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.construction_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('Aucun engin trouvé', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: engins.length,
      itemBuilder: (context, index) {
        final engin = engins[index];
        final etatColor = _getEtatColor(engin.etat);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: ThemeConfig.borderColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ThemeConfig.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.construction,
                        color: ThemeConfig.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            engin.type,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: ThemeConfig.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Capacité: ${engin.capacite}',
                            style: const TextStyle(
                              color: ThemeConfig.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: etatColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getEtatLabel(engin.etat),
                        style: TextStyle(
                          color: etatColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16, color: ThemeConfig.primaryColor),
                              SizedBox(width: 10),
                              Text('Modifier', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'ACTIF',
                          child: Text('Actif', style: TextStyle(fontSize: 13)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'PANNE',
                          child: Text('Panne', style: TextStyle(fontSize: 13)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'MAINTENANCE',
                          child: Text('Maintenance', style: TextStyle(fontSize: 13)),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Supprimer', style: TextStyle(color: ThemeConfig.errorColor, fontSize: 13)),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteEngin(engin.id);
                        } else if (value == 'edit') {
                          _editEngin(engin);
                        } else {
                          _updateEngin(engin.id, value);
                        }
                      },
                      child: const Icon(Icons.more_vert, size: 20, color: ThemeConfig.textSecondaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    typeController.dispose();
    capaciteController.dispose();
    super.dispose();
  }
}

