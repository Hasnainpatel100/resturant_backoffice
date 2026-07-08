import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/stock_adjustment_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_adjustment.dart';
import 'state_adjustment.dart';

class ScreenAdjustmentForm extends StatelessWidget {
  final String brandId;

  const ScreenAdjustmentForm({
    super.key,
    required this.brandId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitAdjustment(
        adjustmentRepository: StockAdjustmentRepositoryMockImpl(),
        warehouseRepository: WarehouseRepositoryMockImpl(),
        itemRepository: ItemRepositoryMockImpl(),
      )..loadFormDropdowns(brandId),
      child: _AdjustmentFormView(brandId: brandId),
    );
  }
}

class _AdjustmentFormView extends StatefulWidget {
  final String brandId;
  const _AdjustmentFormView({required this.brandId});

  @override
  State<_AdjustmentFormView> createState() => _AdjustmentFormViewState();
}

class _AdjustmentFormViewState extends State<_AdjustmentFormView> {
  final _formKey = GlobalKey<FormState>();

  final _refController = TextEditingController();
  final _notesController = TextEditingController();

  WarehouseModel? _selectedWarehouse;

  // Dynamic list of items to adjust
  final List<_AdjustmentItemInput> _itemsList = [];

  @override
  void dispose() {
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _itemsList.add(_AdjustmentItemInput(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        qtyController: TextEditingController(text: '-1.0'), // default to negative correction
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
    if (_selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Warehouse')),
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
        'reason': i.reason,
      };
    }).toList();

    final data = {
      'referenceNo': _refController.text.trim().isEmpty ? null : _refController.text.trim(),
      'warehouseId': _selectedWarehouse!.id,
      'warehouseName': _selectedWarehouse!.name,
      'items': itemsData,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'adjustmentDate': DateTime.now().millisecondsSinceEpoch,
    };

    context.read<CubitAdjustment>().createAdjustment(widget.brandId, data);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<CubitAdjustment, StateAdjustment>(
      listener: (context, state) {
        if (state.status == AdjustmentStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock adjusted successfully'), backgroundColor: Colors.green),
          );
          context.pop();
        }
        if (state.status == AdjustmentStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred'), backgroundColor: cs.error),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AdjustmentStatus.loading;

        if (state.status == AdjustmentStatus.loading && state.items.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Record Stock Adjustment'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Details
                  Text('Adjustment Details', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
                  const Divider(),
                  SizedBox(height: AppSpacing.sm),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Reference Code (Auto Generated)',
                          hint: 'e.g. ADJ-2026-001',
                          controller: _refController,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppDropdownField<WarehouseModel>(
                          label: 'Warehouse Location *',
                          hint: 'Select warehouse',
                          value: _selectedWarehouse,
                          expands: true,
                          items: state.warehouses
                              .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedWarehouse = v),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // ── Adjust Items List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items to Adjust', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.secondary)),
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
                          'No items added. Click "Add Item" to adjust quantities.',
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Qty Offset (+/-) *',
                                        controller: input.qtyController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                        suffixIcon: const Tooltip(
                                          message: 'Use positive (+) to add stock, negative (-) to subtract stock',
                                          child: Icon(Icons.info_outline, size: 16),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) return 'Required';
                                          if (double.tryParse(v) == null) return 'Must be number';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppDropdownField<String>(
                                        label: 'Reason',
                                        value: input.reason,
                                        items: const [
                                          DropdownMenuItem(value: 'Spoilage', child: Text('Spoilage')),
                                          DropdownMenuItem(value: 'Damage', child: Text('Damage')),
                                          DropdownMenuItem(value: 'Theft', child: Text('Theft')),
                                          DropdownMenuItem(value: 'Audit Correction', child: Text('Audit Correction')),
                                          DropdownMenuItem(value: 'Promotional', child: Text('Promotional')),
                                        ],
                                        onChanged: (v) => setState(() => input.reason = v ?? 'Audit Correction'),
                                      ),
                                    ),
                                  ],
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
                    label: 'Audit Remarks / Reason Detail',
                    hint: 'Describe why this adjustment is being recorded',
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
                          : const Text('Record Adjustment', style: TextStyle(fontSize: 16)),
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

class _AdjustmentItemInput {
  final String id;
  ItemModel? item;
  final TextEditingController qtyController;
  String reason;

  _AdjustmentItemInput({
    required this.id,
    this.item,
    required this.qtyController,
    this.reason = 'Audit Correction',
  });
}
