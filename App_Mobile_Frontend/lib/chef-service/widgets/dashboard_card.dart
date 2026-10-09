import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final String? subtitle;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.background = ThemeConfig.surfaceColor,
    this.iconColor = ThemeConfig.primaryColor,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [ThemeConfig.shadowSmall],
        border: Border.all(color: ThemeConfig.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: ThemeConfig.textSecondaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 28)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ]
        ],
      ),
    );
  }
}
