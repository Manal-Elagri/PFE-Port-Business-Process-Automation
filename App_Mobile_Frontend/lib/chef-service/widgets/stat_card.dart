import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color color;
  final double progress;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeConfig.borderColor),
        boxShadow: [ThemeConfig.shadowSmall],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 24, color: ThemeConfig.textPrimaryColor)),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: ThemeConfig.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
