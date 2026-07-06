/// SQLite table definition for the [cash_book] table.
///
/// Import this class wherever you need to reference the table name or any
/// column name as a compile-time constant to avoid magic strings.
///
/// Usage (in a datasource):
/// ```dart
/// await db.insert(CashBookTable.tableName, data);
/// await db.query(CashBookTable.tableName, where: '${CashBookTable.id} = ?');
/// ```
abstract final class CashBookTable {
  // ---------------------------------------------------------------------------
  // Table name
  // ---------------------------------------------------------------------------

  /// The SQLite table name.
  static const String tableName = 'cash_book';

  // ---------------------------------------------------------------------------
  // Primary key
  // ---------------------------------------------------------------------------

  /// Unique identifier for each cash-book entry (TEXT UUID / nano-id).
  static const String id = 'id';

  // ---------------------------------------------------------------------------
  // Business / tenant scope
  // ---------------------------------------------------------------------------

  /// The brand / outlet this entry belongs to.
  static const String brandId = 'brand_id';

  // ---------------------------------------------------------------------------
  // Transaction classification
  // ---------------------------------------------------------------------------

  /// The type of cash movement; maps to [CashTransactionType.value].
  /// Stored as TEXT, never NULL.
  static const String transactionType = 'transaction_type';

  /// Human-readable reference / voucher number (e.g. "SALE-0042", "EXP-007").
  static const String referenceNo = 'reference_no';

  // ---------------------------------------------------------------------------
  // Linked entity references (all optional)
  // ---------------------------------------------------------------------------

  /// ID of the sale record when [transactionType] is [cashSale].
  static const String saleId = 'sale_id';

  /// ID of the purchase record when [transactionType] is [cashPurchase].
  static const String purchaseId = 'purchase_id';

  /// ID of the customer involved (for [cashSale] / [customerPayment]).
  static const String customerId = 'customer_id';

  /// Denormalized customer name for fast display without a JOIN.
  static const String customerName = 'customer_name';

  /// ID of the supplier involved (for [cashPurchase] / [supplierPayment]).
  static const String supplierId = 'supplier_id';

  /// Denormalized supplier name for fast display without a JOIN.
  static const String supplierName = 'supplier_name';

  // ---------------------------------------------------------------------------
  // Financial amounts
  // ---------------------------------------------------------------------------

  /// Cash amount flowing INTO the till for this entry (≥ 0).
  static const String cashIn = 'cash_in';

  /// Cash amount flowing OUT OF the till for this entry (≥ 0).
  static const String cashOut = 'cash_out';

  /// Running cash balance after this entry is applied.
  /// Maintained by the data-access layer on every insert / update.
  static const String balance = 'balance';

  // ---------------------------------------------------------------------------
  // Descriptive fields
  // ---------------------------------------------------------------------------

  /// Short free-text description shown in listings.
  static const String description = 'description';

  /// Additional long-form notes or remarks.
  static const String notes = 'notes';

  // ---------------------------------------------------------------------------
  // Payment method
  // ---------------------------------------------------------------------------

  /// The payment method used (e.g. "Cash", "Cheque", "Bank Transfer").
  static const String paymentMethod = 'payment_method';

  // ---------------------------------------------------------------------------
  // Timestamps
  // ---------------------------------------------------------------------------

  /// The date/time of the actual transaction as a Unix epoch in milliseconds.
  static const String transactionDate = 'transaction_date';

  /// Record creation timestamp as a Unix epoch in milliseconds.
  static const String createdAt = 'created_at';

  /// Record last-update timestamp as a Unix epoch in milliseconds (nullable).
  static const String updatedAt = 'updated_at';

  /// ID of the user who created this entry.
  static const String createdBy = 'created_by';

  // ---------------------------------------------------------------------------
  // Soft-delete / status
  // ---------------------------------------------------------------------------

  /// Whether this entry is active (1) or soft-deleted (0).
  static const String isActive = 'is_active';

  // ---------------------------------------------------------------------------
  // DDL
  // ---------------------------------------------------------------------------

  /// The `CREATE TABLE` SQL statement.
  ///
  /// Call this inside your [DatabaseHelper.onCreate] callback.
  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $id               TEXT    NOT NULL PRIMARY KEY,
      $brandId          TEXT    NOT NULL,
      $transactionType  TEXT    NOT NULL,
      $referenceNo      TEXT,
      $saleId           TEXT,
      $purchaseId       TEXT,
      $customerId       TEXT,
      $customerName     TEXT,
      $supplierId       TEXT,
      $supplierName     TEXT,
      $cashIn           REAL    NOT NULL DEFAULT 0.0,
      $cashOut          REAL    NOT NULL DEFAULT 0.0,
      $balance          REAL    NOT NULL DEFAULT 0.0,
      $description      TEXT,
      $notes            TEXT,
      $paymentMethod    TEXT,
      $transactionDate  INTEGER NOT NULL,
      $createdAt        INTEGER NOT NULL,
      $updatedAt        INTEGER,
      $createdBy        TEXT,
      $isActive         INTEGER NOT NULL DEFAULT 1
    );
  ''';

  /// Index on [brandId] + [transactionDate] for date-range queries scoped to a brand.
  static const String createIndexSql = '''
    CREATE INDEX IF NOT EXISTS idx_cash_book_brand_date
      ON $tableName ($brandId, $transactionDate);
  ''';
}
