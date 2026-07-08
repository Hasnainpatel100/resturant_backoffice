import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/cash_book/cash_book_model.dart';
import '../../data/models/cash_book/cash_transaction_type.dart';
import '../../shared/shared.dart';
import 'screen_cash_book_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Demo / placeholder data — replace with your actual controller / repository
// ─────────────────────────────────────────────────────────────────────────────
List<CashBookModel> _demoEntries() {
  final now = DateTime.now().millisecondsSinceEpoch;
  return [
    CashBookModel(
      id: '1',
      brandId: 'brand1',
      transactionType: CashTransactionType.cashSale,
      referenceNo: 'SALE-0042',
      customerName: 'Walk-in Customer',
      cashIn: 1500.00,
      cashOut: 0,
      balance: 8200.00,
      description: 'Table #5 cash sale',
      paymentMethod: 'Cash',
      transactionDate: now - const Duration(hours: 1).inMilliseconds,
      createdAt: now,
    ),
    CashBookModel(
      id: '2',
      brandId: 'brand1',
      transactionType: CashTransactionType.expense,
      referenceNo: 'EXP-007',
      cashIn: 0,
      cashOut: 350.00,
      balance: 6700.00,
      description: 'Electricity bill payment',
      paymentMethod: 'Cash',
      transactionDate: now - const Duration(hours: 3).inMilliseconds,
      createdAt: now,
    ),
    CashBookModel(
      id: '3',
      brandId: 'brand1',
      transactionType: CashTransactionType.supplierPayment,
      referenceNo: 'SP-0012',
      supplierName: 'Fresh Farm Suppliers',
      cashIn: 0,
      cashOut: 2400.00,
      balance: 6350.00,
      description: 'Weekly produce payment',
      paymentMethod: 'Cash',
      transactionDate: now - const Duration(hours: 5).inMilliseconds,
      createdAt: now,
    ),
    CashBookModel(
      id: '4',
      brandId: 'brand1',
      transactionType: CashTransactionType.customerPayment,
      referenceNo: 'CP-0003',
      customerName: 'Ramesh & Co.',
      cashIn: 800.00,
      cashOut: 0,
      balance: 8750.00,
      description: 'Credit settlement',
      paymentMethod: 'Cash',
      transactionDate: now - const Duration(days: 1).inMilliseconds,
      createdAt: now,
    ),
    CashBookModel(
      id: '5',
      brandId: 'brand1',
      transactionType: CashTransactionType.deposit,
      referenceNo: 'DEP-001',
      cashIn: 5000.00,
      cashOut: 0,
      balance: 7950.00,
      description: 'Opening float deposit',
      paymentMethod: 'Cash',
      transactionDate: now - const Duration(days: 1, hours: 8).inMilliseconds,
      createdAt: now,
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class ScreenCashBookList extends StatefulWidget {
  final String brandId;
  const ScreenCashBookList({super.key, required this.brandId});

  @override
  State<ScreenCashBookList> createState() => _ScreenCashBookListState();
}

class _ScreenCashBookListState extends State<ScreenCashBookList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  List<CashBookModel> _all = [];
  List<CashBookModel> _filtered = [];
  CashTransactionType? _activeFilter;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _all = _demoEntries();
    _filtered = List.from(_all);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = _all.where((e) {
        final matchType =
            _activeFilter == null || e.transactionType == _activeFilter;
        final matchSearch = q.isEmpty ||
            (e.referenceNo?.toLowerCase().contains(q) ?? false) ||
            (e.description?.toLowerCase().contains(q) ?? false) ||
            (e.customerName?.toLowerCase().contains(q) ?? false) ||
            (e.supplierName?.toLowerCase().contains(q) ?? false);
        return matchType && matchSearch;
      }).toList();
    });
  }

  void _setFilter(CashTransactionType? type) {
    setState(() => _activeFilter = type);
    _applyFilter();
  }

  double get _totalIn => _all.fold(0, (s, e) => s + e.cashIn);
  double get _totalOut => _all.fold(0, (s, e) => s + e.cashOut);
  double get _netBalance => _totalIn - _totalOut;

  Future<void> _openForm({CashBookModel? entry}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScreenCashBookForm(
          brandId: widget.brandId,
          existing: entry,
        ),
      ),
    );
    // In production: reload from controller/repository here.
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Book',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Entry'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Summary Banner ───────────────────────────────────────────
            _SummaryBanner(
              totalIn: _totalIn,
              totalOut: _totalOut,
              netBalance: _netBalance,
              formatter: fmt,
            ),

            const SizedBox(height: 2),

            // ── Search + Filters ─────────────────────────────────────────
            _SearchAndFilters(
              controller: _searchCtrl,
              activeFilter: _activeFilter,
              onFilterChanged: _setFilter,
              onSearchChanged: (_) => _applyFilter(),
            ),

            const SizedBox(height: 2),

            // ── Transaction List ─────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? _EmptyState(onAdd: () => _openForm())
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.xxl,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) => _CashEntryCard(
                        entry: _filtered[i],
                        formatter: fmt,
                        onTap: () => _openForm(entry: _filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Banner
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.totalIn,
    required this.totalOut,
    required this.netBalance,
    required this.formatter,
  });

  final double totalIn;
  final double totalOut;
  final double netBalance;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            cs.primary.withBlue((cs.primary.blue + 40).clamp(0, 255)),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _BannerStat(
              label: 'Cash In',
              value: formatter.format(totalIn),
              icon: Icons.arrow_downward_rounded,
              iconColor: Colors.greenAccent.shade400,
            ),
          ),
          Container(
              width: 1, height: 44, color: Colors.white.withOpacity(0.25)),
          Expanded(
            child: _BannerStat(
              label: 'Cash Out',
              value: formatter.format(totalOut),
              icon: Icons.arrow_upward_rounded,
              iconColor: Colors.redAccent.shade100,
            ),
          ),
          Container(
              width: 1, height: 44, color: Colors.white.withOpacity(0.25)),
          Expanded(
            child: _BannerStat(
              label: 'Net Balance',
              value: formatter.format(netBalance),
              icon: Icons.account_balance_wallet_rounded,
              iconColor: Colors.white,
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  const _BannerStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: tt.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search + Filter chips
// ─────────────────────────────────────────────────────────────────────────────
class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  final TextEditingController controller;
  final CashTransactionType? activeFilter;
  final ValueChanged<CashTransactionType?> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search by reference, description, party…',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: cs.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: activeFilter == null,
                  onSelected: (_) => onFilterChanged(null),
                ),
                ...CashTransactionType.values.map(
                  (t) => _FilterChip(
                    label: t.label,
                    selected: activeFilter == t,
                    color: t.isCashIn ? Colors.green : Colors.red,
                    onSelected: (_) => onFilterChanged(t),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = color ?? cs.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? effectiveColor : null,
        ),
        selectedColor: effectiveColor.withOpacity(0.12),
        side: selected
            ? BorderSide(color: effectiveColor, width: 1.2)
            : null,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction entry card
// ─────────────────────────────────────────────────────────────────────────────
class _CashEntryCard extends StatelessWidget {
  const _CashEntryCard({
    required this.entry,
    required this.formatter,
    required this.onTap,
  });

  final CashBookModel entry;
  final NumberFormat formatter;
  final VoidCallback onTap;

  Color _typeColor() {
    return entry.isCashIn ? Colors.green.shade600 : Colors.red.shade600;
  }

  IconData _typeIcon() {
    switch (entry.transactionType) {
      case CashTransactionType.cashSale:
        return Icons.point_of_sale_rounded;
      case CashTransactionType.cashPurchase:
        return Icons.shopping_cart_rounded;
      case CashTransactionType.customerPayment:
        return Icons.person_rounded;
      case CashTransactionType.supplierPayment:
        return Icons.local_shipping_rounded;
      case CashTransactionType.expense:
        return Icons.receipt_long_rounded;
      case CashTransactionType.deposit:
        return Icons.add_card_rounded;
      case CashTransactionType.withdrawal:
        return Icons.money_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _typeColor();
    final dateStr =
        DateFormat('dd MMM, hh:mm a').format(entry.transactionDateTime);
    final party = entry.customerName ?? entry.supplierName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant, width: 0.8),
            ),
            child: Row(
              children: [
                // ── Type icon avatar ────────────────────────────────────
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon(), color: color, size: 20),
                ),
                SizedBox(width: AppSpacing.md),

                // ── Description ─────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.transactionType.label,
                              style: tt.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (entry.referenceNo != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                entry.referenceNo!,
                                style: tt.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (party != null)
                        Text(
                          party,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else if (entry.description != null)
                        Text(
                          entry.description!,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Amount ──────────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          entry.isCashIn
                              ? Icons.add_rounded
                              : Icons.remove_rounded,
                          size: 14,
                          color: color,
                        ),
                        Text(
                          formatter.format(entry.amount),
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bal: ${formatter.format(entry.balance)}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: cs.primary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text('No transactions found',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Add your first cash entry to get started.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Entry'),
          ),
        ],
      ),
    );
  }
}
