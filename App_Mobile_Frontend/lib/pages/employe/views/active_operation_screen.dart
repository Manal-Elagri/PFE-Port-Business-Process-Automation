import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/operations_models.dart';
import '../../../services/operations_service.dart';
import '../../../services/scan_api_service.dart';
import '../../../services/offline_scan_db.dart';

class ActiveOperationScreen extends StatefulWidget {
  final String token;
  final int operationId;
  final String deviceId;
  final int initialNombreConteneurs;
  
  const ActiveOperationScreen({
    super.key,
    required this.token,
    required this.operationId,
    required this.deviceId,
    this.initialNombreConteneurs = 0,
  });

  @override
  State<ActiveOperationScreen> createState() => _ActiveOperationScreenState();
}

class _ActiveOperationScreenState extends State<ActiveOperationScreen> {
  final OperationApiService _operationApi = OperationApiService();
  final ScanApiService _scanApi = ScanApiService();
  final OfflineScanDb _offlineDb = OfflineScanDb.instance;

  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _busy = false;
  bool _paused = false;
  int _pendingOffline = 0;
  int _nombreConteneurs = 0;
  ArretDTO? _currentArret;
  ScanResponseDTO? _lastScan;
  Timer? _statusTimer;
  @override
  void initState() {
    super.initState();
    _nombreConteneurs = widget.initialNombreConteneurs;
    _initCamera();
    _loadPendingCount();
    _loadOpenArrets();
    _statusTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadOpenArrets(),
    );
    print('ACTIVE SCREEN operationId = ${widget.operationId}');
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _cameraReady = true;
      });
    } catch (e) {
      _showSnack('Camera indisponible : $e', isError: true);
    }
  }

  Future<void> _loadPendingCount() async {
    final count = await _offlineDb.countPendingScans();
    if (!mounted) return;
    setState(() => _pendingOffline = count);
  }

  Future<void> _loadOpenArrets() async {
  try {
    print('LOAD ARRETS operationId = ${widget.operationId}');

    final arrets = await _operationApi.getArretsEnCours(
      token: widget.token,
      operationId: widget.operationId,
    );

    print('ARRETS COUNT = ${arrets.length}');

    if (!mounted) return;

    setState(() {
      _currentArret = arrets.isEmpty ? null : arrets.first;
      _paused = arrets.isNotEmpty;
    });
  } catch (e) {
    print('Erreur chargement arrets: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur chargement arrêt : $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
  }

  Future<void> _captureAndProcessImage() async {
    if (!_cameraReady || _cameraController == null || _busy || _paused) return;

    setState(() => _busy = true);

    try {
      final image = await _cameraController!.takePicture();
      final result = await _scanApi.processImage(
        token: widget.token,
        imagePath: image.path,
        operationId: widget.operationId,
        deviceId: widget.deviceId,
      );

      if (!mounted) return;
      setState(() {
        _lastScan = result;
        _nombreConteneurs++;
      });
      _showSnack('Scan image traite');
    } catch (e) {
      _showSnack('Erreur scan image : $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openManualScanDialog() async {
    final matriculeCtrl = TextEditingController();
    final typeCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan manuel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: matriculeCtrl,
              decoration: const InputDecoration(labelText: 'Matricule'),
            ),
            TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(labelText: 'Type ISO'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (matriculeCtrl.text.trim().isEmpty || typeCtrl.text.trim().isEmpty) {
      _showSnack('Matricule et type ISO obligatoires', isError: true);
      return;
    }

    await _processOrSaveManualScan(
      matricule: matriculeCtrl.text.trim(),
      typeIso: typeCtrl.text.trim(),
    );
  }

  Future<void> _openValidateScanDialog(ScanResponseDTO scan) async {
  if (scan.id == null) {
    _showSnack('Scan introuvable', isError: true);
    return;
  }

  final matriculeCtrl = TextEditingController(text: scan.matricule ?? '');
  final typeIsoCtrl = TextEditingController(text: scan.typeIso ?? '');

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Valider le scan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: matriculeCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Matricule corrigé',
              hintText: 'Ex: TCLU1234568',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: typeIsoCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Type ISO corrigé',
              hintText: 'Ex: 22G1',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Valider'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  final matricule = matriculeCtrl.text.trim().toUpperCase();
  final typeIso = typeIsoCtrl.text.trim().toUpperCase();

  if (matricule.isEmpty || typeIso.isEmpty) {
    _showSnack('Matricule et type ISO obligatoires', isError: true);
    return;
  }

  setState(() => _busy = true);

  try {
    final result = await _scanApi.validateScan(
      token: widget.token,
      request: ScanValidationRequestDTO(
        scanId: scan.id!,
        matriculeCorrige: matricule,
        typeIsoCorrige: typeIso,
      ),
    );

    if (!mounted) return;

    setState(() {
      _lastScan = result;
      _nombreConteneurs++;
    });

    _showSnack('Scan validé');
  } catch (e) {
    _showSnack('Erreur validation scan : $e', isError: true);
  } finally {
    if (mounted) setState(() => _busy = false);
  }
}

  Future<void> _processOrSaveManualScan({
    required String matricule,
    required String typeIso,
  }) async {
    final request = ScanRequestDTO(
      operationId: widget.operationId,
      mobileScanId: DateTime.now().millisecondsSinceEpoch.toString(),
      deviceId: widget.deviceId,
      matricule: matricule,
      typeIso: typeIso,
      score: 1,
      offlineMode: false,
    );

    setState(() => _busy = true);

    try {
      final connectivity = await Connectivity().checkConnectivity();

      if (connectivity == ConnectivityResult.none) {
        await _offlineDb.saveScan(
          ScanRequestDTO(
            operationId: request.operationId,
            mobileScanId: request.mobileScanId,
            deviceId: request.deviceId,
            matricule: request.matricule,
            typeIso: request.typeIso,
            score: request.score,
            offlineMode: true,
          ),
        );
        await _loadPendingCount();
        _showSnack('Scan sauvegarde offline');
        return;
      }

      final result = await _scanApi.processScan(
        token: widget.token,
        request: request,
      );

      if (!mounted) return;
      setState(() {
        _lastScan = result;
        _nombreConteneurs++;
      });
      _showSnack('Scan envoye');
    } catch (e) {
      await _offlineDb.saveScan(
        ScanRequestDTO(
          operationId: request.operationId,
          mobileScanId: request.mobileScanId,
          deviceId: request.deviceId,
          matricule: request.matricule,
          typeIso: request.typeIso,
          score: request.score,
          offlineMode: true,
        ),
      );
      await _loadPendingCount();
      _showSnack('Connexion indisponible, scan garde offline');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _syncOfflineScans() async {
    final pending = await _offlineDb.getPendingScans();
    if (pending.isEmpty) {
      _showSnack('Aucun scan offline');
      return;
    }

    setState(() => _busy = true);

    try {
      final synced = await _scanApi.syncOfflineScans(
        token: widget.token,
        requests: pending.map((e) => e.scan).toList(),
      );

      await _offlineDb.deleteScans(pending.map((e) => e.id).toList());

      if (!mounted) return;
      setState(() {
        _pendingOffline = 0;
        _nombreConteneurs = (_nombreConteneurs + synced.length).toInt();
        if (synced.isNotEmpty) _lastScan = synced.last;
      });

      _showSnack('${synced.length} scan(s) synchronise(s)');
    } catch (e) {
      _showSnack('Erreur sync : $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pauseOrResume() async {
    setState(() => _busy = true);

    try {
      if (_paused) {
        await _operationApi.resumeOperation(
          token: widget.token,
          operationId: widget.operationId,
        );
      } else {
        await _operationApi.pauseOperation(
          token: widget.token,
          operationId: widget.operationId,
        );
      }

      if (!mounted) return;
      setState(() => _paused = !_paused);
    } catch (e) {
      _showSnack('Erreur pause/reprise : $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startManualStop() async {
    setState(() => _busy = true);

    try {
      final arret = await _operationApi.arretManuel(
        token: widget.token,
        operationId: widget.operationId,
      );

      if (!mounted) return;
      setState(() {
        _paused = true;
        _currentArret = arret;
      });
    } catch (e) {
      _showSnack('Erreur arret : $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finishStop() async {
  if (_currentArret?.id == null) return;

  final ctrl = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Terminer arrêt'),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Cause de l’arrêt',
          hintText: 'Exemple : panne caméra, retard camion...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Terminer'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  final cause = ctrl.text.trim();

  if (cause.isEmpty) {
    _showSnack('Cause obligatoire', isError: true);
    return;
  }

  setState(() => _busy = true);

  try {
    await _operationApi.terminerArret(
      token: widget.token,
      arretId: _currentArret!.id!,
      cause: cause,
    );

    if (!mounted) return;

    setState(() {
      _currentArret = null;
      _paused = false;
    });

    _showSnack('Arrêt clôturé');
  } catch (e) {
    _showSnack('Erreur clôture arrêt : $e', isError: true);
  } finally {
    if (mounted) setState(() => _busy = false);
  }
  }

  Future<void> _finishOperation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminer operation'),
        content: const Text('Confirmer la cloture de cette operation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _busy = true);

    try {
      await _operationApi.terminerOperation(
        token: widget.token,
        operationId: widget.operationId,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Erreur cloture operation : $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operation #${widget.operationId}'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _syncOfflineScans,
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(),
          if (_currentArret != null) ...[
          const SizedBox(height: 16),
          _buildArretCard(),
        ],
          const SizedBox(height: 16),
          _buildCameraBox(),
          const SizedBox(height: 16),
          _buildScanActions(),
          const SizedBox(height: 16),
          _buildOperationActions(),
          const SizedBox(height: 16),
          _buildLastScanCard(),
        ],
      ),
    );
  }

  Widget _buildArretCard() {
  final arret = _currentArret!;

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange.withOpacity(0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Arrêt détecté',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8),
        Text('Type : ${arret.type ?? '-'}'),
        Text('Début : ${arret.dateDebut ?? '-'}'),
        Text('Cause : ${arret.cause ?? 'Non renseignée'}'),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : _finishStop,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Fin arrêt'),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatusItem(
              label: 'Statut',
              value: _currentArret != null
                  ? 'ARRET'
                  : _paused
                      ? 'PAUSE'
                      : 'EN COURS',
            ),
          ),
          Expanded(
            child: _StatusItem(
              label: 'Conteneurs',
              value: _nombreConteneurs.toString(),
            ),
          ),
          Expanded(
            child: _StatusItem(
              label: 'Offline',
              value: _pendingOffline.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraBox() {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_cameraReady && _cameraController != null)
              CameraPreview(_cameraController!)
            else
              Container(
                color: Colors.black87,
                child: const Center(
                  child: Text(
                    'Camera en chargement...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            Center(
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _busy || _paused ? null : _captureAndProcessImage,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Scanner image'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _busy || _paused ? null : _openManualScanDialog,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Manuel'),
          ),
        ),
      ],
    );
  }

  Widget _buildOperationActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: _busy || _currentArret != null ? null : _pauseOrResume,
          icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
          label: Text(_paused ? 'Reprendre' : 'Pause'),
        ),
        ElevatedButton.icon(
          onPressed: _busy || _currentArret != null ? null : _startManualStop,
          icon: const Icon(Icons.pan_tool_alt_rounded),
          label: const Text('Arret'),
        ),
        ElevatedButton.icon(
          onPressed: _busy || _currentArret == null ? null : _finishStop,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Fin arret'),
        ),
        OutlinedButton.icon(
          onPressed: _busy || _currentArret != null ? null : _finishOperation,
          icon: const Icon(Icons.flag_rounded),
          label: const Text('Terminer'),
        ),
      ],
    );
  }

  Widget _buildLastScanCard() {
  final scan = _lastScan;

  if (scan == null) {
    return const Text('Aucun scan pour le moment');
  }

  final needsValidation =
      scan.statut == 'A_VERIFIER' || scan.statut == 'A_CORRIGER';

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: needsValidation ? Colors.orange : Colors.black12,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          needsValidation ? 'Scan à vérifier' : 'Dernier scan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: needsValidation ? Colors.orange.shade800 : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text('Matricule : ${scan.matricule ?? '-'}'),
        Text('Type ISO : ${scan.typeIso ?? '-'}'),
        Text('Score : ${scan.score ?? '-'}'),
        Text('Statut : ${scan.statut ?? '-'}'),
        if (needsValidation) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : () => _openValidateScanDialog(scan),
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Corriger / valider'),
            ),
          ),
        ],
      ],
    ),
  );
}
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatusItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
