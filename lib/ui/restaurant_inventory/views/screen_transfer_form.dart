import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_transfer_model.dart';
import 'package:back_office/data/models/restaurant_inventory/indent_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_model.dart';
import 'package:back_office/data/models/restaurant_inventory/inventory_foundations.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/inventory_lookup_controller.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/internal_movement_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/internal_movement_repositories.dart';
import 'package:intl/intl.dart';

class ScreenTransferForm extends StatefulWidget {
  final String brandId;
  final String? transferId;
  const ScreenTransferForm({super.key, required this.brandId, this.transferId});

  @override
  State<ScreenTransferForm> createState() => _ScreenTransferFormState();
}

class _ScreenTransferFormState extends State<ScreenTransferForm> {
  final _formKey = GlobalKey<FormState>();
  final _transferNoController = TextEditingController();
  final _remarkController = TextEditingController();
  DateTime _transferDate = DateTime.now();

  String? _fromWarehouseId;
  String? _toWarehouseId;
  String? _indentId;
  String _status = 'draft';

  final List<StockTransferItemModel> _items = [];

  late final StockTransferController controller;
  late final IndentController indentController;
  late final InventoryLookupController lookupController;

  bool get _isEditing => widget.transferId != null;
  bool get _isReadOnly => _status == 'posted' || _status == 'cancelled';

  @override
  void initState() {
    super.initState();
    controller = Get.find<StockTransferController>();
    indentController = Get.put(IndentController(repository: IndentRepositoryImpl()));
    lookupController = Get.put(InventoryLookupController());

    lookupController.loadAllLookups();
    indentController.loadIndents();

    if (_isEditing) {
      final transfer = controller.transfers.firstWhereOrNull((t) => t.id == widget.transferId);
      if (transfer != null) {
        _transferNoController.text = transfer.transferNo;
        _remarkController.text = transfer.remark ?? '';
        _transferDate = transfer.transferDate;
        _fromWarehouseId = transfer.fromWarehouseId;
        _toWarehouseId = transfer.toWarehouseId;
        _indentId = transfer.indentId;
        _status = transfer.status;
        _items.addAll(transfer.items);
      }
    } else {
      _transferNoController.text = InventoryCalculations.generateDocumentNo('TRF');
    }
  }

  @override
  void dispose() {
    _transferNoController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _onIndentSelected(String? selectedIndentId) {
    if (selectedIndentId == null) return;
    final indent = indentController.indents.firstWhereOrNull((i) => i.id == selectedIndentId);
    if (indent != null) {
      setState(() {
        _indentId = selectedIndentId;
        _fromWarehouseId = indent.toWarehouseId;   // supplying warehouse is the source of transfer
        _toWarehouseId = indent.fromWarehouseId;   // requesting outlet is the destination
        _items.clear();
        for (var item in indent.items) {
          _items.add(StockTransferItemModel(
            id: 'ITEM-${DateTime.now().millisecondsSinceEpoch}-${item.rawMaterialId}',
            rawMaterialId: item.rawMaterialId,
            unitId: item.unitId,
            qtyTransfer: item.qtyRequest,
          ));
        }
      });
    }
  }

  void _addItemRow() {
    if (_isReadOnly) return;
    showDialog(
      context: context,
      builder: (context) => _AddTransferItemDialog(
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
        const SnackBar(content: Text('Source and destination warehouses are required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_fromWarehouseId == _toWarehouseId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and destination warehouses cannot be the same'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one raw material item'), backgroundColor: Colors.red),
      );
      return;
    }

    final transfer = StockTransferModel(
      id: widget.transferId ?? '',
      transferNo: _transferNoController.text.trim(),
      transferDate: _transferDate,
      fromWarehouseId: _fromWarehouseId!,
      toWarehouseId: _toWarehouseId!,
      indentId: _indentId,
      status: newStatus,
      remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
      createdAt: _isEditing
          ? (controller.transfers.firstWhereOrNull((t) => t.id == widget.transferId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
      items: _items,
    );

    final success = _isEditing
        ? await controller.updateTransfer(widget.transferId!, transfer)
        : await controller.createTransfer(transfer);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus == 'posted' ? 'Transfer posted successfully' : 'Transfer draft saved'), backgroundColor: Colors.green),
      );
      if (context.mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/brands/${widget.brandId}/inventory/transfers');
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
        title: Text(_isEditing ? (_isReadOnly ? 'View Stock Transfer' : 'Edit Stock Transfer') : 'New Stock Transfer'),
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
                            label: 'Transfer Number',
                            controller: _transferNoController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _isReadOnly ? null : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _transferDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _transferDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Transfer Date', prefixIcon: Icon(Icons.calendar_today)),
                              child: Text(DateFormat('yyyy-MM-dd').format(_transferDate)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Import from Indent Reference
                          Obx(() => AppDropdownField<String>(
                                label: 'Import from Indent (Optional)',
                                isEnabled: !_isReadOnly,
                                value: _indentId,
                                items: [
                                  const DropdownMenuItem<String>(value: null, child: Text('No Reference Indent')),
                                  ...indentController.indents.map((ind) {
                                    return DropdownMenuItem<String>(
                                      value: ind.id,
                                      child: Text('${ind.indentNo} (${ind.status.toUpperCase()})'),
                                    );
                                  }),
                                ],
                                onChanged: _onIndentSelected,
                              )),
                          const SizedBox(height: 12),
                          Obx(() => AppDropdownField<String>(
                                label: 'Source Location (Branch)',
                                isEnabled: !_isReadOnly && _indentId == null,
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
                                label: 'Destination Warehouse (Branch)',
                                isEnabled: !_isReadOnly && _indentId == null,
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
                              Text('Items to Transfer', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              if (!_isReadOnly && _indentId == null)
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
                                child: Text('No items added. Reference an Indent or click "Add Raw Material".', style: TextStyle(color: Colors.grey)),
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
                                  subtitle: Text('Transferred Qty: ${item.qtyTransfer} ${_getUnitCode(item.unitId)}\nRemark: ${item.remark ?? "None"}'),
                                  trailing: !_isReadOnly && _indentId == null
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
                        child: const Text('Post Transfer'),
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

// ── ADD TRANSFER ITEM DIALOG ─────────────────────────────────────────────────
class _AddTransferItemDialog extends StatefulWidget {
  final InventoryLookupController lookupController;
  final ValueChanged<StockTransferItemModel> onAdd;

  const _AddTransferItemDialog({
    required this.lookupController,
    required this.onAdd,
  });

  @override
  State<_AddTransferItemDialog> createState() => _AddTransferItemDialogState();
}

class _AddTransferItemDialogState extends State<_AddTransferItemDialog> {
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

    final item = StockTransferItemModel(
      id: 'ITEM-${DateTime.now().millisecondsSinceEpoch}',
      rawMaterialId: _materialId!,
      unitId: _unitId!,
      qtyTransfer: qty,
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
                label: 'Transferred Qty',
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
