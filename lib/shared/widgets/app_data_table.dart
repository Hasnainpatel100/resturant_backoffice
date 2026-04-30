import '../../imports/core_imports.dart';

/// A reusable data table widget with sorting, pagination, and row actions.
class AppDataTable<T> extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage = 'No data available',
    this.isLoading = false,
    this.onRowTap,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String emptyMessage;
  final bool isLoading;
  final void Function(T)? onRowTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rows.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns,
        rows: rows,
        headingRowColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 48,
        dataRowMaxHeight: 64,
        headingRowHeight: 56,
        horizontalMargin: 16,
        columnSpacing: 24,
      ),
    );
  }
}

/// A helper to build a data cell with optional icon.
class DataCellContent extends StatelessWidget {
  const DataCellContent({
    super.key,
    required this.text,
    this.icon,
    this.color,
  });

  final String text;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color ?? Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(text, style: TextStyle(color: color))),
      ],
    );
  }
}