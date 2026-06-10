import 'dart:io';
import 'package:flutter/material.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/menu_repository_impl.dart';
import 'package:back_office/ui/menu/menu_dashboard/cubit_menu.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry-point: call this to launch the import sheet for a category.
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the CSV / Excel bulk-import bottom sheet scoped to [categoryId].
/// [onSuccess] is called after a successful API import so the caller can
/// refresh its item list.
void showCategoryImportSheet({
  required BuildContext context,
  required CubitMenu cubit,
  required String brandId,
  required String branchId,
  required String categoryId,
  required String categoryName,
  required VoidCallback onSuccess,
  required void Function(String) onError,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CsvImportSheet(
      cubit: cubit,
      brandId: brandId,
      branchId: branchId,
      categoryId: categoryId,
      categoryName: categoryName,
      onSuccess: onSuccess,
      onError: onError,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal model for a parsed (but not yet submitted) row
// ─────────────────────────────────────────────────────────────────────────────

class _ParsedRow {
  final int rowIndex;        // 1-based row number shown to user
  final String name;
  final String code;
  final String description;
  final double price;
  final bool isVeg;
  final bool isAvailable;
  final String? validationError;

  const _ParsedRow({
    required this.rowIndex,
    required this.name,
    required this.code,
    required this.description,
    required this.price,
    required this.isVeg,
    required this.isAvailable,
    this.validationError,
  });

  bool get isValid => validationError == null;

  Map<String, dynamic> toPayload({
    required String brandId,
    required String branchId,
    required String categoryId,
  }) =>
      {
        'brandId': brandId,
        'branchId': branchId,
        'categoryId': categoryId,
        'name': name,
        'code': code,
        'description': description,
        'price': price,
        'isVeg': isVeg,
        'foodType': isVeg ? 'VEG' : 'NON_VEG',
        'isAvailable': isAvailable,
        'displayOrder': 0,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Import sheet widget
// ─────────────────────────────────────────────────────────────────────────────

class _CsvImportSheet extends StatefulWidget {
  final CubitMenu cubit;
  final String brandId;
  final String branchId;
  final String categoryId;
  final String categoryName;
  final VoidCallback onSuccess;
  final void Function(String) onError;

  const _CsvImportSheet({
    required this.cubit,
    required this.brandId,
    required this.branchId,
    required this.categoryId,
    required this.categoryName,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_CsvImportSheet> createState() => _CsvImportSheetState();
}

class _CsvImportSheetState extends State<_CsvImportSheet> {
  // ── State ──────────────────────────────────────────────────────────────────
  _SheetStep _step = _SheetStep.idle;
  String? _fileName;
  List<_ParsedRow> _rows = [];
  String? _parseError;
  bool _isSubmitting = false;

  // ── Expected CSV column headers (case-insensitive) ─────────────────────────
  // name | code | description | price | isVeg | isAvailable
  // category column is intentionally NOT required.

  // ── File picking & parsing ─────────────────────────────────────────────────

  Future<void> _pickAndParse() async {
    setState(() {
      _step = _SheetStep.picking;
      _parseError = null;
      _rows = [];
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      setState(() => _step = _SheetStep.idle);
      return;
    }

    final file = result.files.first;
    _fileName = file.name;
    final bytes = file.bytes;

    if (bytes == null) {
      setState(() {
        _step = _SheetStep.idle;
        _parseError = 'Could not read file. Please try again.';
      });
      return;
    }

    try {
      List<List<dynamic>> rawRows;

      if (file.extension?.toLowerCase() == 'csv') {
        final content = String.fromCharCodes(bytes);
        rawRows = const CsvToListConverter(eol: '\n').convert(content);
      } else {
        // xlsx / xls
        final excel = Excel.decodeBytes(bytes);
        final sheet = excel.tables.values.first;
        rawRows = sheet.rows.map((row) {
          return row.map((cell) {
            if (cell == null) return '';

            final value = cell.value;
            return value?.toString() ?? '';
          }).toList();
        }).toList();
      }

      final parsed = _parseRows(rawRows);
      setState(() {
        _rows = parsed;
        _step = _SheetStep.preview;
      });
    } catch (e,st) {
      print(e);
      print(st);
      setState(() {
        _step = _SheetStep.idle;
        _parseError = 'Failed to parse file: ${e.toString()}';
      });
    }
  }

  List<_ParsedRow> _parseRows(List<List<dynamic>> rawRows) {
    if (rawRows.isEmpty) return [];

    // Detect header row
    final header = rawRows.first
        .map((c) => c.toString().trim().toLowerCase())
        .toList();

    int col(String name) => header.indexOf(name);

    final iName        = col('name');
    final iCode        = col('code');
    final iDesc        = col('description');
    final iPrice       = col('price');
    final iIsVeg       = col('isveg');
    final iAvailable   = col('isavailable');

    // Validate header
    if (iName == -1 || iPrice == -1) {
      throw const FormatException(
        'Missing required columns. File must have at least: name, price',
      );
    }

    final result = <_ParsedRow>[];

    for (int i = 1; i < rawRows.length; i++) {
      final row = rawRows[i];
      if (row.every((c) => c.toString().trim().isEmpty)) continue; // skip blank

      String cell(int idx) =>
          idx >= 0 && idx < row.length ? row[idx].toString().trim() : '';

      final name  = cell(iName);
      final code  = cell(iCode);
      final desc  = cell(iDesc);
      final priceStr = cell(iPrice);
      final price = double.tryParse(priceStr);
      final isVeg = _parseBool(cell(iIsVeg));
      final isAvail = _parseBool(cell(iAvailable), defaultValue: true);

      String? error;
      if (name.isEmpty) {
        error = 'Name is required';
      } else if (price == null || price < 0) {
        error = 'Invalid price "$priceStr"';
      }

      result.add(_ParsedRow(
        rowIndex: i,
        name: name,
        code: code,
        description: desc,
        price: price ?? 0,
        isVeg: isVeg,
        isAvailable: isAvail,
        validationError: error,
      ));
    }

    return result;
  }

  bool _parseBool(String value, {bool defaultValue = false}) {
    final v = value.toLowerCase();
    if (v == 'true' || v == '1' || v == 'yes' || v == 'y') return true;
    if (v == 'false' || v == '0' || v == 'no' || v == 'n') return false;
    return defaultValue;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final validRows = _rows.where((r) => r.isValid).toList();
    if (validRows.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final payloads = validRows
          .map((r) => r.toPayload(
        brandId: widget.brandId,
        branchId: widget.branchId,
        categoryId: widget.categoryId,
      ))
          .toList();

      await widget.cubit.createMenuItems(
        widget.brandId,
        payloads,
      );

      if (mounted) Navigator.of(context).pop();
      widget.onSuccess();
    } catch (e) {
      widget.onError('Import failed: ${e.toString()}');
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          _DragHandle(),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.upload_file_rounded,
                      color: cs.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import to "${widget.categoryName}"',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'CSV or Excel • category assigned automatically',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: _step == _SheetStep.preview && _rows.isNotEmpty
                  ? _PreviewBody(
                rows: _rows,
                isSubmitting: _isSubmitting,
                onReplace: _pickAndParse,
                onSubmit: _submit,
              )
                  : _PickerBody(
                isPicking: _step == _SheetStep.picking,
                parseError: _parseError,
                onPick: _pickAndParse,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step: idle / picking — file picker CTA
// ─────────────────────────────────────────────────────────────────────────────

class _PickerBody extends StatelessWidget {
  final bool isPicking;
  final String? parseError;
  final VoidCallback onPick;

  const _PickerBody({
    required this.isPicking,
    required this.parseError,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Template column guide ────────────────────────────────────────
        _SectionCard(
          icon: Icons.table_chart_outlined,
          title: 'Expected columns',
          child: Column(
            children: const [
              _ColRow(col: 'name', note: 'Required', required: true),
              _ColRow(col: 'code', note: 'SKU / item code'),
              _ColRow(col: 'description', note: 'Short description'),
              _ColRow(col: 'price', note: 'Required · numeric', required: true),
              _ColRow(col: 'isVeg', note: 'true / false  (default: false)'),
              _ColRow(col: 'isAvailable', note: 'true / false  (default: true)'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Note: no category column needed ──────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cs.secondaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: cs.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Do NOT add a "category" column — it is injected automatically.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Error banner ─────────────────────────────────────────────────
        if (parseError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: cs.onErrorContainer, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    parseError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Pick button ──────────────────────────────────────────────────
        FilledButton.icon(
          onPressed: isPicking ? null : onPick,
          icon: isPicking
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.folder_open_rounded, size: 18),
          label: Text(isPicking ? 'Opening…' : 'Choose CSV or Excel File'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step: preview — parsed rows table with error highlights
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewBody extends StatelessWidget {
  final List<_ParsedRow> rows;
  final bool isSubmitting;
  final VoidCallback onReplace;
  final VoidCallback onSubmit;

  const _PreviewBody({
    required this.rows,
    required this.isSubmitting,
    required this.onReplace,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final validCount  = rows.where((r) => r.isValid).length;
    final errorCount  = rows.length - validCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Summary chips ────────────────────────────────────────────────
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(
              icon: Icons.check_circle_outline,
              label: '$validCount valid',
              color: Colors.green.shade700,
              bg: Colors.green.shade50,
            ),
            if (errorCount > 0)
              _SummaryChip(
                icon: Icons.warning_amber_rounded,
                label: '$errorCount will be skipped',
                color: Colors.orange.shade700,
                bg: Colors.orange.shade50,
              ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Row table ────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Table(
            border: TableBorder.all(
              color: cs.outlineVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            columnWidths: const {
              0: FixedColumnWidth(32),  // #
              1: FlexColumnWidth(2.5),  // name
              2: FlexColumnWidth(1),    // price
              3: FixedColumnWidth(40),  // veg
              4: FixedColumnWidth(40),  // avail
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(color: cs.surfaceContainerHighest),
                children: const [
                  _TH('#'),
                  _TH('Name'),
                  _TH('Price'),
                  _TH('Veg'),
                  _TH('Avail'),
                ],
              ),
              // Data rows (capped for perf; user can still import all)
              for (final row in rows.take(50))
                TableRow(
                  decoration: BoxDecoration(
                    color: row.isValid
                        ? null
                        : Colors.orange.shade50,
                  ),
                  children: [
                    _TD(
                      '${row.rowIndex}',
                      error: !row.isValid,
                    ),
                    _TD(
                      row.isValid ? row.name : '${row.name}\n⚠ ${row.validationError}',
                      error: !row.isValid,
                    ),
                    _TD(
                      row.isValid ? '₹${row.price.toStringAsFixed(2)}' : '—',
                      error: !row.isValid,
                    ),
                    _TD(row.isVeg ? '🟢' : '🔴'),
                    _TD(row.isAvailable ? '✓' : '✗'),
                  ],
                ),
              if (rows.length > 50)
                TableRow(children: [
                  _TD('…'),
                  _TD('${rows.length - 50} more rows not shown'),
                  _TD(''),
                  _TD(''),
                  _TD(''),
                ]),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Action buttons ───────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSubmitting ? null : onReplace,
                icon: const Icon(Icons.folder_open_rounded, size: 16),
                label: const Text('Replace file'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: validCount == 0 || isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.upload_rounded, size: 18),
                label: Text(
                  isSubmitting
                      ? 'Importing…'
                      : 'Import $validCount item${validCount == 1 ? '' : 's'}',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helper widgets
// ─────────────────────────────────────────────────────────────────────────────

enum _SheetStep { idle, picking, preview }

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ColRow extends StatelessWidget {
  final String col;
  final String note;
  final bool required;

  const _ColRow({
    required this.col,
    required this.note,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: required
                  ? cs.primaryContainer
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              col,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: required ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            note,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// Table header cell
class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

// Table data cell
class _TD extends StatelessWidget {
  final String text;
  final bool error;
  const _TD(this.text, {this.error = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: error ? Colors.orange.shade800 : null,
        fontSize: 11,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
