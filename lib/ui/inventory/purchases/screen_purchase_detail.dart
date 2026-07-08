import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/purchase_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/supplier_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_purchase.dart';
import 'state_purchase.dart';
import 'package:intl/intl.dart';

class ScreenPurchaseDetail extends StatelessWidget {
  final String brandId;
  final String purchaseId;

  const ScreenPurchaseDetail({
    super.key,
    required this.brandId,
    required this.purchaseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitPurchase(
        purchaseRepository: PurchaseRepositoryMockImpl(),
        supplierRepository: SupplierRepositoryMockImpl(),
        warehouseRepository: WarehouseRepositoryMockImpl(),
        itemRepository: ItemRepositoryMockImpl(),
      )..loadPurchase(brandId, purchaseId),
      child: _PurchaseDetailView(brandId: brandId),
    );
  }
}

class _PurchaseDetailView extends StatelessWidget {
  final String brandId;

  const _PurchaseDetailView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Stock-In Details'),
      ),
      body: BlocBuilder<CubitPurchase, StatePurchase>(
        builder: (context, state) {
          if (state.status == PurchaseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.selected == null) {
            return AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Purchase record not found',
              actionLabel: 'Go Back',
              onAction: () => context.pop(),
            );
          }

          final p = state.selected!;
          final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(
            DateTime.fromMillisecondsSinceEpoch(p.purchaseDate),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info Header Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.referenceNo,
                              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            _PaymentBadge(status: p.paymentStatus),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Recorded on: $dateStr', style: TextStyle(color: cs.onSurfaceVariant)),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Supplier', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                  const SizedBox(height: 2),
                                  Text(p.supplierName, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Stored In', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                  const SizedBox(height: 2),
                                  Text(p.warehouseName, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // ── Items List Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Received Items', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
                        const Divider(),
                        const SizedBox(height: 8),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: p.items.length,
                          separatorBuilder: (_, __) => const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final item = p.items[index];
                            return Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.inventory_2_outlined, color: cs.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemName,
                                        style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.quantity.toStringAsFixed(1)} ${item.unitCode ?? ""} @ ₹${item.costPrice.toStringAsFixed(2)}',
                                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${item.total.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // ── Summary Details Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Financial Summary', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const Divider(),
                        _SummaryRow(label: 'Sub Total', value: '₹${p.subTotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _SummaryRow(label: 'Tax / GST', value: '+ ₹${p.taxAmount.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _SummaryRow(label: 'Discount', value: '- ₹${p.discountAmount.toStringAsFixed(2)}'),
                        const Divider(height: 16),
                        _SummaryRow(
                          label: 'Grand Total',
                          value: '₹${p.totalAmount.toStringAsFixed(2)}',
                          valueStyle: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Notes
                if (p.notes != null)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Remarks / Notes', style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
                          const SizedBox(height: 6),
                          Text(p.notes!, style: tt.bodyMedium),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String status;
  const _PaymentBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color col;
    if (status == 'Paid') {
      col = Colors.green;
    } else if (status == 'Partial') {
      col = Colors.orange;
    } else {
      col = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: col.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: col.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
