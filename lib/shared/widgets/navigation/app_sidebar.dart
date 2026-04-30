import '../../../imports/imports.dart';

/// A responsive sidebar navigation for web/desktop.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    this.selectedIndex = 0,
    this.items = const [],
    this.onItemSelected,
    this.width = 250,
    this.header,
    this.footer,
  });

  final int selectedIndex;
  final List<SidebarItem> items;
  final ValueChanged<int>? onItemSelected;
  final double width;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;
                return _SidebarTile(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onItemSelected?.call(index),
                );
              },
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.isSelected, this.onTap});

  final SidebarItem item;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? cs.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.badge!,
                      style: theme.textTheme.labelSmall?.copyWith(color: cs.onError),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarItem {
  const SidebarItem({
    required this.icon,
    required this.label,
    this.route,
    this.badge,
    this.children,
  });

  final IconData icon;
  final String label;
  final String? route;
  final String? badge;
  final List<SidebarItem>? children;
}