import 'package:flutter/material.dart';
import '../../services/chef_service_service.dart';
import '../../models/chef_service_models.dart';
import '../widgets/loading_widget.dart';

class ChefServiceShiftHistoryScreen extends StatefulWidget {
  final String token;
  final int shiftId;
  const ChefServiceShiftHistoryScreen({Key? key, required this.token, required this.shiftId}) : super(key: key);

  @override
  State<ChefServiceShiftHistoryScreen> createState() => _ChefServiceShiftHistoryScreenState();
}

class _ChefServiceShiftHistoryScreenState extends State<ChefServiceShiftHistoryScreen> {
  late Future<List<HistoriqueShiftModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ChefServiceApiService().getShiftHistory(token: widget.token, shiftId: widget.shiftId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoriqueShiftModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: LoadingWidget(message: 'Chargement historique...'));
        if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
        final data = snapshot.data ?? [];
        if (data.isEmpty) return const Center(child: Text('Aucun historique')); 
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final h = data[index];
            final duration = (h.dateDebut != null && h.dateFin != null) ? h.dateFin!.difference(h.dateDebut!).inMinutes : 0;
            return Card(
              child: ListTile(
                title: Text(h.equipe?.matriculeEquipe ?? 'Équipe'),
                subtitle: Text('Début: ${h.dateDebut ?? '-'} • Fin: ${h.dateFin ?? '-'}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(duration.toString() + ' min'),
                    const SizedBox(height: 4),
                    if (h.active) const Icon(Icons.check_circle, color: Colors.green) else const Icon(Icons.remove_circle, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
