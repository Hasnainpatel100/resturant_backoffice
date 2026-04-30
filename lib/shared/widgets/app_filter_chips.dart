import '../../imports/core_imports.dart';

/// A horizontal scrollable row of filter chips.
class AppFilterChips extends StatelessWidget {
  const AppFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.labelBuilder,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onSelected;
  final String Function(String)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = selected.contains(option);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(labelBuilder?.call(option) ?? option),
              selected: isSelected,
              onSelected: (_) {
                final newSelected = Set<String>.from(selected);
                if (isSelected) {
                  newSelected.remove(option);
                } else {
                  newSelected.add(option);
                }
                onSelected(newSelected);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}