import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/purchase_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/supplier_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/data/models/inventory/supplier_model.dart';
import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_purchase.dart';
import 'state_purchase.dart';

class ScreenPurchaseForm extends StatelessWidget {
  final String brandId;

  const ScreenPurchaseForm({
    super.key,
    required this.brandId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitPurchase(
        purchaseRepository: PurchaseRepositoryMockImpl(),
        supplierRepository: SupplierRepositoryMockImpl(),
        warehouseRepository: WarehouseRepositoryMockImpl(),
        itemRepository: ItemRepositoryMockImpl(),
      )..loadFormDropdowns(brandId),
      child: _PurchaseFormView(brandId: brandId),
    );
  }
}

class _PurchaseFormView extends StatefulWidget {
  final String brandId;
  const _PurchaseFormView({required this.brandId});

  @override
  State<_PurchaseFormView> createState() => _PurchaseFormViewState();
}

class _PurchaseFormViewState extends State<_PurchaseFormView> {
  final _formKey = GlobalKey<FormState>();

  final _refController = TextEditingController();
  final _taxController = TextEditingController(text: '0.00');
  final _discountController = TextEditingController(text: '0.00');
  final _notesController = TextEditingController();

  SupplierModel? _selectedSupplier;
  WarehouseModel? _selectedWarehouse;
  String _paymentStatus = 'Paid';

  // Dynamic items list added to order
  final List<_PurchaseItemInput> _itemsList = [];

  @override
  void dispose() {
    _refController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subTotal {
    double sum = 0.0;
    for (final it in _itemsList) {
      if (it.item != null) {
        final q = double.tryParse(it.qtyController.text) ?? 0.0;
        final p = double.tryParse(it.priceController.text) ?? 0.0;
        sum += q * p;
      }
    }
    return sum;
  }

  double get _grandTotal {
    final sub = _subTotal;
    final tax = double.tryParse(_taxController.text) ?? 0.0;
    final disc = double.tryParse(_discountController.text) ?? 0.0;
    return (sub + tax) - disc;
  }

  void _addItem(List<ItemModel> availableItems) {
    setState(() {
      _itemsList.add(_PurchaseItemInput(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        qtyController: TextEditingController(text: '1.0'),
        priceController: TextEditingController(text: '0.00'),
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemsList[index].qtyController.dispose();
      _itemsList[index].priceController.dispose();
      _itemsList.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Supplier')),
      );
      return;
    }
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
        'costPrice': double.tryParse(i.priceController.text) ?? 0.0,
        'total': (double.tryParse(i.qtyController.text) ?? 0.0) *
            (double.tryParse(i.priceController.text) ?? 0.0),
      };
    }).toList();

    final data = {
      'referenceNo': _refController.text.trim().isEmpty ? null : _refController.text.trim(),
      'supplierId': _selectedSupplier!.id,
      'supplierName': _selectedSupplier!.name,
      'warehouseId': _selectedWarehouse!.id,
      'warehouseName': _selectedWarehouse!.name,
      'items': itemsData,
      'subTotal': _subTotal,
      'taxAmount': double.tryParse(_taxController.text) ?? 0.0,
      'discountAmount': double.tryParse(_discountController.text) ?? 0.0,
      'totalAmount': _grandTotal,
      'paymentStatus': _paymentStatus,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'purchaseDate': DateTime.now().millisecondsSinceEpoch,
    };

    context.read<CubitPurchase>().createPurchase(widget.brandId, data);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<CubitPurchase, StatePurchase>(
      listener: (context, state) {
        if (state.status == PurchaseStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock received successfully'), backgroundColor: Colors.green),
          );
          context.pop();
        }
        if (state.status == PurchaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred'), backgroundColor: cs.error),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == PurchaseStatus.loading;

        if (state.status == PurchaseStatus.loading && state.items.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Record Stock In / Purchase'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order Details
                  Text('Purchase Header Details', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
                  const Divider(),
                  SizedBox(height: AppSpacing.sm),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Reference Code (Auto Generated if blank)',
                          hint: 'e.g. PO-2026-001',
                          controller: _refController,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppDropdownField<String>(
                          label: 'Payment Status',
                          value: _paymentStatus,
                          items: const [
                            DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                            DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                            DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                          ],
                          onChanged: (v) => setState(() => _paymentStatus = v ?? 'Paid'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<SupplierModel>(
                          label: 'Supplier / Vendor *',
                          hint: 'Select supplier',
                          value: _selectedSupplier,
                          expands: true,
                          items: state.suppliers
                              .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedSupplier = v),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppDropdownField<WarehouseModel>(
                          label: 'Target Warehouse *',
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

                  // ── Items List Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Line Items', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.secondary)),
                      FilledButton.icon(
                        onPressed: () => _addItem(state.items),
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
                          'No items added yet. Click "Add Item" above.',
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
                                        onChanged: (item) {
                                          setState(() {
                                            input.item = item;
                                            if (item != null) {
                                              input.priceController.text = item.costPrice.toStringAsFixed(2);
                                            }
                                          });
                                        },
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
                                        label: 'Qty ${input.item?.unitCode != null ? "(${input.item!.unitCode})" : ""}',
                                        controller: input.qtyController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Cost Price (₹)',
                                        controller: input.priceController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        prefixIcon: const Icon(Icons.currency_rupee, size: 14),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('Total', style: tt.bodySmall),
                                          const SizedBox(height: 4),
                                          Text(
                                            '₹${((double.tryParse(input.qtyController.text) ?? 0.0) * (double.tryParse(input.priceController.text) ?? 0.0)).toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
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
                  SizedBox(height: AppSpacing.lg),

                  // ── Order Summary Card
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Receipt Order Summary', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const Divider(),
                          _SummaryRow(label: 'Sub Total', value: '₹${_subTotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Tax (₹)',
                                  controller: _taxController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'Discount (₹)',
                                  controller: _discountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          _SummaryRow(
                            label: 'Grand Total',
                            value: '₹${_grandTotal.toStringAsFixed(2)}',
                            valueStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Notes
                  AppTextField(
                    label: 'Remarks / Notes',
                    hint: 'Enter order details or invoice reference information',
                    controller: _notesController,
                    maxLines: 3,
                    minLines: 2,
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Stock-In Bill', style: TextStyle(fontSize: 16)),
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

class _PurchaseItemInput {
  final String id;
  ItemModel? item;
  final TextEditingController qtyController;
  final TextEditingController priceController;

  _PurchaseItemInput({
    required this.id,
    this.item,
    required this.qtyController,
    required this.priceController,
  });
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
