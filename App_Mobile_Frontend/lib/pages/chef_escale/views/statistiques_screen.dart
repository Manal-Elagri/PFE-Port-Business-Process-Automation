import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../services/chef_escale_service.dart';
import '../../../models/chef_escale_models.dart';

class StatistiquesScreen extends StatefulWidget {
  final String token;
  final ChefEscaleDashboardStats stats;

  const StatistiquesScreen({
    Key? key,
    required this.token,
    required this.stats,
  }) : super(key: key);

  @override
  State<StatistiquesScreen> createState() =>
      _StatistiquesScreenState();
}

class _StatistiquesScreenState
    extends State<StatistiquesScreen> {
  final ChefEscaleApiService api =
      ChefEscaleApiService();

  ChefEscaleDashboardStats? stats;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    stats = await api.getDashboard(widget.token);

    setState(() => loading = false);
  }

  //══════════════════════════════════════
  // KPI CARD
  //══════════════════════════════════════

  Widget _kpiCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                color.withOpacity(.15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //══════════════════════════════════════
  // PIE CHART
  //══════════════════════════════════════

  Widget _pieChart() {
    return SizedBox(
      height: 280,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 60,
          sectionsSpace: 3,
          sections: [
            PieChartSectionData(
              value: stats!.totalEquipes.toDouble(),
              color: Colors.blue,
              title: "Équipes",
              radius: 85,
            ),
            PieChartSectionData(
              value: stats!.totalPersonnels.toDouble(),
              color: Colors.green,
              title: "Personnel",
              radius: 85,
            ),
            PieChartSectionData(
              value: stats!.totalShifts.toDouble(),
              color: Colors.orange,
              title: "Shifts",
              radius: 85,
            ),
            PieChartSectionData(
              value: stats!.totalMouvements.toDouble(),
              color: Colors.red,
              title: "Mvts",
              radius: 85,
            ),
          ],
        ),
      ),
    );
  }

  //══════════════════════════════════════
  // BAR CHART
  //══════════════════════════════════════

  Widget _barChart() {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(
            show: false,
          ),
          gridData: FlGridData(
            show: true,
          ),
          titlesData: FlTitlesData(
            rightTitles:
                AxisTitles(
              sideTitles:
                  SideTitles(
                showTitles: false,
              ),
            ),
            topTitles:
                AxisTitles(
              sideTitles:
                  SideTitles(
                showTitles: false,
              ),
            ),
            bottomTitles:
                AxisTitles(
              sideTitles:
                  SideTitles(
                showTitles: true,
                getTitlesWidget:
                    (value, meta) {
                  switch (
                      value.toInt()) {
                    case 0:
                      return const Text(
                        "Eq",
                        style: TextStyle(
                          color:
                              Colors.white,
                        ),
                      );

                    case 1:
                      return const Text(
                        "Pers",
                        style: TextStyle(
                          color:
                              Colors.white,
                        ),
                      );

                    case 2:
                      return const Text(
                        "Shift",
                        style: TextStyle(
                          color:
                              Colors.white,
                        ),
                      );

                    case 3:
                      return const Text(
                        "Mvts",
                        style: TextStyle(
                          color:
                              Colors.white,
                        ),
                      );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY:
                      stats!.totalEquipes
                          .toDouble(),
                  color: Colors.blue,
                  width: 22,
                )
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: stats!
                      .totalPersonnels
                      .toDouble(),
                  color: Colors.green,
                  width: 22,
                )
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY:
                      stats!.totalShifts
                          .toDouble(),
                  color:
                      Colors.orange,
                  width: 22,
                )
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: stats!
                      .totalMouvements
                      .toDouble(),
                  color: Colors.red,
                  width: 22,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  //══════════════════════════════════════
  // BUILD
  //══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0B1220),

      appBar: AppBar(
        title: const Text(
          "Statistiques",
        ),
        backgroundColor:
            const Color(0xFF0B1220),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding:
                    const EdgeInsets.all(
                        16),
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing:
                        12,
                    crossAxisSpacing:
                        12,
                    childAspectRatio:
                        1.6,
                    children: [
                      _kpiCard(
                        "Équipes",
                        stats!
                            .totalEquipes,
                        Icons.groups,
                        Colors.blue,
                      ),
                      _kpiCard(
                        "Personnel",
                        stats!
                            .totalPersonnels,
                        Icons.people,
                        Colors.green,
                      ),
                      _kpiCard(
                        "Shifts",
                        stats!
                            .totalShifts,
                        Icons.schedule,
                        Colors.orange,
                      ),
                      _kpiCard(
                        "Mouvements",
                        stats!
                            .totalMouvements,
                        Icons.local_shipping,
                        Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 25),

                  const Text(
                    "Répartition globale",
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  _pieChart(),

                  const SizedBox(
                      height: 25),

                  const Text(
                    "Comparaison des indicateurs",
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  _barChart(),
                ],
              ),
            ),
    );
  }
}