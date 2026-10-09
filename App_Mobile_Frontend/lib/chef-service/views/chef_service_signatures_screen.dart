import 'package:flutter/material.dart';
import '../../services/chef_service_service.dart';
import '../../models/chef_service_models.dart';
import '../../models/chef_division_models.dart';
import '../../config/theme_config.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';

class ChefServiceSignaturesScreen extends StatefulWidget {
  final String token;
  const ChefServiceSignaturesScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ChefServiceSignaturesScreen> createState() => _ChefServiceSignaturesScreenState();
}

class _ChefServiceSignaturesScreenState extends State<ChefServiceSignaturesScreen> {
  late Future<List<SignatureModel>> _future;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = ChefServiceApiService().getSignatureHistory(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SignatureModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: LoadingWidget(message: 'Chargement des signatures...'));
        if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
        final data = snapshot.data ?? [];
        final filtered = data.where((e) {
          final q = _search.text.toLowerCase().trim();
          if (q.isEmpty) return true;
          return (e.document?.id?.toString() ?? '').contains(q) || (e.signataire?.nom.toLowerCase() ?? '').contains(q) || (e.signataire?.prenom.toLowerCase() ?? '').contains(q);
        }).toList();
        if (data.isEmpty) return const EmptyStateWidget(message: 'Aucun document');
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: _search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Rechercher'), onChanged: (_) => setState(() {})),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text('Document #${item.document?.id ?? 'N/A'}'),
                        subtitle: Text('Statut: ${item.statut} • ${item.signataire?.prenom ?? '-'} ${item.signataire?.nom ?? ''}'),
                        trailing: Icon(item.signaturePath != null ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded, color: item.signaturePath != null ? ThemeConfig.successColor : ThemeConfig.errorColor),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
