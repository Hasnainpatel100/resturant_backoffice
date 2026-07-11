import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/indent_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_model.dart';
import 'package:back_office/data/models/restaurant_inventory/inventory_foundations.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/inventory_lookup_controller.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/internal_movement_controllers.dart';
import 'package:intl/intl.dart';

class ScreenIndentForm extends StatefulWidget {
  final String brandId;
  final String? indentId;
  const ScreenIndentForm({super.key, required this.brandId, this.indentId});

  @override
  State<ScreenIndentForm> createState() => _ScreenIndentFormState();
}

class _ScreenIndentFormState extends State<ScreenIndentForm> {
  final _formKey = GlobalKey<FormState>();
  final _indentNoController = TextEditingController();
  final _remarkController = TextEditingController();
  DateTime _indentDate = DateTime.now();

  String? _fromWarehouseId;
  String? _toWarehouseId;
  String _status = 'draft';

  final List<IndentItemModel> _items = [];

  late final IndentController controller;
  late final InventoryLookupController lookupController;

  bool get _isEditing => widget.indentId != null;
  bool get _isReadOnly => _status == 'submitted' || _status == 'approved' || _status == 'cancelled';

  @override
  void initState() {
    super.initState();
    controller = Get.find<IndentController>();
    lookupController = Get.put(InventoryLookupController());
    lookupController.loadAllLookups();

    if (_isEditing) {
      final indent = controller.indents.firstWhereOrNull((i) => i.id == widget.indentId);
      if (indent != null) {
        _indentNoController.text = indent.indentNo;
        _remarkController.text = indent.remark ?? '';
        _indentDate = indent.indentDate;
        _fromWarehouseId = indent.fromWarehouseId;
        _toWarehouseId = indent.toWarehouseId;
        _status = indent.status;
        _items.addAll(indent.items);
      }
    } else {
      _indentNoController.text = InventoryCalculations.generateDocumentNo('IND');
    }
  }

  @override
  void dispose() {
    _indentNoController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _addItemRow() {
    if (_isReadOnly) return;
    showDialog(
      context: context,
      builder: (context) => _AddIndentItemDialog(
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
    if (_fromWarehouseId == null || _toWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and supplying warehouses are required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_fromWarehouseId == _toWarehouseId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and supplying warehouses cannot be the same'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one raw material item'), backgroundColor: Colors.red),
      );
      return;
    }

    final indent = IndentModel(
      id: widget.indentId ?? '',
      indentNo: _indentNoController.text.trim(),
      indentDate: _indentDate,
      fromWarehouseId: _fromWarehouseId!,
      toWarehouseId: _toWarehouseId!,
      status: newStatus,
      remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
      createdAt: _isEditing
          ? (controller.indents.firstWhereOrNull((i) => i.id == widget.indentId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
      items: _items,
    );

    final success = _isEditing
        ? await controller.updateIndent(widget.indentId!, indent)
        : await controller.createIndent(indent);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus == 'submitted' ? 'Indent submitted successfully' : 'Indent draft saved'), backgroundColor: Colors.green),
      );
      if (context.mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/brands/${widget.brandId}/inventory/indents');
        }
      }
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
        title: Text(_isEditing ? (_isReadOnly ? 'View Purchase Indent' : 'Edit Purchase Indent') : 'New Purchase Indent'),
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
                            label: 'Indent Number',
                            controller: _indentNoController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _isReadOnly ? null : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _indentDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _indentDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Indent Date', prefixIcon: Icon(Icons.calendar_today)),
                              child: Text(DateFormat('yyyy-MM-dd').format(_indentDate)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() => AppDropdownField<String>(
                                label: 'Requesting Location (Branch)',
                                isEnabled: !_isReadOnly,
                                value: _fromWarehouseId,
                                items: lookupController.branches.map((b) {
                                  return DropdownMenuItem<String>(
                                    value: b.id,
                                    child: Text(b.name.en.isNotEmpty ? b.name.en : b.branchCode),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _fromWarehouseId = val),
                              )),
                          const SizedBox(height: 12),
                          Obx(() => AppDropdownField<String>(
                                label: 'Supplying Warehouse (Branch)',
                                isEnabled: !_isReadOnly,
                                value: _toWarehouseId,
                                items: lookupController.branches.map((b) {
                                  return DropdownMenuItem<String>(
                                    value: b.id,
                                    child: Text(b.name.en.isNotEmpty ? b.name.en : b.branchCode),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _toWarehouseId = val),
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
                              Text('Requested Items', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                                  subtitle: Text('Requested Qty: ${item.qtyRequest} ${_getUnitCode(item.unitId)}\nRemark: ${item.remark ?? "None"}'),
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
                ],
              ),
            ),

            // ── Draft & Submit Actions bar ────────────────────────────────────
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
                        onPressed: () => _submit('submitted'),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Submit Indent'),
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

// ── ADD INDENT ITEM DIALOG ───────────────────────────────────────────────────
class _AddIndentItemDialog extends StatefulWidget {
  final InventoryLookupController lookupController;
  final ValueChanged<IndentItemModel> onAdd;

  const _AddIndentItemDialog({
    required this.lookupController,
    required this.onAdd,
  });

  @override
  State<_AddIndentItemDialog> createState() => _AddIndentItemDialogState();
}

class _AddIndentItemDialogState extends State<_AddIndentItemDialog> {
  final _dialogFormKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _remarkController = TextEditingController();

  String? _materialId;
  String? _unitId;

  @override
  void dispose() {
    _qtyController.dispose();
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
      });
    }
  }

  void _submit() {
    if (!_dialogFormKey.currentState!.validate() || _materialId == null || _unitId == null) return;

    final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;

    final item = IndentItemModel(
      id: 'ITEM-${DateTime.now().millisecondsSinceEpoch}',
      rawMaterialId: _materialId!,
      unitId: _unitId!,
      qtyRequest: qty,
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
              AppTextField(
                label: 'Requested Qty',
                controller: _qtyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
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
