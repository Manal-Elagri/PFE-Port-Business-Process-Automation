import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../models/chef_division_models.dart';
import '../../services/chef_division_service.dart';
import '../widgets/loading_widget.dart';

class ProfileScreen extends StatelessWidget {
  final String token;
  final ChefDivisionProfile? profile;

  const ProfileScreen({Key? key, required this.token, this.profile}) : super(key: key);

  Future<ChefDivisionProfile> _loadProfile() async {
    if (profile != null) return profile!;
    return await ChefDivisionApiService().getProfile(token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChefDivisionProfile>(
      future: _loadProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LoadingWidget(message: 'Chargement du profil...'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Impossible de charger le profil.'));
        }
        final profile = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profil', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: ThemeConfig.primaryColor.withOpacity(0.12),
                        foregroundColor: ThemeConfig.primaryColor,
                        child: Text(
                          '${profile.prenom.isNotEmpty ? profile.prenom[0] : 'C'}${profile.nom.isNotEmpty ? profile.nom[0] : 'D'}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profile.prenom} ${profile.nom}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(profile.role,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ThemeConfig.textSecondaryColor)),
                            const SizedBox(height: 12),
                            Text(profile.email, style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Informations' , style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      _buildDetail('ID', profile.id.toString()),
                      _buildDetail('Nom complet', '${profile.prenom} ${profile.nom}'),
                      _buildDetail('Rôle', profile.role),
                      _buildDetail('Email', profile.email),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF0F172A)))),
        ],
      ),
    );
  }
}
