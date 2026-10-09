import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../models/chef_division_models.dart';
import '../../services/chef_division_service.dart';
import '../widgets/loading_widget.dart';

class SignaturesHistoryScreen extends StatefulWidget {
  final String token;

  const SignaturesHistoryScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<SignaturesHistoryScreen> createState() => _SignaturesHistoryScreenState();
}

class _SignaturesHistoryScreenState extends State<SignaturesHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'Tous';
  late Future<List<SignatureModel>> _future;
  final List<String> _statuses = ['Tous', 'EN_ATTENTE', 'SIGNE', 'REFUSE'];

  @override
  void initState() {
    super.initState();
    _future = ChefDivisionApiService().getSignatureHistory(widget.token);
  }

  List<SignatureModel> _applyFilter(List<SignatureModel> data) {
    final query = _searchController.text.toLowerCase().trim();
    return data.where((item) {
      final statusMatch = _statusFilter == 'Tous' || item.statut.toUpperCase() == _statusFilter;
      final searchMatch = query.isEmpty ||
          (item.document?.id.toString().contains(query) ?? false) ||
          (item.signataire?.nom.toLowerCase().contains(query) ?? false) ||
          (item.signataire?.prenom.toLowerCase().contains(query) ?? false) ||
          (item.document?.statut.toLowerCase().contains(query) ?? false);
      return statusMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SignatureModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LoadingWidget(message: 'Chargement de l’historique...'));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final signatures = snapshot.data ?? [];
        final filtered = _applyFilter(signatures);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Historique des signatures', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Rechercher',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _statusFilter,
                    items: _statuses
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _statusFilter = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (signatures.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('Aucun document trouvé.', style: Theme.of(context).textTheme.bodyLarge),
                  ),
                )
              else if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('Aucune entrée ne correspond aux critères.', style: Theme.of(context).textTheme.bodyLarge),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final date = item.dateSignature != null
                          ? '${item.dateSignature!.day}/${item.dateSignature!.month}/${item.dateSignature!.year}'
                          : 'Non signée';
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Document #${item.document?.id ?? 'N/A'}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(item.statut),
                                    backgroundColor: ThemeConfig.backgroundColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('Statut document : ${item.document?.statut ?? 'Inconnu'}'),
                              const SizedBox(height: 8),
                              Text('Date : $date'),
                              const SizedBox(height: 8),
                              Text('Signataire : ${item.signataire?.prenom ?? '-'} ${item.signataire?.nom ?? ''}'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    item.signaturePath != null ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
                                    color: item.signaturePath != null ? ThemeConfig.successColor : ThemeConfig.errorColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item.signaturePath != null ? 'Signature disponible' : 'Aucune signature disponible'),
                                ],
                              ),
                            ],
                          ),
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
