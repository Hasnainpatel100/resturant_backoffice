import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/supplier_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/purchase_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_supplier.dart';
import 'state_supplier.dart';
import 'package:intl/intl.dart';

class ScreenSupplierLedger extends StatelessWidget {
  final String brandId;
  final String supplierId;

  const ScreenSupplierLedger({
    super.key,
    required this.brandId,
    required this.supplierId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitSupplier(repository: SupplierRepositoryMockImpl())
        ..loadSupplier(brandId, supplierId),
      child: _SupplierLedgerView(brandId: brandId, supplierId: supplierId),
    );
  }
}

class _SupplierLedgerView extends StatefulWidget {
  final String brandId;
  final String supplierId;

  const _SupplierLedgerView({required this.brandId, required this.supplierId});

  @override
  State<_SupplierLedgerView> createState() => _SupplierLedgerViewState();
}

class _SupplierLedgerViewState extends State<_SupplierLedgerView> {
  // Let's load the purchases associated with this supplier to render transaction history
  final _purchaseRepo = PurchaseRepositoryMockImpl();
  List<dynamic> _transactions = [];
  bool _loadingTx = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final response = await _purchaseRepo.getPurchases(widget.brandId);
    response.fold(
      (_) => setState(() => _loadingTx = false),
      (listRes) {
        // filter purchases for this supplier
        final supsPurchases = listRes.items.where((p) => p.supplierId == widget.supplierId).toList();
        setState(() {
          _transactions = supsPurchases;
          _loadingTx = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Ledger'),
      ),
      body: BlocBuilder<CubitSupplier, StateSupplier>(
        builder: (context, state) {
          if (state.status == SupplierStatus.loading || _loadingTx) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.selected == null) {
            return AppEmptyState(
              icon: Icons.people_outline,
              title: 'Supplier profile not found',
              actionLabel: 'Go Back',
              onAction: () => context.pop(),
            );
          }

          final supplier = state.selected!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Supplier Summary Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (supplier.contactPerson != null) ...[
                          const SizedBox(height: 4),
                          Text('Contact: ${supplier.contactPerson}', style: tt.bodyMedium),
                        ],
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _BalanceBox(
                                label: 'Opening Balance',
                                val: supplier.openingBalance,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _BalanceBox(
                                label: 'Current Balance Due',
                                val: supplier.currentBalance,
                                color: cs.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // ── Transaction List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Purchase Transactions',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.history, color: cs.outline),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),

                if (_transactions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No purchases recorded from this supplier yet.',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      final dateStr = DateFormat('dd MMM yyyy').format(
                        DateTime.fromMillisecondsSinceEpoch(tx.purchaseDate),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.receipt_long, color: cs.onPrimaryContainer, size: 18),
                          ),
                          title: Text(
                            tx.referenceNo,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('Date: $dateStr • Wh: ${tx.warehouseName}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${tx.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tx.paymentStatus,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: tx.paymentStatus == 'Paid'
                                      ? Colors.green
                                      : tx.paymentStatus == 'Partial'
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalanceBox extends StatelessWidget {
  final String label;
  final double val;
  final Color color;

  const _BalanceBox({required this.label, required this.val, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            '₹${val.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
