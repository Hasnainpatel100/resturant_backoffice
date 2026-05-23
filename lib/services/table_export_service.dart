import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// Platform-conditional imports for downloading bytes
import 'table_export_service_stub.dart'
if (dart.library.html) 'table_export_service_web.dart'
as platform_download;

// ---------------------------------------------------------------------------
// TableExportService
// ---------------------------------------------------------------------------
//
// Generates a well-formatted Excel template that matches the importable
// TableModel columns and triggers a download appropriate for the platform.
//
// Filename pattern:  table_import_format_YYYYMMDD.xlsx
// ---------------------------------------------------------------------------

class TableExportService {
  static const _templateColumns = [
    'tableNumber',
    'roomTypeId',
    'displayName',
    'capacity',
    'description',
    'status',
    'isActive',
    'positionX',
    'positionY',
  ];

  static const _sampleRow = [
    'T1',
    'ROOM001',
    'Window Table',
    '4',
    'Near entrance',
    'available',
    'true',
    '120',
    '240',
  ];

  static const _instructionLines = [
    'IMPORT INSTRUCTIONS',
    '',
    'Required columns:  tableNumber, roomTypeId, capacity',
    'Optional columns:  displayName, description, status, isActive, positionX, positionY',
    '',
    'Status allowed values:  available | occupied | reserved | blocked',
    'isActive values:         true | false   (default: true)',
    '',
    'Do NOT include system-managed fields:',
    '  id, brandId, branchId, currentOrderId, createdAt, createdBy, updatedAt, updatedBy',
    '',
    'Save the file as .xlsx, .xls, or .csv before uploading.',
  ];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Builds the Excel template and downloads it.
  /// Returns `true` on success, `false` if download failed.
  Future<bool> downloadTemplate() async {
    try {
      final bytes = _buildExcel();
      final filename =
          'table_import_format_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
      await platform_download.downloadBytes(bytes, filename);
      return true;
    } catch (e) {
      debugPrint('[TableExportService] download error: $e');
      return false;
    }
  }

  // ── Builder ────────────────────────────────────────────────────────────────

  Uint8List _buildExcel() {
    final excel = Excel.createExcel();

    // ── Sheet 1 : Template ──────────────────────────────────────────────────
    final templateSheet = excel['Template'];
    excel.setDefaultSheet('Template');

    // Bold header style
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#1F3864'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    // Write headers
    for (var col = 0; col < _templateColumns.length; col++) {
      final cell = templateSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(_templateColumns[col]);
      cell.cellStyle = headerStyle;
      templateSheet.setColumnWidth(col, 20);
    }

    // Write sample row
    final sampleStyle = CellStyle(
      italic: true,
      fontColorHex: ExcelColor.fromHexString('#555555'),
    );
    for (var col = 0; col < _sampleRow.length; col++) {
      final cell = templateSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1));
      cell.value = TextCellValue(_sampleRow[col]);
      cell.cellStyle = sampleStyle;
    }

    // ── Sheet 2 : Instructions ──────────────────────────────────────────────
    final instrSheet = excel['Instructions'];

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#1F3864'),
    );
    final bodyStyle = CellStyle(fontSize: 11);

    for (var i = 0; i < _instructionLines.length; i++) {
      final cell = instrSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      cell.value = TextCellValue(_instructionLines[i]);
      cell.cellStyle = i == 0 ? titleStyle : bodyStyle;
    }
    instrSheet.setColumnWidth(0, 70);

    // Remove the default "Sheet1" created by the excel package
    excel.delete('Sheet1');

    final encoded = excel.encode();
    if (encoded == null) throw Exception('Excel encoding returned null');
    return Uint8List.fromList(encoded);
  }
}












