import 'package:flutter/material.dart';
import '../../services/chef_service_service.dart';
import '../../models/chef_service_models.dart';
import '../../config/theme_config.dart';
import '../widgets/loading_widget.dart';

class ChefServiceActiveEquipesScreen extends StatefulWidget {
  final String token;
  const ChefServiceActiveEquipesScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ChefServiceActiveEquipesScreen> createState() => _ChefServiceActiveEquipesScreenState();
}

class _ChefServiceActiveEquipesScreenState extends State<ChefServiceActiveEquipesScreen> {
  late Future<List<EquipeModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ChefServiceApiService().getActiveTeamsToday(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EquipeModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: LoadingWidget(message: 'Chargement équipes actives...'));
        if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
        final teams = snapshot.data ?? [];
        if (teams.isEmpty) return const Center(child: Text('Aucune équipe active aujourd\'hui'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final t = teams[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index+1}')),
                title: Text(t.matriculeEquipe),
                subtitle: Text(t.chefEquipe?.prenom ?? '-'),
                trailing: Chip(label: const Text('Actif'), backgroundColor: ThemeConfig.successColor.withOpacity(0.12)),
              ),
            );
          },
        );
      },
    );
  }
}
