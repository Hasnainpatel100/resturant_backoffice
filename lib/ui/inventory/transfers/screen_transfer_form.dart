import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/stock_transfer_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_transfer.dart';
import 'state_transfer.dart';

class ScreenTransferForm extends StatelessWidget {
  final String brandId;

  const ScreenTransferForm({
    super.key,
    required this.brandId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitTransfer(
        transferRepository: StockTransferRepositoryMockImpl(),
        warehouseRepository: WarehouseRepositoryMockImpl(),
        itemRepository: ItemRepositoryMockImpl(),
      )..loadFormDropdowns(brandId),
      child: _TransferFormView(brandId: brandId),
    );
  }
}

class _TransferFormView extends StatefulWidget {
  final String brandId;
  const _TransferFormView({required this.brandId});

  @override
  State<_TransferFormView> createState() => _TransferFormViewState();
}

class _TransferFormViewState extends State<_TransferFormView> {
  final _formKey = GlobalKey<FormState>();

  final _refController = TextEditingController();
  final _notesController = TextEditingController();

  WarehouseModel? _fromWarehouse;
  WarehouseModel? _toWarehouse;

  // Dynamic list of items to transfer
  final List<_TransferItemInput> _itemsList = [];

  @override
  void dispose() {
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _itemsList.add(_TransferItemInput(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        qtyController: TextEditingController(text: '1.0'),
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemsList[index].qtyController.dispose();
      _itemsList.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_fromWarehouse == null || _toWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both Source and Destination warehouses')),
      );
      return;
    }
    if (_fromWarehouse!.id == _toWarehouse!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and Destination warehouse cannot be the same')),
      );
      return;
    }
    if (_itemsList.isEmpty || _itemsList.any((i) => i.item == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one valid item')),
      );
      return;
    }

    final itemsData = _itemsList.map((i) {
      return {
        'itemId': i.item!.id,
        'itemName': i.item!.name,
        'unitCode': i.item!.unitCode,
        'quantity': double.tryParse(i.qtyController.text) ?? 0.0,
      };
    }).toList();

    final data = {
      'referenceNo': _refController.text.trim().isEmpty ? null : _refController.text.trim(),
      'fromWarehouseId': _fromWarehouse!.id,
      'fromWarehouseName': _fromWarehouse!.name,
      'toWarehouseId': _toWarehouse!.id,
      'toWarehouseName': _toWarehouse!.name,
      'items': itemsData,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'transferDate': DateTime.now().millisecondsSinceEpoch,
    };

    context.read<CubitTransfer>().createTransfer(widget.brandId, data);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<CubitTransfer, StateTransfer>(
      listener: (context, state) {
        if (state.status == TransferStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock transfer recorded'), backgroundColor: Colors.green),
          );
          context.pop();
        }
        if (state.status == TransferStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred'), backgroundColor: cs.error),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == TransferStatus.loading;

        if (state.status == TransferStatus.loading && state.items.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Record Stock Transfer'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Details
                  Text('Transfer Details', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
                  const Divider(),
                  SizedBox(height: AppSpacing.sm),

                  AppTextField(
                    label: 'Reference Code (Auto Generated)',
                    hint: 'e.g. TR-2026-001',
                    controller: _refController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<WarehouseModel>(
                          label: 'Source Warehouse *',
                          hint: 'Select source',
                          value: _fromWarehouse,
                          expands: true,
                          items: state.warehouses
                              .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _fromWarehouse = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_right_alt, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppDropdownField<WarehouseModel>(
                          label: 'Destination Warehouse *',
                          hint: 'Select destination',
                          value: _toWarehouse,
                          expands: true,
                          items: state.warehouses
                              .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _toWarehouse = v),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // ── Transfer Items List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items to Transfer', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.secondary)),
                      FilledButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Item'),
                        style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                      ),
                    ],
                  ),
                  const Divider(),
                  SizedBox(height: AppSpacing.sm),

                  if (_itemsList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No items added. Click "Add Item" to add products.',
                          style: TextStyle(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _itemsList.length,
                      itemBuilder: (context, idx) {
                        final input = _itemsList[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: cs.surfaceContainerLowest,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppDropdownField<ItemModel>(
                                        label: 'Select Item',
                                        value: input.item,
                                        expands: true,
                                        items: state.items
                                            .map((item) => DropdownMenuItem(
                                                value: item,
                                                child: Text('${item.name} (${item.sku ?? "No SKU"})')))
                                            .toList(),
                                        onChanged: (item) => setState(() => input.item = item),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _removeItem(idx),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AppTextField(
                                  label: 'Transfer Qty ${input.item?.unitCode != null ? "(${input.item!.unitCode})" : ""} *',
                                  controller: input.qtyController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Required';
                                    final val = double.tryParse(v);
                                    if (val == null || val <= 0) return 'Must be greater than 0';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  SizedBox(height: AppSpacing.md),

                  // Notes
                  AppTextField(
                    label: 'Transfer Notes / Remarks',
                    hint: 'Describe reason for transfer or add details',
                    controller: _notesController,
                    maxLines: 3,
                    minLines: 2,
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Record Stock Transfer', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TransferItemInput {
  final String id;
  ItemModel? item;
  final TextEditingController qtyController;

  _TransferItemInput({
    required this.id,
    this.item,
    required this.qtyController,
  });
}
