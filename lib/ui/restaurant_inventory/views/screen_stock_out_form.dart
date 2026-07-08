import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/manual_stock_out_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_model.dart';
import 'package:back_office/data/models/restaurant_inventory/inventory_foundations.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/inventory_lookup_controller.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/manual_inventory_controllers.dart';
import 'package:intl/intl.dart';

class ScreenStockOutForm extends StatefulWidget {
  final String brandId;
  final String? outId;
  const ScreenStockOutForm({super.key, required this.brandId, this.outId});

  @override
  State<ScreenStockOutForm> createState() => _ScreenStockOutFormState();
}

class _ScreenStockOutFormState extends State<ScreenStockOutForm> {
  final _formKey = GlobalKey<FormState>();
  final _outNoController = TextEditingController();
  final _remarkController = TextEditingController();
  DateTime _outDate = DateTime.now();

  String? _warehouseId;
  String? _reasonId;
  String _status = 'draft';

  final List<ManualStockOutItemModel> _items = [];

  late final ManualStockOutController controller;
  late final InventoryLookupController lookupController;

  bool get _isEditing => widget.outId != null;
  bool get _isReadOnly => _status == 'posted';

  @override
  void initState() {
    super.initState();
    controller = Get.find<ManualStockOutController>();
    lookupController = Get.put(InventoryLookupController());
    lookupController.loadAllLookups();

    if (_isEditing) {
      final out = controller.outs.firstWhereOrNull((o) => o.id == widget.outId);
      if (out != null) {
        _outNoController.text = out.stockOutNo;
        _remarkController.text = out.remark ?? '';
        _outDate = out.stockOutDate;
        _warehouseId = out.warehouseId;
        _reasonId = out.reasonId;
        _status = out.status;
        _items.addAll(out.items);
      }
    } else {
      _outNoController.text = InventoryCalculations.generateDocumentNo('OUT');
    }
  }

  @override
  void dispose() {
    _outNoController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    double sum = 0.0;
    for (var item in _items) {
      sum += item.lineAmount;
    }
    return sum;
  }

  void _addItemRow() {
    if (_isReadOnly) return;
    showDialog(
      context: context,
      builder: (context) => _AddOutItemDialog(
        lookupController: lookupController,
        onAdd: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _removeItemRow(int index) {
    if (_isReadOnly) return;
    setState(() {
      _items.removeAt(index);
    });
  }

  void _submit(String newStatus) async {
    if (!_formKey.currentState!.validate()) return;
    if (_warehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warehouse is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_reasonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reason is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one raw material item'), backgroundColor: Colors.red),
      );
      return;
    }

    final out = ManualStockOutModel(
      id: widget.outId ?? '',
      stockOutNo: _outNoController.text.trim(),
      stockOutDate: _outDate,
      warehouseId: _warehouseId!,
      reasonId: _reasonId!,
      status: newStatus,
      remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
      createdAt: _isEditing
          ? (controller.outs.firstWhereOrNull((o) => o.id == widget.outId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
      items: _items,
    );

    final success = _isEditing
        ? await controller.updateOut(widget.outId!, out)
        : await controller.createOut(out);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus == 'posted' ? 'Stock Out posted successfully' : 'Stock Out draft saved'), backgroundColor: Colors.green),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage.value ?? 'Operation failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _getMaterialLabel(String matId) {
    final mat = lookupController.rawMaterials.firstWhereOrNull((m) => m.id == matId);
    return mat?.materialName ?? 'Unknown material';
  }

  String _getUnitCode(String unitId) {
    final unit = lookupController.units.firstWhereOrNull((u) => u.id == unitId);
    return unit?.shortName ?? 'pcs';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? (_isReadOnly ? 'View Stock Out' : 'Edit Stock Out') : 'New Manual Stock Out'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  // ── Header Details ──────────────────────────────────────────
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Header Details', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const Divider(),
                          const SizedBox(height: 8),
                          AppTextField(
                            label: 'Stock Out Number',
                            controller: _outNoController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _isReadOnly ? null : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _outDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _outDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Stock Out Date', prefixIcon: Icon(Icons.calendar_today)),
                              child: Text(DateFormat('yyyy-MM-dd HH:mm').format(_outDate)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() => AppDropdownField<String>(
                                label: 'Warehouse (Branch)',
                                isEnabled: !_isReadOnly,
                                value: _warehouseId,
                                items: lookupController.branches.map((b) {
                                  return DropdownMenuItem<String>(
                                    value: b.id,
                                    child: Text(b.name.en.isNotEmpty ? b.name.en : b.branchCode),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _warehouseId = val),
                              )),
                          const SizedBox(height: 12),
                          Obx(() => AppDropdownField<String>(
                                label: 'Reason for Stock Out',
                                isEnabled: !_isReadOnly,
                                value: _reasonId,
                                items: lookupController.reasons.map((r) {
                                  return DropdownMenuItem<String>(
                                    value: r.id,
                                    child: Text(r.reasonName),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _reasonId = val),
                              )),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'Remark',
                            hint: 'Enter remarks',
                            controller: _remarkController,
                            readOnly: _isReadOnly,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Items List Details ──────────────────────────────────────
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Items Details', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              if (!_isReadOnly)
                                TextButton.icon(
                                  onPressed: _addItemRow,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Raw Material'),
                                ),
                            ],
                          ),
                          const Divider(),
                          if (_items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text('No items added. Click "Add Raw Material" above.', style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _items.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, idx) {
                                final item = _items[idx];
                                return ListTile(
                                  title: Text(_getMaterialLabel(item.rawMaterialId), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Qty: ${item.qty} ${_getUnitCode(item.unitId)} • Cost Rate: \$${item.rate.toStringAsFixed(2)} • Total Cost: \$${item.lineAmount.toStringAsFixed(2)}'),
                                  trailing: !_isReadOnly
                                      ? IconButton(
                                          icon: Icon(Icons.delete_outline, color: cs.error),
                                          onPressed: () => _removeItemRow(idx),
                                        )
                                      : null,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Valuation summary details ──────────────────────────────
                  Card(
                    color: cs.primary.withOpacity(0.04),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Valuation Summary', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const Divider(),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Grand Total Cost:', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text('\$${_totalAmount.toStringAsFixed(2)}', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Draft & Post Actions bar ──────────────────────────────────────
            if (!_isReadOnly)
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _submit('draft'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Save as Draft'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _submit('posted'),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Post Stock Out'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── ADD ITEM DIALOG ──────────────────────────────────────────────────────────
class _AddOutItemDialog extends StatefulWidget {
  final InventoryLookupController lookupController;
  final ValueChanged<ManualStockOutItemModel> onAdd;

  const _AddOutItemDialog({
    required this.lookupController,
    required this.onAdd,
  });

  @override
  State<_AddOutItemDialog> createState() => _AddOutItemDialogState();
}

class _AddOutItemDialogState extends State<_AddOutItemDialog> {
  final _dialogFormKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _remarkController = TextEditingController();

  String? _materialId;
  String? _unitId;

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _onMaterialSelected(String? matId) {
    if (matId == null) return;
    final mat = widget.lookupController.rawMaterials.firstWhereOrNull((m) => m.id == matId);
    if (mat != null) {
      setState(() {
        _materialId = matId;
        _unitId = mat.baseUnitId;
        _rateController.text = mat.purchaseRate.toString();
      });
    }
  }

  void _submit() {
    if (!_dialogFormKey.currentState!.validate() || _materialId == null || _unitId == null) return;

    final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final lineAmount = qty * rate;

    final item = ManualStockOutItemModel(
      id: 'ITEM-${DateTime.now().millisecondsSinceEpoch}',
      rawMaterialId: _materialId!,
      unitId: _unitId!,
      qty: qty,
      rate: rate,
      lineAmount: lineAmount,
      remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
    );

    widget.onAdd(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Raw Material'),
      content: Form(
        key: _dialogFormKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppDropdownField<String>(
                label: 'Raw Material',
                value: _materialId,
                items: widget.lookupController.rawMaterials.map((m) {
                  return DropdownMenuItem<String>(
                    value: m.id,
                    child: Text(m.displayLabel),
                  );
                }).toList(),
                onChanged: _onMaterialSelected,
              ),
              const SizedBox(height: 12),
              AppDropdownField<String>(
                label: 'Unit',
                value: _unitId,
                items: widget.lookupController.units.map((u) {
                  return DropdownMenuItem<String>(
                    value: u.id,
                    child: Text(u.displayLabel),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _unitId = val),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Qty',
                      controller: _qtyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      label: 'Rate',
                      controller: _rateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Remark',
                controller: _remarkController,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add Item'),
        ),
      ],
    );
  }
}
