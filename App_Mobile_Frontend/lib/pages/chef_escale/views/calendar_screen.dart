import 'package:flutter/material.dart';
import '../../../models/chef_escale_models.dart';
import '../../../services/chef_escale_service.dart';

class CalendarScreen extends StatefulWidget {
  final String token;

  const CalendarScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<CalendarScreen> createState() =>
      _CalendarScreenState();
}

class _CalendarScreenState
    extends State<CalendarScreen> {

  final ChefEscaleApiService api =
      ChefEscaleApiService();

  bool loading = true;

  List<EquipeModel> equipes = [];

  @override
  void initState() {
    super.initState();
    loadCalendar();
  }

  Future<void> loadCalendar() async {
    setState(() => loading = true);

    equipes =
        await api.getCalendar(widget.token);

    setState(() => loading = false);
  }

  //══════════════════════════════════
  // GROUP BY DATE
  //══════════════════════════════════

  Map<String, List<EquipeModel>> get grouped {
    final Map<String, List<EquipeModel>> data = {};

    for (final e in equipes) {
      final date =
          e.shift?.planningDate ?? "Sans date";

      data.putIfAbsent(date, () => []);

      data[date]!.add(e);
    }

    return data;
  }

  //══════════════════════════════════
  // SHIFT COLOR
  //══════════════════════════════════

  Color shiftColor(String? shift) {
    switch (shift) {
      case "SHIFT_1":
        return Colors.blue;

      case "SHIFT_2":
        return Colors.orange;

      case "SHIFT_3":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  //══════════════════════════════════
  // STATS
  //══════════════════════════════════

  int get totalEquipes =>
      equipes.length;

  int get totalDays =>
      grouped.length;

  //══════════════════════════════════
  // EMPTY STATE
  //══════════════════════════════════

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.calendar_month,
            size: 90,
            color: Colors.white24,
          ),
          SizedBox(height: 15),
          Text(
            "Aucun planning disponible",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }

  //══════════════════════════════════
  // DATE HEADER
  //══════════════════════════════════

  Widget buildDateHeader(String date) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            date,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  //══════════════════════════════════
  // EQUIPE CARD
  //══════════════════════════════════

  Widget equipeCard(
    EquipeModel equipe,
    int index,
  ) {
    return TweenAnimationBuilder(
      duration: Duration(
        milliseconds: 250 + (index * 80),
      ),
      tween: Tween(begin: 0.0, end: 1.0),
      builder:
          (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset:
                Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 4,
        color: const Color(0xFF111827),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: shiftColor(
              equipe.shift?.type,
            ),
            child: const Icon(
              Icons.groups,
              color: Colors.white,
            ),
          ),

          title: Text(
            equipe.matriculeEquipe,
            style: const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              Text(
                equipe.shift?.type ??
                    "Sans shift",
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),

              Text(
                "${equipe.shift?.heureDebut ?? '--'} → ${equipe.shift?.heureFin ?? '--'}",
                style: const TextStyle(
                  color: Colors.white54,
                ),
              ),

              if (equipe.chefEquipe != null)
                Text(
                  "Chef : ${equipe.chefEquipe!.nom} ${equipe.chefEquipe!.prenom}",
                  style: const TextStyle(
                    color: Colors.white60,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //══════════════════════════════════
  // BUILD
  //══════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0B1220),

      appBar: AppBar(
        title:
            const Text("Calendrier des équipes"),
        backgroundColor:
            const Color(0xFF0B1220),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : equipes.isEmpty
              ? emptyState()
              : RefreshIndicator(
                  onRefresh: loadCalendar,
                  child: Column(
                    children: [

                      //════════ STATS ════════

                      Padding(
                        padding:
                            const EdgeInsets.all(
                                16),
                        child: Row(
                          children: [

                            Expanded(
                              child: _statCard(
                                "Équipes",
                                totalEquipes
                                    .toString(),
                                Icons.groups,
                              ),
                            ),

                            const SizedBox(
                                width: 12),

                            Expanded(
                              child: _statCard(
                                "Jours",
                                totalDays
                                    .toString(),
                                Icons.calendar_month,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          padding:
                              const EdgeInsets
                                  .all(16),
                          children: grouped.entries
                              .map((entry) {

                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [

                                buildDateHeader(
                                    entry.key),

                                ...entry.value
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) =>
                                          equipeCard(
                                        e.value,
                                        e.key,
                                      ),
                                    ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: Colors.cyanAccent,
            size: 30,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
              fontSize: 22,
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}