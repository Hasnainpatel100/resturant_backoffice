import '../../imports/core_imports.dart';

/// A simple pagination control with prev/next and page info.
class AppPagination extends StatelessWidget {
  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.showPageNumbers = true,
    this.maxVisiblePages = 5,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final bool showPageNumbers;
  final int maxVisiblePages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        if (showPageNumbers) ..._buildPageNumbers(context),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
        const SizedBox(width: 16),
        Text(
          'Page $currentPage of $totalPages',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    final pages = <Widget>[];
    final start = (currentPage - maxVisiblePages ~/ 2).clamp(1, totalPages);
    final end = (start + maxVisiblePages - 1).clamp(1, totalPages);

    for (var i = start; i <= end; i++) {
      pages.add(
        TextButton(
          onPressed: i == currentPage ? null : () => onPageChanged(i),
          style: TextButton.styleFrom(
            backgroundColor: i == currentPage
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
          ),
          child: Text('$i'),
        ),
      );
    }
    return pages;
  }
}