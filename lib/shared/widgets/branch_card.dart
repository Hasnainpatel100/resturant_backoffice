import '../../imports/core_imports.dart';

/// A card for displaying a branch summary.
class BranchCard extends StatelessWidget {
  const BranchCard({
    super.key,
    required this.name,
    this.address,
    this.plan,
    this.userCount,
    this.status,
    this.onTap,
  });

  final String name;
  final String? address;
  final String? plan;
  final int? userCount;
  final String? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store, color: cs.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'active' ? cs.primaryContainer : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(status!, style: theme.textTheme.labelSmall),
                    ),
                ],
              ),
              if (address != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address!,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (plan != null) ...[
                    Icon(Icons.card_membership, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(plan!, style: theme.textTheme.bodySmall),
                  ],
                  if (userCount != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('$userCount users', style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}