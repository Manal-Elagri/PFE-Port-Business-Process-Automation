import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../models/chef_division_models.dart';
import '../../services/chef_division_service.dart';
import '../widgets/loading_widget.dart';

class EnginsKpiScreen extends StatefulWidget {
  final String token;
  const EnginsKpiScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<EnginsKpiScreen> createState() => _EnginsKpiScreenState();
}

class _EnginsKpiScreenState extends State<EnginsKpiScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<EnginKPI>> _topFuture;
  late Future<List<EnginUsageRate>> _usageFuture;
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _topFuture   = ChefDivisionApiService().getTopEngins(widget.token);
    _usageFuture = ChefDivisionApiService().getUsageRate(widget.token);
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      body: FutureBuilder<List<EnginKPI>>(
        future: _topFuture,
        builder: (ctx, topSnap) {
          return FutureBuilder<List<EnginUsageRate>>(
            future: _usageFuture,
            builder: (ctx, useSnap) {
              final loading =
                  topSnap.connectionState != ConnectionState.done ||
                      useSnap.connectionState != ConnectionState.done;

              if (loading) {
                return const Center(
                    child: LoadingWidget(message: 'Chargement des engins...'));
              }

              if (topSnap.hasError || useSnap.hasError) {
                return _buildError();
              }

              final top   = topSnap.data ?? [];
              final usage = useSnap.data ?? [];
              final avg   = usage.isEmpty
                  ? 0.0
                  : usage.map((e) => e.tauxUtilisation).reduce((a, b) => a + b) /
                      usage.length;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── App Bar ──────────────────────────────────
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    backgroundColor: ThemeConfig.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Engins KPI',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('Performance & utilisation',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ThemeConfig.primaryColor,
                              ThemeConfig.primaryColor.withBlue(200),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([

                        // ── KPI Cards ──────────────────────────
                        Row(children: [
                          Expanded(
                            child: _KpiCard(
                              label: 'Engins suivis',
                              value: '${top.length}',
                              icon: Icons.engineering_rounded,
                              color: ThemeConfig.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _KpiCard(
                              label: 'Usage moyen',
                              value: '${avg.toStringAsFixed(1)}%',
                              icon: Icons.speed_rounded,
                              color: ThemeConfig.secondaryColor,
                            ),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // ── Bar Chart ──────────────────────────
                        if (top.isNotEmpty) ...[
                          _SectionHeader(
                              title: 'Classement des engins',
                              icon: Icons.emoji_events_rounded,
                              color: ThemeConfig.accentColor),
                          const SizedBox(height: 12),
                          _BarChartCard(data: top, animation: _anim),
                          const SizedBox(height: 24),
                        ],

                        // ── Usage List ─────────────────────────
                        if (usage.isNotEmpty) ...[
                          _SectionHeader(
                              title: "Taux d'utilisation",
                              icon: Icons.bar_chart_rounded,
                              color: ThemeConfig.secondaryColor),
                          const SizedBox(height: 12),
                          ...usage.map((u) => _UsageRow(usage: u, animation: _anim)),
                        ],
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded, size: 48, color: ThemeConfig.textSecondaryColor),
        const SizedBox(height: 12),
        Text('Impossible de charger les données',
            style: TextStyle(color: ThemeConfig.textSecondaryColor)),
      ]),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Text(title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: ThemeConfig.textPrimaryColor,
              fontWeight: FontWeight.w700)),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              ThemeConfig.borderColor,
              ThemeConfig.borderColor.withOpacity(0),
            ]),
          ),
        ),
      ),
    ]);
  }
}

// ─── KPI Card ────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: ThemeConfig.borderRadiusLarge,
        border: Border.all(color: ThemeConfig.borderColor),
        boxShadow: [ThemeConfig.shadowSmall],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: ThemeConfig.borderRadiusMedium,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800, fontSize: 22)),
            const SizedBox(height: 2),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: ThemeConfig.textSecondaryColor)),
          ]),
        ),
      ]),
    );
  }
}

// ─── Bar Chart Card ──────────────────────────────────────────
class _BarChartCard extends StatelessWidget {
  final List<EnginKPI> data;
  final Animation<double> animation;
  const _BarChartCard({required this.data, required this.animation});

  @override
  Widget build(BuildContext context) {
    final maxOps = data
        .map((e) => e.totalOperations)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final medals = [
      ThemeConfig.accentColor,
      ThemeConfig.textSecondaryColor,
      const Color(0xFFCD7F32),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: ThemeConfig.borderRadiusLarge,
        border: Border.all(color: ThemeConfig.borderColor),
        boxShadow: [ThemeConfig.shadowMedium],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Chart bars
        SizedBox(
          height: 160,
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, __) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((e) {
                final idx   = e.key;
                final engin = e.value;
                final ratio = maxOps == 0
                    ? 0.0
                    : (engin.totalOperations / maxOps) * animation.value;
                final color = idx < 3
                    ? medals[idx]
                    : ThemeConfig.primaryColor.withOpacity(0.45);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${engin.totalOperations}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700,
                                    color: ThemeConfig.textPrimaryColor)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          child: Container(
                            height: 130 * ratio,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [color, color.withOpacity(0.55)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Divider
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 1,
          color: ThemeConfig.borderColor,
        ),

        // Labels
        Row(
          children: data.asMap().entries.map((e) {
            final idx   = e.key;
            final engin = e.value;
            final color = idx < 3 ? medals[idx] : ThemeConfig.textSecondaryColor;
            return Expanded(
              child: Column(children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  alignment: Alignment.center,
                  child: Text('${idx + 1}',
                      style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w800, color: color)),
                ),
                const SizedBox(height: 4),
                Text(
                  engin.typeEngin.length > 7
                      ? '${engin.typeEngin.substring(0, 6)}.'
                      : engin.typeEngin,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: ThemeConfig.textSecondaryColor),
                ),
              ]),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

// ─── Usage Row ───────────────────────────────────────────────
class _UsageRow extends StatelessWidget {
  final EnginUsageRate usage;
  final Animation<double> animation;
  const _UsageRow({required this.usage, required this.animation});

  @override
  Widget build(BuildContext context) {
    final val = (usage.tauxUtilisation / 100).clamp(0.0, 1.0);
    final Color barColor;
    final String statusLabel;
    if (val >= 0.75) {
      barColor    = ThemeConfig.successColor;
      statusLabel = 'Excellent';
    } else if (val >= 0.40) {
      barColor    = ThemeConfig.secondaryColor;
      statusLabel = 'Correct';
    } else {
      barColor    = ThemeConfig.errorColor;
      statusLabel = 'Faible';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: ThemeConfig.borderRadiusMedium,
        border: Border.all(color: ThemeConfig.borderColor),
        boxShadow: [ThemeConfig.shadowSmall],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.construction_rounded,
                  size: 15, color: ThemeConfig.primaryColor),
              const SizedBox(width: 8),
              Text(usage.typeEngin,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: barColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: barColor.withOpacity(0.3), width: 0.8),
              ),
              child: Text(statusLabel,
                  style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700, color: barColor)),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Bar + percentage
        Row(children: [
          Expanded(
            child: AnimatedBuilder(
              animation: animation,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: val * animation.value,
                  minHeight: 7,
                  backgroundColor: ThemeConfig.borderColor,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: animation,
            builder: (_, __) => SizedBox(
              width: 44,
              child: Text(
                '${(usage.tauxUtilisation * animation.value).toStringAsFixed(0)}%',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w800, color: barColor),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}