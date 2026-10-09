import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({Key? key, required this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
        ]
      ],
    );
  }
}
