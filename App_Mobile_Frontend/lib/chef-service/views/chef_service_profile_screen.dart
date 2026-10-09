import 'package:flutter/material.dart';
import '../../services/chef_service_service.dart';
import '../../models/chef_service_models.dart';
import '../widgets/loading_widget.dart';

class ChefServiceProfileScreen extends StatelessWidget {
  final String token;
  const ChefServiceProfileScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
      ),
      body: FutureBuilder<ChefServiceProfile>(
        future: ChefServiceApiService().getProfile(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: LoadingWidget(message: 'Chargement profil...'));
          if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
          final p = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 40, backgroundImage: p.formattedImageUrl != null ? NetworkImage(p.formattedImageUrl!) : null, child: p.formattedImageUrl == null ? Text('${p.prenom.isNotEmpty ? p.prenom[0] : 'C'}') : null),
                const SizedBox(height: 12),
                Text('${p.prenom} ${p.nom}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(p.email),
                const SizedBox(height: 12),
                Text('Rôle: ${p.role}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
