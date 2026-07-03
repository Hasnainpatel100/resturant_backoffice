import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/inventory/purchase_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/supplier_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_purchase.dart';
import 'state_purchase.dart';
import 'package:intl/intl.dart';

class ScreenPurchaseList extends StatelessWidget {
  final String brandId;
  const ScreenPurchaseList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitPurchase(
        purchaseRepository: PurchaseRepositoryMockImpl(),
        supplierRepository: SupplierRepositoryMockImpl(),
        warehouseRepository: WarehouseRepositoryMockImpl(),
        itemRepository: ItemRepositoryMockImpl(),
      )..loadPurchases(brandId),
      child: _PurchaseListView(brandId: brandId),
    );
  }
}

class _PurchaseListView extends StatefulWidget {
  final String brandId;
  const _PurchaseListView({required this.brandId});

  @override
  State<_PurchaseListView> createState() => _PurchaseListViewState();
}

class _PurchaseListViewState extends State<_PurchaseListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<CubitPurchase>().loadPurchases(widget.brandId, search: query);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock In / Purchases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CubitPurchase>().loadPurchases(widget.brandId),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/purchases/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Stock In'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitPurchase, StatePurchase>(
        listener: (context, state) {
          if (state.status == PurchaseStatus.success) {
            context.read<CubitPurchase>().loadPurchases(widget.brandId);
          }
          if (state.status == PurchaseStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PurchaseStatus.loading && state.purchases.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AppSearchField(
                  controller: _searchController,
                  hint: 'Search by reference number, supplier, warehouse...',
                  onChanged: _onSearch,
                ),
              ),

              Expanded(
                child: state.status == PurchaseStatus.error
                    ? AppEmptyState(
                        icon: Icons.error_outline,
                        title: 'Failed to load purchase records',
                        subtitle: state.errorMessage,
                        actionLabel: 'Retry',
                        onAction: () => context.read<CubitPurchase>().loadPurchases(widget.brandId),
                      )
                    : state.purchases.isEmpty
                        ? AppEmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No purchase records found',
                            subtitle: _searchController.text.isNotEmpty
                                ? 'No results for "${_searchController.text}"'
                                : 'Record stock-in bills to update item quantities.',
                            actionLabel: _searchController.text.isEmpty ? 'Record Stock-In' : null,
                            onAction: _searchController.text.isEmpty
                                ? () => context.push('/brands/${widget.brandId}/inventory/purchases/create')
                                : null,
                          )
                        : RefreshIndicator(
                            onRefresh: () async => context.read<CubitPurchase>().loadPurchases(widget.brandId),
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              itemCount: state.purchases.length,
                              itemBuilder: (context, index) {
                                final purchase = state.purchases[index];
                                final dateStr = DateFormat('dd MMM yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(purchase.purchaseDate),
                                );
                                return Card(
                                  margin: EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: ListTile(
                                    onTap: () => context.push(
                                      '/brands/${widget.brandId}/inventory/purchases/${purchase.id}',
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: cs.primaryContainer,
                                      child: Icon(Icons.download_rounded, color: cs.onPrimaryContainer, size: 20),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            purchase.referenceNo,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          '₹${purchase.totalAmount.toStringAsFixed(2)}',
                                          style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Supplier: ${purchase.supplierName}'),
                                                Text('Warehouse: ${purchase.warehouseName} • $dateStr'),
                                              ],
                                            ),
                                          ),
                                          _PaymentBadge(status: purchase.paymentStatus),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: col.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: col.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
