import 'package:equatable/equatable.dart';

import 'cash_book_table.dart';
import 'cash_transaction_type.dart';

/// Immutable model representing a single entry in the Cash Book.
///
/// ### Cash-flow semantics
/// Both [cashIn] and [cashOut] are always non-negative values.  The direction
/// of money is determined entirely by [transactionType] (see
/// [CashTransactionTypeExtension.isCashIn]).
///
/// ### SQLite ↔ Dart mapping
/// * TEXT columns → [String] / [String?]
/// * REAL columns → [double]
/// * INTEGER columns → [int] / [int?]
/// * INTEGER boolean (0/1) → [bool]
///
/// Use [fromMap] / [toMap] to convert to/from the `sqflite` row format.
class CashBookModel extends Equatable {
  // ---------------------------------------------------------------------------
  // Primary key
  // ---------------------------------------------------------------------------

  /// Unique identifier (UUID / nano-id) for this cash-book entry.
  final String id;

  // ---------------------------------------------------------------------------
  // Business / tenant scope
  // ---------------------------------------------------------------------------

  /// The brand / outlet this entry belongs to.
  final String brandId;

  // ---------------------------------------------------------------------------
  // Transaction classification
  // ---------------------------------------------------------------------------

  /// The type of cash movement (determines cash-flow direction).
  final CashTransactionType transactionType;

  /// Voucher / reference number (e.g. "SALE-0042", "EXP-007").
  final String? referenceNo;

  // ---------------------------------------------------------------------------
  // Linked entity references (all optional)
  // ---------------------------------------------------------------------------

  /// ID of the linked sale record (populated for [CashTransactionType.cashSale]).
  final String? saleId;

  /// ID of the linked purchase record (populated for [CashTransactionType.cashPurchase]).
  final String? purchaseId;

  /// ID of the customer involved in this transaction.
  final String? customerId;

  /// Denormalized customer name for fast display without a JOIN.
  final String? customerName;

  /// ID of the supplier involved in this transaction.
  final String? supplierId;

  /// Denormalized supplier name for fast display without a JOIN.
  final String? supplierName;

  // ---------------------------------------------------------------------------
  // Financial amounts
  // ---------------------------------------------------------------------------

  /// Amount of cash received / flowing IN (≥ 0).
  final double cashIn;

  /// Amount of cash paid out / flowing OUT (≥ 0).
  final double cashOut;

  /// Running cash balance after this entry.
  final double balance;

  // ---------------------------------------------------------------------------
  // Descriptive fields
  // ---------------------------------------------------------------------------

  /// Short description shown in list views.
  final String? description;

  /// Long-form remarks or notes.
  final String? notes;

  // ---------------------------------------------------------------------------
  // Payment method
  // ---------------------------------------------------------------------------

  /// Payment method used (e.g. "Cash", "Cheque", "Bank Transfer").
  final String? paymentMethod;

  // ---------------------------------------------------------------------------
  // Timestamps
  // ---------------------------------------------------------------------------

  /// Actual date/time of the transaction (Unix epoch in milliseconds).
  final int transactionDate;

  /// Record creation timestamp (Unix epoch in milliseconds).
  final int createdAt;

  /// Record last-update timestamp (Unix epoch in milliseconds); `null` if never updated.
  final int? updatedAt;

  /// ID of the user who created this entry.
  final String? createdBy;

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  /// `true` while this record is active; `false` when soft-deleted.
  final bool isActive;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CashBookModel({
    required this.id,
    required this.brandId,
    required this.transactionType,
    this.referenceNo,
    this.saleId,
    this.purchaseId,
    this.customerId,
    this.customerName,
    this.supplierId,
    this.supplierName,
    this.cashIn = 0.0,
    this.cashOut = 0.0,
    this.balance = 0.0,
    this.description,
    this.notes,
    this.paymentMethod,
    required this.transactionDate,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.isActive = true,
  })  : assert(cashIn >= 0, 'cashIn must be non-negative'),
        assert(cashOut >= 0, 'cashOut must be non-negative');

  // ---------------------------------------------------------------------------
  // Deserialization – from sqflite row map
  // ---------------------------------------------------------------------------

  /// Creates a [CashBookModel] from a raw sqflite row [map].
  ///
  /// Throws [ArgumentError] when [CashBookTable.transactionType] contains an
  /// unrecognized string — bad data is surfaced early rather than silently
  /// defaulting to a wrong type.
  factory CashBookModel.fromMap(Map<String, dynamic> map) {
    return CashBookModel(
      id: map[CashBookTable.id] as String? ?? '',
      brandId: map[CashBookTable.brandId] as String? ?? '',
      transactionType: CashTransactionType.values
          .byName(map[CashBookTable.transactionType] as String),
      referenceNo: map[CashBookTable.referenceNo] as String?,
      saleId: map[CashBookTable.saleId] as String?,
      purchaseId: map[CashBookTable.purchaseId] as String?,
      customerId: map[CashBookTable.customerId] as String?,
      customerName: map[CashBookTable.customerName] as String?,
      supplierId: map[CashBookTable.supplierId] as String?,
      supplierName: map[CashBookTable.supplierName] as String?,
      cashIn: (map[CashBookTable.cashIn] as num?)?.toDouble() ?? 0.0,
      cashOut: (map[CashBookTable.cashOut] as num?)?.toDouble() ?? 0.0,
      balance: (map[CashBookTable.balance] as num?)?.toDouble() ?? 0.0,
      description: map[CashBookTable.description] as String?,
      notes: map[CashBookTable.notes] as String?,
      paymentMethod: map[CashBookTable.paymentMethod] as String?,
      transactionDate: map[CashBookTable.transactionDate] as int? ?? 0,
      createdAt: map[CashBookTable.createdAt] as int? ?? 0,
      updatedAt: map[CashBookTable.updatedAt] as int?,
      createdBy: map[CashBookTable.createdBy] as String?,
      isActive: (map[CashBookTable.isActive] as int? ?? 1) == 1,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization – to sqflite row map
  // ---------------------------------------------------------------------------

  /// Converts this model into a [Map] compatible with sqflite's insert/update APIs.
  Map<String, dynamic> toMap() => {
        CashBookTable.id: id,
        CashBookTable.brandId: brandId,
        CashBookTable.transactionType: transactionType.value,
        CashBookTable.referenceNo: referenceNo,
        CashBookTable.saleId: saleId,
        CashBookTable.purchaseId: purchaseId,
        CashBookTable.customerId: customerId,
        CashBookTable.customerName: customerName,
        CashBookTable.supplierId: supplierId,
        CashBookTable.supplierName: supplierName,
        CashBookTable.cashIn: cashIn,
        CashBookTable.cashOut: cashOut,
        CashBookTable.balance: balance,
        CashBookTable.description: description,
        CashBookTable.notes: notes,
        CashBookTable.paymentMethod: paymentMethod,
        CashBookTable.transactionDate: transactionDate,
        CashBookTable.createdAt: createdAt,
        CashBookTable.updatedAt: updatedAt,
        CashBookTable.createdBy: createdBy,
        CashBookTable.isActive: isActive ? 1 : 0,
      };

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a new [CashBookModel] with the specified fields replaced.
  CashBookModel copyWith({
    String? id,
    String? brandId,
    CashTransactionType? transactionType,
    String? referenceNo,
    String? saleId,
    String? purchaseId,
    String? customerId,
    String? customerName,
    String? supplierId,
    String? supplierName,
    double? cashIn,
    double? cashOut,
    double? balance,
    String? description,
    String? notes,
    String? paymentMethod,
    int? transactionDate,
    int? createdAt,
    int? updatedAt,
    String? createdBy,
    bool? isActive,
  }) {
    return CashBookModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      transactionType: transactionType ?? this.transactionType,
      referenceNo: referenceNo ?? this.referenceNo,
      saleId: saleId ?? this.saleId,
      purchaseId: purchaseId ?? this.purchaseId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      cashIn: cashIn ?? this.cashIn,
      cashOut: cashOut ?? this.cashOut,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }

  // ---------------------------------------------------------------------------
  // Derived / computed getters
  // ---------------------------------------------------------------------------

  /// Net effect of this entry on the cash balance.
  /// Positive = cash in, negative = cash out.
  double get netAmount => cashIn - cashOut;

  /// `true` when this entry increases the cash balance.
  bool get isCashIn => transactionType.isCashIn;

  /// `true` when this entry decreases the cash balance.
  bool get isCashOut => transactionType.isCashOut;

  /// The amount that matters for this entry's direction.
  /// Returns [cashIn] for in-flow types and [cashOut] for out-flow types.
  double get amount => isCashIn ? cashIn : cashOut;

  /// The transaction date as a [DateTime] (local time).
  DateTime get transactionDateTime =>
      DateTime.fromMillisecondsSinceEpoch(transactionDate);

  // ---------------------------------------------------------------------------
  // Equatable
  // ---------------------------------------------------------------------------

  @override
  List<Object?> get props => [
        id,
        brandId,
        transactionType,
        referenceNo,
        cashIn,
        cashOut,
        balance,
        transactionDate,
        isActive,
      ];

  // ---------------------------------------------------------------------------
  // Debug
  // ---------------------------------------------------------------------------

  @override
  String toString() =>
      'CashBookModel(id: $id, type: ${transactionType.label}, '
      'in: $cashIn, out: $cashOut, balance: $balance, '
      'date: $transactionDateTime)';
}
