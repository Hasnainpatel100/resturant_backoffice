enum InventoryStatus {
  draft,
  submitted,
  posted,
  received,
  cancelled,
}

extension InventoryStatusExtension on InventoryStatus {
  String get name {
    switch (this) {
      case InventoryStatus.draft:
        return 'draft';
      case InventoryStatus.submitted:
        return 'submitted';
      case InventoryStatus.posted:
        return 'posted';
      case InventoryStatus.received:
        return 'received';
      case InventoryStatus.cancelled:
        return 'cancelled';
    }
  }

  static InventoryStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'submitted':
        return InventoryStatus.submitted;
      case 'posted':
        return InventoryStatus.posted;
      case 'received':
        return InventoryStatus.received;
      case 'cancelled':
        return InventoryStatus.cancelled;
      case 'draft':
      default:
        return InventoryStatus.draft;
    }
  }
}

class InventoryCalculations {
  static String generateDocumentNo(String prefix) {
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Calculates tax and total for an item row.
  /// Returns a map with 'taxAmount' and 'lineTotal'.
  static Map<String, double> calculateLineTotals({
    required double qty,
    required double rate,
    required double taxValue, // e.g. 5.0 for 5%
    required bool includeInRate,
  }) {
    final lineAmount = qty * rate;
    double taxAmount = 0.0;
    double lineTotal = lineAmount;

    if (taxValue > 0) {
      if (includeInRate) {
        taxAmount = lineAmount * taxValue / (100 + taxValue);
        lineTotal = lineAmount;
      } else {
        taxAmount = lineAmount * taxValue / 100;
        lineTotal = lineAmount + taxAmount;
      }
    }

    return {
      'taxAmount': taxAmount,
      'lineTotal': lineTotal,
    };
  }
}
