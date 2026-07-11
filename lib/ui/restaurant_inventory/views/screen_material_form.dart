import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenMaterialForm extends StatefulWidget {
  final String brandId;
  final String? itemId;
  const ScreenMaterialForm({super.key, required this.brandId, this.itemId});

  @override
  State<ScreenMaterialForm> createState() => _ScreenMaterialFormState();
}

class _ScreenMaterialFormState extends State<ScreenMaterialForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _purchaseRateController = TextEditingController();
  final _sellingRateController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _minLevelController = TextEditingController();
  final _maxLevelController = TextEditingController();

  String? _groupId;
  String? _baseUnitId;
  String? _taxId;

  bool _trackInventory = true;
  bool _hasExpiry = false;
  bool _isBatchWise = false;
  bool _isFurnishedItem = false;
  bool _isSubRecipeItem = false;
  bool _isActive = true;

  late final RawMaterialController controller;
  late final RawMaterialGroupController groupController;
  late final UnitController unitController;
  late final RawMaterialTaxController taxController;

  bool get _isEditing => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    controller = Get.find<RawMaterialController>();
    groupController = Get.put(RawMaterialGroupController(repository: RawMaterialGroupRepositoryImpl()));
    unitController = Get.put(UnitController(repository: UnitRepositoryImpl()));
    taxController = Get.put(RawMaterialTaxController(repository: RawMaterialTaxRepositoryImpl()));

    groupController.loadGroups();
    unitController.loadUnits();
    taxController.loadTaxes();

    if (_isEditing) {
      final mat = controller.materials.firstWhereOrNull((m) => m.id == widget.itemId);
      if (mat != null) {
        _codeController.text = mat.materialCode;
        _nameController.text = mat.materialName;
        _shortNameController.text = mat.shortName;
        _purchaseRateController.text = mat.purchaseRate.toString();
        _sellingRateController.text = mat.sellingRate.toString();
        _reorderLevelController.text = mat.reorderLevel.toString();
        _minLevelController.text = mat.minimumLevel.toString();
        _maxLevelController.text = mat.maximumLevel.toString();

        _groupId = mat.groupId.isEmpty ? null : mat.groupId;
        _baseUnitId = mat.baseUnitId.isEmpty ? null : mat.baseUnitId;
        _taxId = mat.defaultTaxId;

        _trackInventory = mat.trackInventory;
        _hasExpiry = mat.hasExpiry;
        _isBatchWise = mat.isBatchWise;
        _isFurnishedItem = mat.isFurnishedItem;
        _isSubRecipeItem = mat.isSubRecipeItem;
        _isActive = mat.isActive;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _shortNameController.dispose();
    _purchaseRateController.dispose();
    _sellingRateController.dispose();
    _reorderLevelController.dispose();
    _minLevelController.dispose();
    _maxLevelController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_groupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Raw Material Group is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_baseUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base Unit is required'), backgroundColor: Colors.red),
      );
      return;
    }

    final mat = RawMaterialModel(
      id: widget.itemId ?? '',
      materialCode: _codeController.text.trim(),
      materialName: _nameController.text.trim(),
      shortName: _shortNameController.text.trim(),
      groupId: _groupId!,
      baseUnitId: _baseUnitId!,
      defaultTaxId: _taxId,
      purchaseRate: double.tryParse(_purchaseRateController.text.trim()) ?? 0.0,
      lastPurchaseRate: _isEditing
          ? (controller.materials.firstWhereOrNull((m) => m.id == widget.itemId)?.lastPurchaseRate ?? 0.0)
          : 0.0,
      sellingRate: double.tryParse(_sellingRateController.text.trim()) ?? 0.0,
      reorderLevel: double.tryParse(_reorderLevelController.text.trim()) ?? 0.0,
      minimumLevel: double.tryParse(_minLevelController.text.trim()) ?? 0.0,
      maximumLevel: double.tryParse(_maxLevelController.text.trim()) ?? 0.0,
      trackInventory: _trackInventory,
      hasExpiry: _hasExpiry,
      isBatchWise: _isBatchWise,
      isFurnishedItem: _isFurnishedItem,
      isSubRecipeItem: _isSubRecipeItem,
      isActive: _isActive,
      createdAt: _isEditing
          ? (controller.materials.firstWhereOrNull((m) => m.id == widget.itemId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
    );

    final success = _isEditing
        ? await controller.updateMaterial(widget.itemId!, mat)
        : await controller.createMaterial(mat);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Material updated' : 'Material created'), backgroundColor: Colors.green),
      );
      if (context.mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/brands/${widget.brandId}/inventory/items');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Raw Material' : 'New Raw Material'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextField(
              label: 'Material Code',
              hint: 'e.g. RM001',
              controller: _codeController,
              validator: (v) => v == null || v.isEmpty ? 'Material Code is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Material Name',
              hint: 'e.g. All-Purpose Flour',
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Material Name is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Short Name / Alias',
              hint: 'e.g. AP Flour',
              controller: _shortNameController,
            ),
            SizedBox(height: AppSpacing.md),
            Obx(() => AppDropdownField<String>(
                  label: 'Raw Material Group',
                  hint: 'Select Group',
                  value: _groupId,
                  items: groupController.groups.map((g) {
                    return DropdownMenuItem<String>(
                      value: g.id,
                      child: Text(g.groupName),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _groupId = val),
                )),
            SizedBox(height: AppSpacing.md),
            Obx(() => AppDropdownField<String>(
                  label: 'Base Unit of Measurement',
                  hint: 'Select Unit',
                  value: _baseUnitId,
                  items: unitController.units.map((u) {
                    return DropdownMenuItem<String>(
                      value: u.id,
                      child: Text(u.displayLabel),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _baseUnitId = val),
                )),
            SizedBox(height: AppSpacing.md),
            Obx(() => AppDropdownField<String>(
                  label: 'Default Tax (Optional)',
                  hint: 'Select Tax',
                  value: _taxId,
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('No Tax')),
                    ...taxController.taxes.map((t) {
                      return DropdownMenuItem<String>(
                        value: t.id,
                        child: Text(t.displayLabel),
                      );
                    }),
                  ],
                  onChanged: (val) => setState(() => _taxId = val),
                )),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Purchase Rate',
                    hint: 'e.g. 10.0',
                    controller: _purchaseRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Selling Rate (if applicable)',
                    hint: 'e.g. 15.0',
                    controller: _sellingRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Reorder Level',
                    hint: 'e.g. 50.0',
                    controller: _reorderLevelController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Min Level',
                    hint: 'e.g. 10.0',
                    controller: _minLevelController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Max Level',
                    hint: 'e.g. 500.0',
                    controller: _maxLevelController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            AppSwitchField(
              label: 'Track Inventory',
              description: 'Maintain stock on hand and record transactions for this item',
              value: _trackInventory,
              onChanged: (val) => setState(() => _trackInventory = val),
            ),
            SizedBox(height: AppSpacing.md),
            AppSwitchField(
              label: 'Has Expiry',
              description: 'Whether stock units of this item carry expiry dates',
              value: _hasExpiry,
              onChanged: (val) => setState(() => _hasExpiry = val),
            ),
            SizedBox(height: AppSpacing.md),
            AppSwitchField(
              label: 'Is Batch Wise',
              description: 'Track stock units separately by batch numbers',
              value: _isBatchWise,
              onChanged: (val) => setState(() => _isBatchWise = val),
            ),
            SizedBox(height: AppSpacing.md),
            AppSwitchField(
              label: 'Is Furnished Item',
              description: 'Whether this is a final output item produced from production recipe',
              value: _isFurnishedItem,
              onChanged: (val) => setState(() => _isFurnishedItem = val),
            ),
            SizedBox(height: AppSpacing.md),
            AppSwitchField(
              label: 'Is Sub-Recipe Item',
              description: 'Whether this item is a semi-finished product used in other recipes',
              value: _isSubRecipeItem,
              onChanged: (val) => setState(() => _isSubRecipeItem = val),
            ),
            SizedBox(height: AppSpacing.md),
            AppSwitchField(
              label: 'Active Status',
              description: 'Deactivate to disable procurement and transfers of this item',
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(() => AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Raw Material',
                  isLoading: controller.isLoading.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}
