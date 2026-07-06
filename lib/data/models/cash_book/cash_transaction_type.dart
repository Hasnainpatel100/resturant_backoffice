/// Enumerates every kind of cash movement tracked in the Cash Book.
///
/// The direction of cash flow (in / out) is implied by the type itself:
///
/// | Type              | Flow |
/// |-------------------|------|
/// | cashSale          | IN   |
/// | customerPayment   | IN   |
/// | deposit           | IN   |
/// | cashPurchase      | OUT  |
/// | supplierPayment   | OUT  |
/// | expense           | OUT  |
/// | withdrawal        | OUT  |
enum CashTransactionType {
  /// Cash received from a direct point-of-sale transaction.
  cashSale,

  /// Cash paid out for a direct purchase from a supplier.
  cashPurchase,

  /// Cash received from a customer settling a credit balance.
  customerPayment,

  /// Cash paid out to a supplier settling a payable balance.
  supplierPayment,

  /// Cash paid out for an operational or miscellaneous expense.
  expense,

  /// Cash deposited into the business (e.g. opening float, bank withdrawal).
  deposit,

  /// Cash withdrawn from the till or business (e.g. to bank, owner draw).
  withdrawal,
}

/// Convenience helpers for [CashTransactionType].
extension CashTransactionTypeExtension on CashTransactionType {
  // ---------------------------------------------------------------------------
  // String serialization
  // ---------------------------------------------------------------------------

  /// Returns the canonical string representation stored in the database.
  ///
  /// Uses [Enum.name] so the value always matches the enum identifier exactly.
  ///
  /// Example:
  /// ```dart
  /// CashTransactionType.cashSale.value // → 'cashSale'
  /// ```
  String get value => name;

  // ---------------------------------------------------------------------------
  // String deserialization
  // ---------------------------------------------------------------------------

  /// Parses [value] back into a [CashTransactionType].
  ///
  /// Throws [ArgumentError] when [value] does not match any enum name, which
  /// mirrors the behaviour of [Enum.values.byName] and makes bad data visible
  /// at the data-access layer rather than silently returning a default.
  ///
  /// Example:
  /// ```dart
  /// CashTransactionType.cashSale.fromValue('expense')
  ///   // → CashTransactionType.expense
  /// ```
  CashTransactionType fromValue(String value) =>
      CashTransactionType.values.byName(value);

  // ---------------------------------------------------------------------------
  // Display label
  // ---------------------------------------------------------------------------

  /// Human-readable label suitable for UI display.
  String get label {
    switch (this) {
      case CashTransactionType.cashSale:
        return 'Cash Sale';
      case CashTransactionType.cashPurchase:
        return 'Cash Purchase';
      case CashTransactionType.customerPayment:
        return 'Customer Payment';
      case CashTransactionType.supplierPayment:
        return 'Supplier Payment';
      case CashTransactionType.expense:
        return 'Expense';
      case CashTransactionType.deposit:
        return 'Deposit';
      case CashTransactionType.withdrawal:
        return 'Withdrawal';
    }
  }

  // ---------------------------------------------------------------------------
  // Cash-flow direction helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` when this transaction type increases the cash balance.
  bool get isCashIn {
    switch (this) {
      case CashTransactionType.cashSale:
      case CashTransactionType.customerPayment:
      case CashTransactionType.deposit:
        return true;
      case CashTransactionType.cashPurchase:
      case CashTransactionType.supplierPayment:
      case CashTransactionType.expense:
      case CashTransactionType.withdrawal:
        return false;
    }
  }

  /// Returns `true` when this transaction type decreases the cash balance.
  bool get isCashOut => !isCashIn;
}
