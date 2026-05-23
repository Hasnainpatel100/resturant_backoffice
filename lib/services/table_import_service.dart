// ---------------------------------------------------------------------------
// TableImportRow – one parsed & validated row ready for API submission
// ---------------------------------------------------------------------------

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border;
import '../imports/imports.dart';

class TableImportRow {
  final String tableNumber;

  // User enters this from Excel
  final String roomTypeName;

  final String displayName;
  final int capacity;
  final String description;
  final String status;
  final bool isActive;
  final double? positionX;
  final double? positionY;

  const TableImportRow({
    required this.tableNumber,
    required this.roomTypeName,
    required this.displayName,
    required this.capacity,
    required this.description,
    required this.status,
    required this.isActive,
    this.positionX,
    this.positionY,
  });

  /// Converts to final API map
  Map<String, dynamic> toApiMap({
    required String brandId,
    required String branchId,
  }) {
    return {
      'tableNumber': tableNumber,
      //'roomTypeId': roomTypeId,
      'displayName': displayName,
      'capacity': capacity,
      'description': description,
      'status': status,
      'isActive': isActive,
      'positionX': positionX ?? 0,
      'positionY': positionY ?? 0,
      'brandId': brandId,
      'branchId': branchId,
    };
  }
}

// ---------------------------------------------------------------------------
// TableImportResult – full result after parsing a file
// ---------------------------------------------------------------------------

class TableImportResult {
  final List<TableImportRow> rows;
  final List<String> errors; // row-level validation errors

  const TableImportResult({required this.rows, required this.errors});

  bool get hasErrors => errors.isNotEmpty;
}

// ---------------------------------------------------------------------------
// TableImportService
// ---------------------------------------------------------------------------

class TableImportService {
  static const _allowedStatuses = {
    'available',
    'occupied',
    'reserved',
    'blocked',
  };

  // ── Required headers (case-insensitive) ────────────────────────────────────
  static const _requiredHeaders = {'tablenumber', 'roomtypeid', 'capacity'};

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Opens the OS file picker and parses the selected file.
  /// Returns null if the user cancels, or a [TableImportResult] on success.
  Future<TableImportResult?> pickAndParse() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    final ext = (file.extension ?? '').toLowerCase();
    if (ext == 'csv') {
      return _parseCsv(bytes);
    } else if (ext == 'xlsx' || ext == 'xls') {
      return _parseExcel(bytes);
    } else {
      return TableImportResult(
        rows: [],
        errors: ['Unsupported file format. Please use .xlsx, .xls, or .csv.'],
      );
    }
  }

  // ── Parsers ────────────────────────────────────────────────────────────────

  TableImportResult _parseExcel(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null || sheet.rows.isEmpty) {
      return TableImportResult(rows: [], errors: ['Excel sheet is empty.']);
    }

    // First row = headers
    final headers = sheet.rows.first
        .map((c) => (c?.value?.toString() ?? '').trim().toLowerCase())
        .toList();

    final missingHeaders =
        _requiredHeaders.where((h) => !headers.contains(h)).toList();
    if (missingHeaders.isNotEmpty) {
      return TableImportResult(
        rows: [],
        errors: [
          'Missing required columns: ${missingHeaders.join(', ')}. '
              'Please use the Download Format template.'
        ],
      );
    }

    final rawRows = sheet.rows.skip(1).map((row) {
      return row.map((c) => c?.value?.toString() ?? '').toList();
    }).toList();

    return _validateAndBuild(headers, rawRows);
  }

  TableImportResult _parseCsv(Uint8List bytes) {
    final csvString = String.fromCharCodes(bytes);
    final rows = CsvToListConverter().convert(csvString);
    if (rows.isEmpty) {
      return TableImportResult(rows: [], errors: ['CSV file is empty.']);
    }

    final headers =
        rows.first.map((e) => e.toString().trim().toLowerCase()).toList();

    final missingHeaders =
        _requiredHeaders.where((h) => !headers.contains(h)).toList();
    if (missingHeaders.isNotEmpty) {
      return TableImportResult(
        rows: [],
        errors: [
          'Missing required columns: ${missingHeaders.join(', ')}. '
              'Please use the Download Format template.'
        ],
      );
    }

    final rawRows =
        rows.skip(1).map((r) => r.map((e) => e.toString()).toList()).toList();

    return _validateAndBuild(headers, rawRows);
  }

  // ── Core Validator ─────────────────────────────────────────────────────────

  TableImportResult _validateAndBuild(
    List<String> headers,
    List<List<String>> rawRows,
  ) {
    final rows = <TableImportRow>[];
    final errors = <String>[];
    final seenTableNumbers = <String>{};

    String col(List<String> row, String name) {
      final idx = headers.indexOf(name);
      if (idx == -1 || idx >= row.length) return '';
      return row[idx].trim();
    }

    for (var i = 0; i < rawRows.length; i++) {
      final rowNum = i + 2; // 1-based, skipping header row
      final raw = rawRows[i];

      // Skip fully empty rows
      if (raw.every((cell) => cell.isEmpty)) continue;

      final tableNumber = col(raw, 'tablenumber');
      final roomTypeName = col(raw, 'roomtypeid');
      final capacityStr = col(raw, 'capacity');
      final displayName = col(raw, 'displayname');
      final description = col(raw, 'description');
      final statusRaw = col(raw, 'status');
      final isActiveRaw = col(raw, 'isactive');
      final posXRaw = col(raw, 'positionx');
      final posYRaw = col(raw, 'positiony');

      // ── Required field checks ──────────────────────────────────────────────
      if (tableNumber.isEmpty) {
        errors.add('Row $rowNum: tableNumber is required.');
        continue;
      }

      if (roomTypeName.isEmpty) {
        errors.add('Row $rowNum ($tableNumber): roomTypeName is required.');
        continue;
      }

      final capacity = int.tryParse(capacityStr);
      if (capacity == null || capacity < 0) {
        errors.add(
          'Row $rowNum ($tableNumber): capacity must be a non-negative integer '
          '(got "$capacityStr").',
        );
        continue;
      }

      // ── Duplicate check ────────────────────────────────────────────────────
      if (seenTableNumbers.contains(tableNumber.toLowerCase())) {
        errors.add(
          'Row $rowNum: duplicate tableNumber "$tableNumber" in the import file.',
        );
        continue;
      }
      seenTableNumbers.add(tableNumber.toLowerCase());

      // ── Optional field defaults & validation ───────────────────────────────
      final status = statusRaw.isEmpty ? 'available' : statusRaw.toLowerCase();
      if (!_allowedStatuses.contains(status)) {
        errors.add(
          'Row $rowNum ($tableNumber): invalid status "$statusRaw". '
          'Allowed values: ${_allowedStatuses.join(', ')}.',
        );
        continue;
      }

      final isActive =
          isActiveRaw.isEmpty ? true : isActiveRaw.toLowerCase() != 'false';

      final posX = posXRaw.isEmpty ? null : double.tryParse(posXRaw);
      final posY = posYRaw.isEmpty ? null : double.tryParse(posYRaw);

      rows.add(TableImportRow(
        tableNumber: tableNumber,
        roomTypeName: roomTypeName,
        displayName: displayName.isEmpty ? tableNumber : displayName,
        capacity: capacity,
        description: description,
        status: status,
        isActive: isActive,
        positionX: posX,
        positionY: posY,
      ));
    }

    if (rows.isEmpty && errors.isEmpty) {
      errors.add('No valid rows found in the file.');
    }

    return TableImportResult(rows: rows, errors: errors);
  }
}

// ---------------------------------------------------------------------------
// ImportPreviewDialog – shows parsed rows + errors before confirmation
// ---------------------------------------------------------------------------

class ImportPreviewDialog extends StatelessWidget {
  final TableImportResult result;
  final VoidCallback onConfirm;

  const ImportPreviewDialog({
    super.key,
    required this.result,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ─────────────────────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.preview_outlined, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text('Import Preview',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  // Summary chips
                  if (result.rows.isNotEmpty)
                    _Chip(
                      label: '${result.rows.length} valid',
                      color: Colors.green,
                    ),
                  if (result.errors.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _Chip(
                      label:
                          '${result.errors.length} error${result.errors.length == 1 ? '' : 's'}',
                      color: Colors.red,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // ── Errors ────────────────────────────────────────────────────
              if (result.hasErrors) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Validation Errors',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: Colors.red.shade700)),
                      const SizedBox(height: 6),
                      ...result.errors.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('• $e',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.red.shade800)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Valid rows table ───────────────────────────────────────────
              if (result.rows.isNotEmpty) ...[
                Text('Valid Rows (${result.rows.length})',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SingleChildScrollView(
                        child: _PreviewTable(rows: result.rows),
                      ),
                    ),
                  ),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Text('No valid rows to import.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  ),
                ),

              const SizedBox(height: 20),

              // ── Actions ───────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12)),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: result.rows.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                    icon: const Icon(Icons.upload_rounded, size: 18),
                    label: Text(
                      'Import ${result.rows.length} Table${result.rows.length == 1 ? '' : 's'}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _PreviewTable extends StatelessWidget {
  final List<TableImportRow> rows;
  const _PreviewTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87);
    const cellStyle = TextStyle(fontSize: 12, color: Colors.black87);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.4),
        1: FlexColumnWidth(1.6),
        2: FlexColumnWidth(1.6),
        3: FlexColumnWidth(0.7),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(0.7),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade200),
      ),
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            _cell('Table #', headerStyle),
            _cell('Room Type ID', headerStyle),
            _cell('Display Name', headerStyle),
            _cell('Cap.', headerStyle),
            _cell('Status', headerStyle),
            _cell('Active', headerStyle),
          ],
        ),
        // Data rows
        ...rows.map(
          (r) => TableRow(
            children: [
              _cell(r.tableNumber, cellStyle),
              _cell(r.roomTypeName, cellStyle),
              _cell(r.displayName, cellStyle),
              _cell(r.capacity.toString(), cellStyle),
              _cell(r.status, cellStyle),
              _cell(r.isActive ? '✓' : '✗', cellStyle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(String text, TextStyle style) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(text,
            style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
}
