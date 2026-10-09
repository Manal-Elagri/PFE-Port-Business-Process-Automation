import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/admin_service.dart';
import '../../../../models/admin_models.dart';

class EscalesScreen extends StatefulWidget {
  final String token;
  const EscalesScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<EscalesScreen> createState() => _EscalesScreenState();
}

class _EscalesScreenState extends State<EscalesScreen> {
  late AdminApiService _apiService;
  List<EscaleModel> escales    = [];
  List<NavireModel> navires    = [];
  bool isLoading  = false;
  bool showForm   = false;

  // Form controllers
  final TextEditingController numeroEscaleController = TextEditingController();
  final TextEditingController dateArriveeController  = TextEditingController();
  final TextEditingController dateDepartController   = TextEditingController();
  NavireModel? selectedNavire;

  // Filter state
  DateTime? _filterArrivee;
  DateTime? _filterDepart;
  // mode: 'none' | 'arrivee' | 'depart' | 'periode'
  String _filterMode = 'none';

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
  static const _warn       = Color(0xFFF59E0B);
  static const _warnSoft   = Color(0xFFFFFBEB);
  // ─────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _apiService = AdminApiService();
    _loadData();
  }

  @override
  void dispose() {
    numeroEscaleController.dispose();
    dateArriveeController.dispose();
    dateDepartController.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────

  List<EscaleModel> get _filtered {
    if (_filterMode == 'none') return escales;
    return escales.where((e) {
      try {
        final arr = DateTime.parse(e.dateArrivee);
        final dep = DateTime.parse(e.dateDepart);
        if (_filterMode == 'arrivee' && _filterArrivee != null) {
          return _sameDay(arr, _filterArrivee!);
        }
        if (_filterMode == 'depart' && _filterDepart != null) {
          return _sameDay(dep, _filterDepart!);
        }
        if (_filterMode == 'periode' &&
            _filterArrivee != null &&
            _filterDepart != null) {
          // escales qui se chevauchent avec la période
          return !dep.isBefore(_filterArrivee!) &&
              !arr.isAfter(_filterDepart!);
        }
      } catch (_) {}
      return true;
    }).toList();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _hasFilter => _filterMode != 'none';

  void _clearFilter() {
    setState(() {
      _filterMode   = 'none';
      _filterArrivee = null;
      _filterDepart  = null;
    });
  }

  // ── Form helpers ──────────────────────────────────────────────────────

  void _toggleForm() {
    setState(() => showForm = !showForm);
    if (!showForm) _clearFormFields();
  }

  void _clearForm() {
    setState(() => showForm = false);
    _clearFormFields();
  }

  void _clearFormFields() {
    numeroEscaleController.clear();
    dateArriveeController.clear();
    dateDepartController.clear();
    setState(() => selectedNavire = null);
  }

  // ── Date picker ───────────────────────────────────────────────────────

  Future<DateTime?> _pickDate({DateTime? initial}) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _accent,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
  }

  Future<void> _pickDateInto(TextEditingController ctrl,
      {VoidCallback? onPicked}) async {
    final d = await _pickDate(
        initial: ctrl.text.isNotEmpty
            ? DateTime.tryParse(ctrl.text)
            : null);
    if (d != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(d);
      onPicked?.call();
    }
  }

  // ── Filter dialog ─────────────────────────────────────────────────────

  Future<void> _showFilterDialog() async {
    String mode         = _filterMode == 'none' ? 'arrivee' : _filterMode;
    DateTime? pickArr   = _filterArrivee;
    DateTime? pickDep   = _filterDepart;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Dialog(
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
                      child: const Icon(Icons.filter_alt_rounded,
                          color: _accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Filtrer les escales',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
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

                const SizedBox(height: 20),
                const Divider(color: _border, height: 1),
                const SizedBox(height: 20),

                // Mode selector
                _filterLabel('Type de filtre'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _modeChip('arrivee', 'Arrivée', Icons.flight_land_rounded, mode, setSt, (v) => mode = v),
                    const SizedBox(width: 8),
                    _modeChip('depart',  'Départ',  Icons.flight_takeoff_rounded, mode, setSt, (v) => mode = v),
                    const SizedBox(width: 8),
                    _modeChip('periode', 'Période', Icons.date_range_rounded, mode, setSt, (v) => mode = v),
                  ],
                ),

                const SizedBox(height: 20),

                // Date pickers
                if (mode == 'arrivee') ...[
                  _filterLabel('Date d\'arrivée'),
                  const SizedBox(height: 8),
                  _filterDateTile(
                    date: pickArr,
                    placeholder: 'Choisir une date',
                    icon: Icons.calendar_today_rounded,
                    onTap: () async {
                      final d = await _pickDate(initial: pickArr);
                      if (d != null) setSt(() => pickArr = d);
                    },
                    onClear: () => setSt(() => pickArr = null),
                  ),
                ],

                if (mode == 'depart') ...[
                  _filterLabel('Date de départ'),
                  const SizedBox(height: 8),
                  _filterDateTile(
                    date: pickDep,
                    placeholder: 'Choisir une date',
                    icon: Icons.calendar_today_rounded,
                    onTap: () async {
                      final d = await _pickDate(initial: pickDep);
                      if (d != null) setSt(() => pickDep = d);
                    },
                    onClear: () => setSt(() => pickDep = null),
                  ),
                ],

                if (mode == 'periode') ...[
                  _filterLabel('Du (date arrivée)'),
                  const SizedBox(height: 8),
                  _filterDateTile(
                    date: pickArr,
                    placeholder: 'Date de début',
                    icon: Icons.flight_land_rounded,
                    onTap: () async {
                      final d = await _pickDate(initial: pickArr);
                      if (d != null) setSt(() => pickArr = d);
                    },
                    onClear: () => setSt(() => pickArr = null),
                  ),
                  const SizedBox(height: 10),
                  _filterLabel('Au (date départ)'),
                  const SizedBox(height: 8),
                  _filterDateTile(
                    date: pickDep,
                    placeholder: 'Date de fin',
                    icon: Icons.flight_takeoff_rounded,
                    onTap: () async {
                      final d = await _pickDate(initial: pickDep);
                      if (d != null) setSt(() => pickDep = d);
                    },
                    onClear: () => setSt(() => pickDep = null),
                  ),
                ],

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _outlineBtn('Réinitialiser', () {
                        Navigator.pop(ctx);
                        _clearFilter();
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _solidBtn('Appliquer', () {
                        setState(() {
                          _filterMode    = mode;
                          _filterArrivee = pickArr;
                          _filterDepart  = pickDep;
                        });
                        Navigator.pop(ctx);
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterLabel(String t) => Text(t,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _slate,
          letterSpacing: 0.4));

  Widget _modeChip(
    String value,
    String label,
    IconData icon,
    String current,
    StateSetter setSt,
    ValueChanged<String> onSet,
  ) {
    final active = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setSt(() => onSet(value)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? _accent : _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: active ? _accent : _border, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? Colors.white : _slate),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : _slate)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterDateTile({
    required DateTime? date,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: date != null ? _accentSoft : _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: date != null ? _accent : _border),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: date != null ? _accent : _slate),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('dd MMMM yyyy', 'fr').format(date)
                    : placeholder,
                style: TextStyle(
                    fontSize: 13,
                    color: date != null ? _accent : _slate,
                    fontWeight: date != null
                        ? FontWeight.w600
                        : FontWeight.normal),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded,
                    size: 14, color: _slate),
              ),
          ],
        ),
      ),
    );
  }

  // ── API calls ─────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.getEscales(widget.token),
        _apiService.getAllNavires(widget.token),
      ]);
      setState(() {
        escales = results[0] as List<EscaleModel>;
        navires = results[1] as List<NavireModel>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _createEscale() async {
    if (numeroEscaleController.text.trim().isEmpty ||
        dateArriveeController.text.isEmpty ||
        dateDepartController.text.isEmpty ||
        selectedNavire == null) {
      _showSnack('Tous les champs sont obligatoires', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      await _apiService.createEscale(
        widget.token,
        numeroEscaleController.text.trim(),
        dateArriveeController.text,
        dateDepartController.text,
        selectedNavire!.id,
      );
      _clearForm();
      await _loadData();
      if (mounted) _showSnack('Escale créée avec succès');
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _updateEscale(EscaleModel escale) async {
    final numCtrl = TextEditingController(text: escale.numeroEscale);
    final arrCtrl = TextEditingController(text: escale.dateArrivee);
    final depCtrl = TextEditingController(text: escale.dateDepart);
    NavireModel? selNavire =
        navires.where((n) => n.id == escale.navire?.id).firstOrNull;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          const Text('Modifier l\'escale',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _ink)),
                          Text('Escale #${escale.numeroEscale}',
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

                _filterLabel('Navire'),
                const SizedBox(height: 6),
                _styledDropdown<NavireModel>(
                  value: selNavire,
                  hint: 'Sélectionner un navire',
                  icon: Icons.directions_boat_rounded,
                  items: navires,
                  itemLabel: (n) => n.nom,
                  onChanged: (v) =>
                      setDialogState(() => selNavire = v),
                ),
                const SizedBox(height: 14),
                _filterLabel('Numéro d\'escale'),
                const SizedBox(height: 6),
                TextField(
                  controller: numCtrl,
                  style: const TextStyle(fontSize: 14, color: _ink),
                  decoration: _inputDeco(
                      Icons.confirmation_number_rounded),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _filterLabel('Date d\'arrivée'),
                          const SizedBox(height: 6),
                          _dateField(
                            ctrl: arrCtrl,
                            hint: 'aaaa-mm-jj',
                            onTap: () async {
                              await _pickDateInto(arrCtrl);
                              setDialogState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _filterLabel('Date de départ'),
                          const SizedBox(height: 6),
                          _dateField(
                            ctrl: depCtrl,
                            hint: 'aaaa-mm-jj',
                            onTap: () async {
                              await _pickDateInto(depCtrl);
                              setDialogState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: _outlineBtn(
                        'Annuler', () => Navigator.pop(ctx, false))),
                    const SizedBox(width: 12),
                    Expanded(child: _solidBtn(
                        'Enregistrer', () => Navigator.pop(ctx, true))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      if (selNavire == null) {
        _showSnack('Veuillez sélectionner un navire', isError: true);
        return;
      }
      setState(() => isLoading = true);
      try {
        await _apiService.updateEscale(
          widget.token,
          escale.id,
          numCtrl.text.trim(),
          arrCtrl.text,
          depCtrl.text,
          selNavire!.id,
        );
        await _loadData();
        if (mounted) _showSnack('Escale mise à jour');
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) _showSnack('Erreur: $e', isError: true);
      }
    }
  }

  Future<void> _deleteEscale(int id) async {
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
              const Text('Supprimer cette escale ?',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _ink)),
              const SizedBox(height: 8),
              const Text(
                'Cette action est irréversible.',
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
        await _apiService.deleteEscale(widget.token, id);
        await _loadData();
        if (mounted) _showSnack('Escale supprimée');
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

  Widget _dateField({
    required TextEditingController ctrl,
    required String hint,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      style: const TextStyle(fontSize: 13, color: _ink),
      onTap: onTap,
      decoration: _inputDeco(
        Icons.calendar_today_rounded,
        hint: hint,
        suffix: ctrl.text.isNotEmpty
            ? const Icon(Icons.check_circle_rounded,
                size: 16, color: _success)
            : null,
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, size: 16, color: _slate),
              const SizedBox(width: 8),
              Flexible(
                child: Text(hint,
                    style: const TextStyle(
                        color: Color(0xFFCBD5E1), fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(icon, size: 15, color: _accent),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(itemLabel(item),
                              style: const TextStyle(
                                  fontSize: 13, color: _ink),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: _ink),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(IconData icon,
      {String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: Color(0xFFCBD5E1), fontSize: 13),
      prefixIcon: Icon(icon, size: 16, color: _slate),
      prefixIconConstraints:
          const BoxConstraints(minWidth: 40, minHeight: 40),
      suffixIcon: suffix,
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
              onRefresh: _loadData,
              color: _accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildFilterBar(),
                    const SizedBox(height: 16),
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
                              const SizedBox(height: 16),
                            ])
                          : const SizedBox.shrink(),
                    ),
                    _buildEscalesList(),
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
          Text('Escales',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.4)),
          Text('Gestion des escales portuaires',
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
    final today = DateTime.now();
    final enCours = escales.where((e) {
      try {
        final arr = DateTime.parse(e.dateArrivee);
        final dep = DateTime.parse(e.dateDepart);
        return !today.isBefore(arr) && !today.isAfter(dep);
      } catch (_) {
        return false;
      }
    }).length;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.anchor_rounded,
            label: 'Total escales',
            value: escales.length.toString(),
            color: _accent,
            bg: _accentSoft,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            icon: Icons.radar_rounded,
            label: 'En cours',
            value: enCours.toString(),
            color: _warn,
            bg: _warnSoft,
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
          horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        height: 1)),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: _slate),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter bar ────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    final filtered = _filtered;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _showFilterDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: _hasFilter ? _accentSoft : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _hasFilter ? _accent : _border),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt_rounded,
                      size: 16,
                      color: _hasFilter ? _accent : _slate),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hasFilter
                          ? _filterDescription()
                          : 'Filtrer par date…',
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              _hasFilter ? _accent : _slate,
                          fontWeight: _hasFilter
                              ? FontWeight.w600
                              : FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_hasFilter) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${filtered.length}',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _clearFilter,
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: _slate),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _filterDescription() {
    final fmt = (DateTime d) =>
        DateFormat('dd/MM', 'fr').format(d);
    if (_filterMode == 'arrivee' && _filterArrivee != null) {
      return 'Arrivée : ${fmt(_filterArrivee!)}';
    }
    if (_filterMode == 'depart' && _filterDepart != null) {
      return 'Départ : ${fmt(_filterDepart!)}';
    }
    if (_filterMode == 'periode') {
      final a = _filterArrivee != null ? fmt(_filterArrivee!) : '?';
      final d = _filterDepart != null ? fmt(_filterDepart!) : '?';
      return 'Période : $a → $d';
    }
    return '';
  }

  // ── Form card ─────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    return StatefulBuilder(
      builder: (context, setFormState) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        padding: const EdgeInsets.all(20),
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
                  child: const Icon(Icons.anchor_rounded,
                      color: _accent, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nouvelle escale',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                      Text(
                          'Renseignez les informations de l\'escale',
                          style: TextStyle(
                              fontSize: 12, color: _slate)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: _border, height: 1),
            const SizedBox(height: 16),

            // Navire (full width)
            _filterLabel('Navire'),
            const SizedBox(height: 6),
            _styledDropdown<NavireModel>(
              value: selectedNavire,
              hint: 'Choisir un navire',
              icon: Icons.directions_boat_rounded,
              items: navires,
              itemLabel: (n) => n.nom,
              onChanged: (v) =>
                  setFormState(() => selectedNavire = v),
            ),

            const SizedBox(height: 14),

            // Numéro (full width)
            _filterLabel('Numéro d\'escale'),
            const SizedBox(height: 6),
            TextField(
              controller: numeroEscaleController,
              style: const TextStyle(fontSize: 13, color: _ink),
              decoration: _inputDeco(
                  Icons.confirmation_number_rounded,
                  hint: 'Ex: ESC-2024-001'),
            ),

            const SizedBox(height: 14),

            // Dates : 2 colonnes
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _filterLabel('Date d\'arrivée'),
                      const SizedBox(height: 6),
                      _dateField(
                        ctrl: dateArriveeController,
                        hint: 'aaaa-mm-jj',
                        onTap: () async {
                          await _pickDateInto(dateArriveeController);
                          setFormState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _filterLabel('Date de départ'),
                      const SizedBox(height: 6),
                      _dateField(
                        ctrl: dateDepartController,
                        hint: 'aaaa-mm-jj',
                        onTap: () async {
                          await _pickDateInto(dateDepartController);
                          setFormState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                    child: _outlineBtn('Annuler', _clearForm)),
                const SizedBox(width: 12),
                Expanded(
                    child: _solidBtn(
                        'Créer l\'escale', _createEscale)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────

  Widget _buildEscalesList() {
    final list = _filtered
      ..sort((a, b) => b.dateArrivee.compareTo(a.dateArrivee));

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 52),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.anchor_rounded,
                  size: 30, color: _accent),
            ),
            const SizedBox(height: 14),
            Text(
              _hasFilter
                  ? 'Aucun résultat pour ce filtre'
                  : 'Aucune escale enregistrée',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _ink),
            ),
            const SizedBox(height: 6),
            Text(
              _hasFilter
                  ? 'Modifiez ou supprimez le filtre'
                  : 'Ajoutez votre première escale via le bouton +',
              style:
                  const TextStyle(fontSize: 13, color: _slate),
            ),
          ],
        ),
      );
    }

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
                horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Text('Liste des escales',
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
                  child: Text('${list.length} résultat(s)',
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
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(
                color: _border, height: 1, indent: 20),
            itemBuilder: (_, i) => _buildEscaleRow(list[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildEscaleRow(EscaleModel escale) {
    final today = DateTime.now();
    bool enCours = false;
    try {
      final arr = DateTime.parse(escale.dateArrivee);
      final dep = DateTime.parse(escale.dateDepart);
      enCours = !today.isBefore(arr) && !today.isAfter(dep);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Icône statut ──────────────────────────────────────────
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: enCours ? _warnSoft : _accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              enCours ? Icons.radar_rounded : Icons.anchor_rounded,
              color: enCours ? _warn : _accent,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // ── Bloc d'infos ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Ligne 1 : numéro + badge "En cours"
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Escale #${escale.numeroEscale}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (enCours) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _warnSoft,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _warn.withOpacity(0.3)),
                        ),
                        child: const Text('En cours',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: _warn)),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 5),

                // Ligne 2 : navire
                Row(
                  children: [
                    const Icon(Icons.directions_boat_rounded,
                        size: 13, color: _slate),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        escale.navire?.nom ?? 'Navire non défini',
                        style: const TextStyle(
                            fontSize: 12, color: _slate),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Ligne 3 : arrivée + départ sur deux mini-pills
                Row(
                  children: [
                    // Arrivée
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _success.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.login_rounded,
                                size: 11, color: _success),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _fmtDate(escale.dateArrivee),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _ink,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Départ
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _dangerSoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _danger.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.logout_rounded,
                                size: 11, color: _danger),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _fmtDate(escale.dateDepart),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _ink,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ── Actions (verticales) ──────────────────────────────────
          Column(
            children: [
              _iconAction(
                icon: Icons.edit_rounded,
                color: _accent,
                bg: _accentSoft,
                onTap: () => _updateEscale(escale),
              ),
              const SizedBox(height: 6),
              _iconAction(
                icon: Icons.delete_rounded,
                color: _danger,
                bg: _dangerSoft,
                onTap: () => _deleteEscale(escale.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDate(String iso) {
    try {
      return DateFormat('dd MMM yyyy', 'fr')
          .format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
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