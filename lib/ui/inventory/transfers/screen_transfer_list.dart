import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/inventory/stock_transfer_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_transfer.dart';
import 'state_transfer.dart';
import 'package:intl/intl.dart';

class ScreenTransferList extends StatelessWidget {
  final String brandId;
  const ScreenTransferList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitTransfer(
        transferRepository: StockTransferRepositoryMockImpl(),
        warehouseRepository: WarehouseRepositoryMockImpl(),
        itemRepository: ItemRepositoryMockImpl(),
      )..loadTransfers(brandId),
      child: _TransferListView(brandId: brandId),
    );
  }
}

class _TransferListView extends StatelessWidget {
  final String brandId;
  const _TransferListView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Transfers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CubitTransfer>().loadTransfers(brandId),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/$brandId/inventory/transfers/create'),
            icon: const Icon(Icons.compare_arrows, size: 18),
            label: const Text('New Transfer'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitTransfer, StateTransfer>(
        listener: (context, state) {
          if (state.status == TransferStatus.success) {
            context.read<CubitTransfer>().loadTransfers(brandId);
          }
          if (state.status == TransferStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == TransferStatus.loading && state.transfers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TransferStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load stock transfers',
              subtitle: state.errorMessage,
              actionLabel: 'Retry',
              onAction: () => context.read<CubitTransfer>().loadTransfers(brandId),
            );
          }

          if (state.transfers.isEmpty) {
            return AppEmptyState(
              icon: Icons.compare_arrows_outlined,
              title: 'No transfers recorded',
              subtitle: 'Move stock between warehouses or kitchen stores here.',
              actionLabel: 'Create Transfer',
              onAction: () => context.push('/brands/$brandId/inventory/transfers/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<CubitTransfer>().loadTransfers(brandId),
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.transfers.length,
              itemBuilder: (context, index) {
                final trans = state.transfers[index];
                final dateStr = DateFormat('dd MMM yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(trans.transferDate),
                );

                return Card(
                  margin: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.primaryContainer,
                          child: Icon(Icons.compare_arrows, color: cs.onPrimaryContainer),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                trans.referenceNo,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              dateStr,
                              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    trans.fromWarehouseName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_right_alt, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    trans.toWarehouseName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              if (trans.notes != null)
                                Text(
                                  'Notes: ${trans.notes}',
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Expand items transferred
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          children: trans.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 14, color: cs.outline),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(item.itemName)),
                                  Text(
                                    '${item.quantity.toStringAsFixed(1)} ${item.unitCode ?? ""}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
