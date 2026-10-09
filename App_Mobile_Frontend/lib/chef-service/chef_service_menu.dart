import 'package:flutter/material.dart';
import 'chef_service_routes.dart';

class ChefServiceMenu extends StatelessWidget {
  final String selectedRoute;
  final ValueChanged<String> onSelected;
  final VoidCallback? onLogout;

  const ChefServiceMenu({
    Key? key,
    required this.selectedRoute,
    required this.onSelected,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chef de service',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ..._menuItems.map((item) {
                    final selected = item.route == selectedRoute;
                    return ListTile(
                      leading: Icon(
                        item.icon,
                        color: selected ? colors.primary : theme.textTheme.bodyMedium?.color,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                          color: selected ? colors.primary : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      selected: selected,
                      selectedTileColor: colors.primary.withOpacity(0.08),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      onTap: () => onSelected(item.route),
                    );
                  }),
                  ListTile(
                    leading: Icon(Icons.logout_rounded, color: colors.error),
                    title: Text(
                      'Déconnexion',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.error,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onSelected(ChefServiceRoutes.dashboard),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(color: colors.primary),
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

class _ChefServiceMenuItem {
  final String route;
  final String label;
  final IconData icon;

  const _ChefServiceMenuItem(this.route, this.label, this.icon);
}

const List<_ChefServiceMenuItem> _menuItems = [
  _ChefServiceMenuItem(ChefServiceRoutes.dashboard, 'Dashboard', Icons.dashboard_rounded),
  _ChefServiceMenuItem(ChefServiceRoutes.profile, 'Profil', Icons.person_rounded),
  _ChefServiceMenuItem(ChefServiceRoutes.signatures, 'Signatures', Icons.history_rounded),
  _ChefServiceMenuItem(ChefServiceRoutes.conges, 'Congés', Icons.beach_access_rounded),
  _ChefServiceMenuItem(ChefServiceRoutes.shiftCalendar, 'Calendrier Shift', Icons.calendar_today_rounded),
  _ChefServiceMenuItem(ChefServiceRoutes.shiftHistory, 'Historique Shift', Icons.history_edu_rounded),
  _ChefServiceMenuItem(ChefServiceRoutes.shiftEquipes, 'Équipes Shift', Icons.groups_rounded),
  _ChefServiceMenuItem(ChefServiceRoutes.activeEquipes, 'Équipes Actives', Icons.checklist_rtl_rounded),
];
