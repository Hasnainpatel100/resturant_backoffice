import '../../imports/core_imports.dart';

/// A stat card with icon, label, and value.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cardColor = color ?? cs.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: cardColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      trend!.startsWith('+') ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: trend!.startsWith('+') ? cs.primary : cs.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: trend!.startsWith('+') ? cs.primary : cs.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}