import 'package:flutter/material.dart';
import '../../services/chef_service_service.dart';
import '../../models/chef_service_models.dart';
import '../widgets/loading_widget.dart';

class ChefServiceShiftEquipesScreen extends StatefulWidget {
  final String token;
  final int shiftId;
  const ChefServiceShiftEquipesScreen({Key? key, required this.token, required this.shiftId}) : super(key: key);

  @override
  State<ChefServiceShiftEquipesScreen> createState() => _ChefServiceShiftEquipesScreenState();
}

class _ChefServiceShiftEquipesScreenState extends State<ChefServiceShiftEquipesScreen> {
  late Future<List<EquipeModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ChefServiceApiService().getEquipesByShift(token: widget.token, shiftId: widget.shiftId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EquipeModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: LoadingWidget(message: 'Chargement équipes...'));
        if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
        final teams = snapshot.data ?? [];
        if (teams.isEmpty) return const Center(child: Text('Aucune équipe pour ce shift'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final t = teams[index];
            return Card(
              child: ListTile(
                title: Text(t.matriculeEquipe),
                subtitle: Text(t.chefEquipe?.prenom ?? '-'),
              ),
            );
          },
        );
      },
    );
  }
}
