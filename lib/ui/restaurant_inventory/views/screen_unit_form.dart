import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/unit_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';

class ScreenUnitForm extends StatefulWidget {
  final String brandId;
  final String? unitId;
  const ScreenUnitForm({super.key, required this.brandId, this.unitId});

  @override
  State<ScreenUnitForm> createState() => _ScreenUnitFormState();
}

class _ScreenUnitFormState extends State<ScreenUnitForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _decimalAllowed = false;
  bool _isActive = true;
  late final UnitController controller;

  bool get _isEditing => widget.unitId != null;

  @override
  void initState() {
    super.initState();
    controller = Get.find<UnitController>();
    if (_isEditing) {
      final unit = controller.units.firstWhereOrNull((u) => u.id == widget.unitId);
      if (unit != null) {
        _nameController.text = unit.unitName;
        _codeController.text = unit.shortName;
        _decimalAllowed = unit.decimalAllowed;
        _isActive = unit.isActive;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final unit = UnitModel(
      id: widget.unitId ?? '',
      unitName: _nameController.text.trim(),
      shortName: _codeController.text.trim(),
      decimalAllowed: _decimalAllowed,
      isActive: _isActive,
      createdAt: _isEditing
          ? (controller.units.firstWhereOrNull((u) => u.id == widget.unitId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
    );

    final success = _isEditing
        ? await controller.updateUnit(widget.unitId!, unit)
        : await controller.createUnit(unit);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Unit updated' : 'Unit created'), backgroundColor: Colors.green),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Unit' : 'New Unit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextField(
              label: 'Unit Name',
              hint: 'e.g. Kilogram',
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Unit Name is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Short Name / Symbol',
              hint: 'e.g. kg',
              controller: _codeController,
              validator: (v) => v == null || v.isEmpty ? 'Short Name is required' : null,
            ),
            SizedBox(height: AppSpacing.lg),
            AppSwitchField(
              label: 'Decimal Allowed',
              description: 'Whether fractional quantities are allowed for this unit (e.g., 1.5 kg)',
              value: _decimalAllowed,
              onChanged: (val) => setState(() => _decimalAllowed = val),
            ),
            SizedBox(height: AppSpacing.md),
            AppSwitchField(
              label: 'Active Status',
              description: 'Disable to hide this unit from selections',
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(() => AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Unit',
                  isLoading: controller.isLoading.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}
