import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/goods_receipt_model.dart';
import 'package:back_office/data/models/restaurant_inventory/purchase_order_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_model.dart';
import 'package:back_office/data/models/restaurant_inventory/inventory_foundations.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/inventory_lookup_controller.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/procurement_controllers.dart';
import 'package:intl/intl.dart';

class ScreenGRNForm extends StatefulWidget {
  final String brandId;
  final String? grnId;
  const ScreenGRNForm({super.key, required this.brandId, this.grnId});

  @override
  State<ScreenGRNForm> createState() => _ScreenGRNFormState();
}

class _ScreenGRNFormState extends State<ScreenGRNForm> {
  final _formKey = GlobalKey<FormState>();
  final _grnNoController = TextEditingController();
  final _remarkController = TextEditingController();
  DateTime _grnDate = DateTime.now();

  String? _poId;
  String? _vendorId;
  String _status = 'draft';

  final List<GoodsReceiptItemModel> _items = [];

  late final GoodsReceiptController controller;
  late final PurchaseOrderController poController;
  late final InventoryLookupController lookupController;

  bool get _isEditing => widget.grnId != null;
  bool get _isReadOnly => _status == 'posted' || _status == 'cancelled';

  @override
  void initState() {
    super.initState();
    controller = Get.find<GoodsReceiptController>();
    poController = Get.find<PurchaseOrderController>();
    lookupController = Get.put(InventoryLookupController());
    lookupController.loadAllLookups();
    poController.loadPOs();

    if (_isEditing) {
      final grn = controller.grns.firstWhereOrNull((g) => g.id == widget.grnId);
      if (grn != null) {
        _grnNoController.text = grn.grnNo;
        _remarkController.text = grn.remark ?? '';
        _grnDate = grn.grnDate;
        _poId = grn.purchaseOrderId;
        _vendorId = grn.vendorId;
        _status = grn.status;
        _items.addAll(grn.items);
      }
    } else {
      _grnNoController.text = InventoryCalculations.generateDocumentNo('GRN');
    }
  }

  @override
  void dispose() {
    _grnNoController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  double get _subtotal {
    double sum = 0.0;
    for (var item in _items) {
      sum += item.qty * item.rate;
    }
    return sum;
  }

  double get _taxTotal {
    double sum = 0.0;
    for (var item in _items) {
      sum += item.taxAmount;
    }
    return sum;
  }

  double get _grandTotal {
    double sum = 0.0;
    for (var item in _items) {
      sum += item.lineTotal;
    }
    return sum;
  }

  void _onPOSelected(String? selectedPoId) {
    if (selectedPoId == null) return;
    final po = poController.pos.firstWhereOrNull((p) => p.id == selectedPoId);
    if (po != null) {
      setState(() {
        _poId = selectedPoId;
        _vendorId = po.vendorId;
        _items.clear();
        for (var item in po.items) {
          _items.add(GoodsReceiptItemModel(
            id: 'ITEM-${DateTime.now().millisecondsSinceEpoch}-${item.rawMaterialId}',
            rawMaterialId: item.rawMaterialId,
            unitId: item.unitId,
            qty: item.qty,
            rate: item.rate,
            taxPercent: item.taxPercent,
            taxAmount: item.taxAmount,
            lineTotal: item.lineTotal,
          ));
        }
      });
    }
  }

  void _addItemRow() {
    if (_isReadOnly) return;
    showDialog(
      context: context,
      builder: (context) => _AddGRNItemDialog(
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
    if (_vendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one raw material item'), backgroundColor: Colors.red),
      );
      return;
    }

    final grn = GoodsReceiptModel(
      id: widget.grnId ?? '',
      grnNo: _grnNoController.text.trim(),
      grnDate: _grnDate,
      purchaseOrderId: _poId,
      vendorId: _vendorId!,
      status: newStatus,
      amount: _subtotal,
      taxAmount: _taxTotal,
      totalWithTax: _grandTotal,
      remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
      createdAt: _isEditing
          ? (controller.grns.firstWhereOrNull((g) => g.id == widget.grnId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
      items: _items,
    );

    final success = _isEditing
        ? await controller.updateGRN(widget.grnId!, grn)
        : await controller.createGRN(grn);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus == 'posted' ? 'GRN posted successfully' : 'GRN draft saved'), backgroundColor: Colors.green),
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
        title: Text(_isEditing ? (_isReadOnly ? 'View Goods Receipt' : 'Edit Goods Receipt') : 'New Goods Receipt (GRN)'),
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
                            label: 'GRN Number',
                            controller: _grnNoController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _isReadOnly ? null : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _grnDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _grnDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'GRN Date', prefixIcon: Icon(Icons.calendar_today)),
                              child: Text(DateFormat('yyyy-MM-dd HH:mm').format(_grnDate)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Reference PO Lookup
                          Obx(() => AppDropdownField<String>(
                                label: 'Import from Purchase Order (Optional)',
                                isEnabled: !_isReadOnly,
                                value: _poId,
                                items: [
                                  const DropdownMenuItem<String>(value: null, child: Text('No Reference PO')),
                                  ...poController.pos.map((p) {
                                    return DropdownMenuItem<String>(
                                      value: p.id,
                                      child: Text('${p.poNo} (${p.status.toUpperCase()})'),
                                    );
                                  }),
                                ],
                                onChanged: _onPOSelected,
                              )),
                          const SizedBox(height: 12),
                          Obx(() => AppDropdownField<String>(
                                label: 'Vendor (Supplier)',
                                isEnabled: !_isReadOnly && _poId == null, // disable vendor change if importing from PO
                                value: _vendorId,
                                items: lookupController.vendors.map((v) {
                                  return DropdownMenuItem<String>(
                                    value: v.id,
                                    child: Text(v.vendorName),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _vendorId = val),
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
                              Text('Received Items', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              if (!_isReadOnly && _poId == null) // only allow manual adding if not linked to PO
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
                                child: Text('No items added. Select a PO or click "Add Raw Material".', style: TextStyle(color: Colors.grey)),
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
                                  subtitle: Text('Qty: ${item.qty} ${_getUnitCode(item.unitId)} • Rate: \$${item.rate.toStringAsFixed(2)} • Tax: \$${item.taxAmount.toStringAsFixed(2)} • Line Total: \$${item.lineTotal.toStringAsFixed(2)}\nBatch: ${item.batchNo ?? "N/A"}'),
                                  trailing: !_isReadOnly && _poId == null
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
                              const Text('Subtotal:'),
                              Text('\$${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tax Total:'),
                              Text('\$${_taxTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Grand Total:', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text('\$${_grandTotal.toStringAsFixed(2)}', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
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
                        child: const Text('Post Goods Receipt'),
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

// ── ADD GRN ITEM DIALOG ──────────────────────────────────────────────────────
class _AddGRNItemDialog extends StatefulWidget {
  final InventoryLookupController lookupController;
  final ValueChanged<GoodsReceiptItemModel> onAdd;

  const _AddGRNItemDialog({
    required this.lookupController,
    required this.onAdd,
  });

  @override
  State<_AddGRNItemDialog> createState() => _AddGRNItemDialogState();
}

class _AddGRNItemDialogState extends State<_AddGRNItemDialog> {
  final _dialogFormKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _batchNoController = TextEditingController();
  final _remarkController = TextEditingController();

  String? _materialId;
  String? _unitId;
  String? _taxId;
  DateTime? _expiryDate;

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    _batchNoController.dispose();
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
        _taxId = mat.defaultTaxId;
        _rateController.text = mat.purchaseRate.toString();
      });
    }
  }

  double get _taxPercent {
    if (_taxId == null) return 0.0;
    final tax = widget.lookupController.taxes.firstWhereOrNull((t) => t.id == _taxId);
    return tax?.taxValue ?? 0.0;
  }

  void _submit() {
    if (!_dialogFormKey.currentState!.validate() || _materialId == null || _unitId == null) return;

    final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;

    final tax = widget.lookupController.taxes.firstWhereOrNull((t) => t.id == _taxId);
    final includeInRate = tax?.includeInRate ?? false;

    final calcs = InventoryCalculations.calculateLineTotals(
      qty: qty,
      rate: rate,
      taxValue: _taxPercent,
      includeInRate: includeInRate,
    );

    final item = GoodsReceiptItemModel(
      id: 'ITEM-${DateTime.now().millisecondsSinceEpoch}',
      rawMaterialId: _materialId!,
      unitId: _unitId!,
      qty: qty,
      rate: rate,
      taxPercent: _taxPercent,
      taxAmount: calcs['taxAmount'] ?? 0.0,
      lineTotal: calcs['lineTotal'] ?? 0.0,
      batchNo: _batchNoController.text.trim().isEmpty ? null : _batchNoController.text.trim(),
      expiryDate: _expiryDate,
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
              AppDropdownField<String>(
                label: 'Tax Rule',
                value: _taxId,
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('No Tax')),
                  ...widget.lookupController.taxes.map((t) {
                    return DropdownMenuItem<String>(
                      value: t.id,
                      child: Text(t.displayLabel),
                    );
                  }),
                ],
                onChanged: (val) => setState(() => _taxId = val),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Batch Number (Optional)',
                controller: _batchNoController,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(() => _expiryDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Expiry Date (Optional)', prefixIcon: Icon(Icons.date_range)),
                  child: Text(_expiryDate != null ? DateFormat('yyyy-MM-dd').format(_expiryDate!) : 'Not Set'),
                ),
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
