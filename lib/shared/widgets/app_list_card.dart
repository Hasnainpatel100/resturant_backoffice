import '../../imports/imports.dart';

/// A modern, lightweight list-item card used across all inventory list screens.
///
/// Features:
/// - Colored icon avatar
/// - Title + optional reference badge
/// - Subtitle lines (up to 2)
/// - Optional status chip
/// - Trailing action buttons
/// - InkWell tap ripple with rounded corners
///
/// Usage:
/// ```dart
/// AppListCard(
///   icon: Icons.business,
///   iconColor: cs.primary,
///   title: vendor.vendorName,
///   ref: vendor.vendorCode,
///   lines: ['Phone: ${vendor.phone}', 'Balance: ${vendor.openingBalance}'],
///   status: AppListCardStatus(label: 'Active', color: Colors.green),
///   onTap: () => ...,
///   actions: [
///     AppListCardAction(icon: Icons.edit_outlined, onTap: () => ...),
///     AppListCardAction(icon: Icons.delete_outline, color: cs.error, onTap: () => ...),
///   ],
/// )
/// ```
class AppListCard extends StatelessWidget {
  const AppListCard({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    required this.title,
    this.ref,
    this.lines = const [],
    this.status,
    this.actions = const [],
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String title;

  /// Short reference/code shown as a pill badge next to the title.
  final String? ref;

  /// Up to 2 subtitle lines shown below the title.
  final List<String> lines;

  /// Optional status chip (e.g. Draft, Posted, Active).
  final AppListCardStatus? status;

  /// Icon action buttons shown in the trailing area.
  final List<AppListCardAction> actions;

  /// Optional fully custom trailing widget (overrides [actions]).
  final Widget? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final effectiveIconColor = iconColor ?? cs.primary;
    final effectiveIconBg =
        iconBgColor ?? effectiveIconColor.withOpacity(0.10);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant, width: 0.8),
            ),
            child: Row(
              children: [
                // ── Icon avatar ────────────────────────────────────────
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: effectiveIconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: effectiveIconColor, size: 20),
                ),
                const SizedBox(width: 12),

                // ── Text block ─────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row (title + optional ref badge)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (ref != null) ...[
                            const SizedBox(width: 6),
                            _RefBadge(ref: ref!, cs: cs, tt: tt),
                          ],
                          if (status != null) ...[
                            const SizedBox(width: 6),
                            _StatusChip(status: status!, tt: tt),
                          ],
                        ],
                      ),

                      // Subtitle lines
                      if (lines.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        ...lines.take(2).map(
                              (l) => Text(
                                l,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                      ],
                    ],
                  ),
                ),

                // ── Trailing ───────────────────────────────────────────
                if (trailing != null)
                  trailing!
                else if (actions.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions.map((a) {
                      return SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(a.icon,
                              size: 19,
                              color: a.color ?? cs.onSurfaceVariant),
                          tooltip: a.tooltip,
                          onPressed: a.onTap,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Supporting data classes ──────────────────────────────────────────────────

class AppListCardStatus {
  const AppListCardStatus({required this.label, required this.color});
  final String label;
  final Color color;
}

class AppListCardAction {
  const AppListCardAction({
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final String? tooltip;
}

// ── Internal helpers ─────────────────────────────────────────────────────────

class _RefBadge extends StatelessWidget {
  const _RefBadge(
      {required this.ref, required this.cs, required this.tt});
  final String ref;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        ref,
        style: tt.labelSmall?.copyWith(
          fontSize: 10,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.tt});
  final AppListCardStatus status;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: status.color.withOpacity(0.30), width: 0.8),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: tt.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: status.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
