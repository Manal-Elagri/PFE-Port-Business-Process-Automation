import 'package:flutter/material.dart';
import '../../services/chef_service_service.dart';
import '../../models/chef_service_models.dart';
import '../widgets/loading_widget.dart';
import '../widgets/chart_card.dart';

class ChefServiceShiftCalendarScreen extends StatefulWidget {
  final String token;
  const ChefServiceShiftCalendarScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ChefServiceShiftCalendarScreen> createState() => _ChefServiceShiftCalendarScreenState();
}

class _ChefServiceShiftCalendarScreenState extends State<ChefServiceShiftCalendarScreen> {
  late Future<List<ShiftModel>> _future;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    _future = ChefServiceApiService().getShiftCalendar(token: widget.token, date: date);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ShiftModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: LoadingWidget(message: 'Chargement calendrier...'));
        if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
        final shifts = snapshot.data ?? [];
        if (shifts.isEmpty) return const Center(child: Text('Aucun shift pour aujourd\'hui'));
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calendrier des shifts', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...shifts.map((s) => Card(
                child: ListTile(
                  title: Text(s.type),
                  subtitle: Text('${s.heureDebut} - ${s.heureFin}'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.chefService?.prenom ?? '-'),
                      const SizedBox(height: 4),
                      Text(s.chefDivision?.prenom ?? '-'),
                    ],
                  ),
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }
}
