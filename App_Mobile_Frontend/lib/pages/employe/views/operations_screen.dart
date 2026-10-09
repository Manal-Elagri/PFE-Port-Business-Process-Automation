import 'package:flutter/material.dart';
import '../../../models/admin_models.dart';
import '../../../models/employe_models.dart';
import '../../../models/operations_models.dart';
import '../../../services/employe_service.dart';
import '../../../services/operations_service.dart';
import 'active_operation_screen.dart';

class OperationsScreen extends StatefulWidget {
  final String token;

  const OperationsScreen({
    super.key,
    required this.token,
  });

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  final EmployeApiService _employeApiService = EmployeApiService();
  final OperationApiService _operationApiService = OperationApiService();

  bool _loading = true;
  bool _canStart = false;
  bool _showForm = false;
  bool _loadingRefs = false;
  bool _startingOperation = false;

  String? _error;
  OperationContextModel? _operationContext;

  String? _selectedType;
  EscaleModel? _selectedEscale;
  PosteModel? _selectedPoste;
  PortierModel? _selectedPortier;
  final List<EnginModel> _selectedEngins = [];

  List<EscaleModel> _escales = [];
  List<PosteModel> _postes = [];
  List<PortierModel> _portiers = [];
  List<EnginModel> _engins = [];

  @override
  void initState() {
    super.initState();
    _loadOperationAccess();
  }

  Future<void> _loadOperationAccess() async {
    setState(() {
      _loading = true;
      _error = null;
      _showForm = false;
    });

    try {
      final canStart = await _employeApiService.canStartOperation(widget.token);
      OperationContextModel? context;

      if (canStart) {
        context = await _employeApiService.getOperationContext(widget.token);
      }

      if (!mounted) return;

      setState(() {
        _canStart = canStart;
        _operationContext = context;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showStartForm() async {
    if (!_canStart || _operationContext == null) return;

    setState(() {
      _showForm = true;
      _loadingRefs = true;
      _selectedType = null;
      _selectedEscale = null;
      _selectedPoste = null;
      _selectedPortier = null;
      _selectedEngins.clear();
    });

    try {
      final results = await Future.wait([
        _employeApiService.getEscales(widget.token),
        _employeApiService.getPostes(widget.token),
        _employeApiService.getPortiers(widget.token),
        _employeApiService.getEnginsActifs(widget.token),
      ]);

      if (!mounted) return;

      setState(() {
        _escales = results[0] as List<EscaleModel>;
        _postes = results[1] as List<PosteModel>;
        _portiers = results[2] as List<PortierModel>;
        _engins = results[3] as List<EnginModel>;
        _loadingRefs = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingRefs = false;
        _showForm = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement references : $e')),
      );
    }
  }

  Future<void> _startOperation() async {
    if (_selectedType == null ||
        _selectedEscale == null ||
        _selectedPoste == null ||
        _selectedPortier == null ||
        _selectedEngins.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _startingOperation = true);

    try {
      final operation = await _operationApiService.startOperation(
        token: widget.token,
        request: StartOperationRequest(
          type: _selectedType!,
          escaleId: _selectedEscale!.id,
          posteId: _selectedPoste!.id,
          portierId: _selectedPortier!.id,
          enginIds: _selectedEngins.map((engin) => engin.id).toList(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation demarree : ${operation.statut}')),
      );

      setState(() {
        _showForm = false;
        _selectedType = null;
        _selectedEscale = null;
        _selectedPoste = null;
        _selectedPortier = null;
        _selectedEngins.clear();
      });

      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveOperationScreen(
          token: widget.token,
          operationId: operation.id!,
          deviceId: 'DEVICE-001',
          initialNombreConteneurs: operation.nombreConteneurs ?? 0,
        ),
      ),
    );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _startingOperation = false);
      }
    }
  }

  void _hideForm() {
    setState(() {
      _showForm = false;
      _selectedType = null;
      _selectedEscale = null;
      _selectedPoste = null;
      _selectedPortier = null;
      _selectedEngins.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations'),
        actions: [
          IconButton(
            onPressed: _loadOperationAccess,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOperationAccess,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _ErrorState(
                message: _error!,
                onRetry: _loadOperationAccess,
              )
            else if (!_canStart)
              const _BlockedState()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReadyState(
                    contextModel: _operationContext,
                    onStart: _showStartForm,
                  ),
                  if (_showForm) ...[
                    const SizedBox(height: 24),
                    _StartOperationForm(
                      loadingRefs: _loadingRefs,
                      startingOperation: _startingOperation,
                      selectedType: _selectedType,
                      selectedEscale: _selectedEscale,
                      selectedPoste: _selectedPoste,
                      selectedPortier: _selectedPortier,
                      selectedEngins: _selectedEngins,
                      escales: _escales,
                      postes: _postes,
                      portiers: _portiers,
                      engins: _engins,
                      onTypeChanged: (value) {
                        setState(() => _selectedType = value);
                      },
                      onEscaleChanged: (value) {
                        setState(() => _selectedEscale = value);
                      },
                      onPosteChanged: (value) {
                        setState(() => _selectedPoste = value);
                      },
                      onPortierChanged: (value) {
                        setState(() => _selectedPortier = value);
                      },
                      onEnginChanged: (engin, selected) {
                        setState(() {
                          if (selected) {
                            if (!_selectedEngins.any((e) => e.id == engin.id)) {
                              _selectedEngins.add(engin);
                            }
                          } else {
                            _selectedEngins.removeWhere(
                              (e) => e.id == engin.id,
                            );
                          }
                        });
                      },
                      onStart: _startOperation,
                      onCancel: _hideForm,
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ReadyState extends StatelessWidget {
  final OperationContextModel? contextModel;
  final VoidCallback onStart;

  const _ReadyState({
    required this.contextModel,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operation autorisee',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contexte actuel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Equipe : ${contextModel?.matriculeEquipe ?? '-'}'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: contextModel == null ? null : onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Nouvelle operation'),
          ),
        ),
      ],
    );
  }
}

class _StartOperationForm extends StatelessWidget {
  final bool loadingRefs;
  final bool startingOperation;

  final String? selectedType;
  final EscaleModel? selectedEscale;
  final PosteModel? selectedPoste;
  final PortierModel? selectedPortier;
  final List<EnginModel> selectedEngins;

  final List<EscaleModel> escales;
  final List<PosteModel> postes;
  final List<PortierModel> portiers;
  final List<EnginModel> engins;

  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<EscaleModel?> onEscaleChanged;
  final ValueChanged<PosteModel?> onPosteChanged;
  final ValueChanged<PortierModel?> onPortierChanged;
  final void Function(EnginModel engin, bool selected) onEnginChanged;

  final VoidCallback onStart;
  final VoidCallback onCancel;

  const _StartOperationForm({
    required this.loadingRefs,
    required this.startingOperation,
    required this.selectedType,
    required this.selectedEscale,
    required this.selectedPoste,
    required this.selectedPortier,
    required this.selectedEngins,
    required this.escales,
    required this.postes,
    required this.portiers,
    required this.engins,
    required this.onTypeChanged,
    required this.onEscaleChanged,
    required this.onPosteChanged,
    required this.onPortierChanged,
    required this.onEnginChanged,
    required this.onStart,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (loadingRefs) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nouvelle operation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: const InputDecoration(
              labelText: 'Type operation',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'CHARGEMENT',
                child: Text('Chargement'),
              ),
              DropdownMenuItem(
                value: 'DECHARGEMENT',
                child: Text('Dechargement'),
              ),
            ],
            onChanged: startingOperation ? null : onTypeChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EscaleModel>(
            value: selectedEscale,
            decoration: const InputDecoration(
              labelText: 'Escale',
              border: OutlineInputBorder(),
            ),
            items: escales.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text('Escale ${e.numeroEscale}'),
              );
            }).toList(),
            onChanged: startingOperation ? null : onEscaleChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PosteModel>(
            value: selectedPoste,
            decoration: const InputDecoration(
              labelText: 'Poste',
              border: OutlineInputBorder(),
            ),
            items: postes.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text('Poste ${p.numeroPoste} - ${p.localisation}'),
              );
            }).toList(),
            onChanged: startingOperation ? null : onPosteChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PortierModel>(
            value: selectedPortier,
            decoration: const InputDecoration(
              labelText: 'Portier',
              border: OutlineInputBorder(),
            ),
            items: portiers.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text('Portier ${p.code}'),
              );
            }).toList(),
            onChanged: startingOperation ? null : onPortierChanged,
          ),
          const SizedBox(height: 16),
          const Text(
            'Engins actifs',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (engins.isEmpty)
            const Text('Aucun engin actif disponible')
          else
            ...engins.map((engin) {
              final selected = selectedEngins.any((e) => e.id == engin.id);

              return CheckboxListTile(
                value: selected,
                onChanged: startingOperation
                    ? null
                    : (value) {
                        onEnginChanged(engin, value ?? false);
                      },
                title: Text('Engin ${engin.id}'),
                subtitle: Text('${engin.type} - ${engin.etat.name}'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: startingOperation ? null : onCancel,
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: startingOperation ? null : onStart,
                  icon: startingOperation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlockedState extends StatelessWidget {
  const _BlockedState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_clock_rounded,
            color: Colors.orange,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'Impossible de lancer une operation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Votre shift est inactif ou vous n avez pas l autorisation necessaire.',
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Colors.red,
          size: 40,
        ),
        const SizedBox(height: 12),
        const Text(
          'Erreur de chargement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Reessayer'),
        ),
      ],
    );
  }
}
