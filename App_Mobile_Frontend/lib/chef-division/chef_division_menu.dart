import 'package:flutter/material.dart';
import 'chef_division_routes.dart';
import '../config/theme_config.dart';

class ChefDivisionMenu extends StatelessWidget {
  final String selectedRoute;
  final ValueChanged<String> onSelected;

  const ChefDivisionMenu({
    Key? key,
    required this.selectedRoute,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: ThemeConfig.backgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chef de division',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _menuItems.map((item) {
                  final selected = item.route == selectedRoute;
                  return ListTile(
                    leading: Icon(item.icon,
                        color: selected
                            ? ThemeConfig.primaryColor
                            : ThemeConfig.textSecondaryColor),
                    title: Text(item.label,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                          color: selected
                              ? ThemeConfig.primaryColor
                              : ThemeConfig.textPrimaryColor,
                        )),
                    selected: selected,
                    selectedTileColor:
                        ThemeConfig.primaryColor.withOpacity(0.08),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    onTap: () => onSelected(item.route),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onSelected(ChefDivisionRoutes.dashboard),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeConfig.primaryColor,
                        side: const BorderSide(color: ThemeConfig.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChefDivisionMenuItem {
  final String route;
  final String label;
  final IconData icon;

  const _ChefDivisionMenuItem(this.route, this.label, this.icon);
}

const List<_ChefDivisionMenuItem> _menuItems = [
  _ChefDivisionMenuItem(ChefDivisionRoutes.dashboard, 'Dashboard', Icons.dashboard_rounded),
  _ChefDivisionMenuItem(ChefDivisionRoutes.profile, 'Profil', Icons.person_rounded),
 
 
  _ChefDivisionMenuItem(ChefDivisionRoutes.arrets, 'Arrêts', Icons.report_problem_rounded),
  _ChefDivisionMenuItem(ChefDivisionRoutes.engins, 'Engins', Icons.precision_manufacturing_rounded),
  _ChefDivisionMenuItem(ChefDivisionRoutes.escales, 'Escales', Icons.anchor_rounded),
  _ChefDivisionMenuItem(ChefDivisionRoutes.equipes, 'Équipes', Icons.groups_rounded),
];
