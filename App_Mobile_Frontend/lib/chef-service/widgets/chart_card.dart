import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final List<double> values;
  final List<String> labels;
  final Color color;

  const ChartCard({Key? key, required this.title, required this.values, required this.labels, this.color = ThemeConfig.primaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeConfig.borderColor),
        boxShadow: [ThemeConfig.shadowSmall],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final data = values[index];
                final label = labels.length > index ? labels[index] : '';
                final barHeight = (data / (maxValue == 0 ? 1 : maxValue)) * 100;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
