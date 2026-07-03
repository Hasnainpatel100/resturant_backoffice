import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/models/inventory/supplier_model.dart';
import 'package:back_office/data/repositories/inventory/supplier_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_supplier.dart';
import 'state_supplier.dart';

class ScreenSupplierList extends StatelessWidget {
  final String brandId;
  const ScreenSupplierList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitSupplier(repository: SupplierRepositoryMockImpl())
        ..loadSuppliers(brandId),
      child: _SupplierListView(brandId: brandId),
    );
  }
}

class _SupplierListView extends StatefulWidget {
  final String brandId;
  const _SupplierListView({required this.brandId});

  @override
  State<_SupplierListView> createState() => _SupplierListViewState();
}

class _SupplierListViewState extends State<_SupplierListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<CubitSupplier>().loadSuppliers(widget.brandId, search: query);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers / Vendors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<CubitSupplier>().loadSuppliers(widget.brandId),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/suppliers/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Supplier'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitSupplier, StateSupplier>(
        listener: (context, state) {
          if (state.status == SupplierStatus.success) {
            context.read<CubitSupplier>().loadSuppliers(widget.brandId);
          }
          if (state.status == SupplierStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SupplierStatus.loading && state.suppliers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AppSearchField(
                  controller: _searchController,
                  hint: 'Search suppliers by name, contact, phone...',
                  onChanged: _onSearch,
                ),
              ),

              Expanded(
                child: state.status == SupplierStatus.error
                    ? AppEmptyState(
                        icon: Icons.error_outline,
                        title: 'Failed to load suppliers',
                        subtitle: state.errorMessage,
                        actionLabel: 'Retry',
                        onAction: () => context.read<CubitSupplier>().loadSuppliers(widget.brandId),
                      )
                    : state.suppliers.isEmpty
                        ? AppEmptyState(
                            icon: Icons.people_outline,
                            title: 'No suppliers found',
                            subtitle: _searchController.text.isNotEmpty
                                ? 'No results for "${_searchController.text}"'
                                : 'Add your first supplier or vendor to purchase stock.',
                            actionLabel: _searchController.text.isEmpty ? 'Add Supplier' : null,
                            onAction: _searchController.text.isEmpty
                                ? () => context.push('/brands/${widget.brandId}/inventory/suppliers/create')
                                : null,
                          )
                        : RefreshIndicator(
                            onRefresh: () async => context.read<CubitSupplier>().loadSuppliers(widget.brandId),
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              itemCount: state.suppliers.length,
                              itemBuilder: (context, index) {
                                final supplier = state.suppliers[index];
                                return _SupplierCard(
                                  supplier: supplier,
                                  onLedger: () => context.push(
                                    '/brands/${widget.brandId}/inventory/suppliers/${supplier.id}/ledger',
                                  ),
                                  onEdit: () => context.push(
                                    '/brands/${widget.brandId}/inventory/suppliers/${supplier.id}/edit',
                                  ),
                                  onDelete: () => _confirmDelete(context, supplier),
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

  void _confirmDelete(BuildContext context, SupplierModel supplier) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Supplier?'),
        content: Text(
          'Are you sure you want to delete "${supplier.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<CubitSupplier>().deleteSupplier(widget.brandId, supplier.id);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final VoidCallback onLedger;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onLedger,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 3,
            color: supplier.isActive ? Colors.green : Colors.grey,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Text(
                supplier.name.substring(0, 1).toUpperCase(),
                style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    supplier.name,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: supplier.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: supplier.isActive ? Colors.green.withOpacity(0.4) : Colors.grey.withOpacity(0.4)),
                  ),
                  child: Text(
                    supplier.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: supplier.isActive ? Colors.green : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (supplier.contactPerson != null)
                  Text('Contact: ${supplier.contactPerson}', style: tt.bodyMedium),
                if (supplier.phone != null)
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(supplier.phone!, style: tt.bodySmall),
                    ],
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Payable: ₹${supplier.currentBalance.toStringAsFixed(2)}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: cs.outline),
              onSelected: (v) {
                if (v == 'ledger') onLedger();
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'ledger',
                  child: ListTile(
                    leading: Icon(Icons.receipt_long_outlined),
                    title: Text('Ledger'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Delete', style: TextStyle(color: Colors.red)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
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
