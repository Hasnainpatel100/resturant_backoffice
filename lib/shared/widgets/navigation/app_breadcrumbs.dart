import 'package:back_office/imports/imports.dart';

/// A breadcrumb navigation widget.
class AppBreadcrumbs extends StatelessWidget {
  const AppBreadcrumbs({
    super.key,
    required this.items,
    this.onItemTap,
  });

  final List<BreadcrumbItem> items;
  final ValueChanged<int>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          if (i == items.length - 1)
            Text(
              items[i].label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            )
          else
            InkWell(
              onTap: () => onItemTap?.call(i),
              child: Text(
                items[i].label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
        ],
      ],
    );
  }
}

class BreadcrumbItem {
  const BreadcrumbItem({required this.label, this.route});

  final String label;
  final String? route;
}