import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_tax_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenTaxForm extends StatefulWidget {
  final String brandId;
  final String? taxId;
  const ScreenTaxForm({super.key, required this.brandId, this.taxId});

  @override
  State<ScreenTaxForm> createState() => _ScreenTaxFormState();
}

class _ScreenTaxFormState extends State<ScreenTaxForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  String _taxType = 'percentage';
  String? _groupId;
  bool _isDividable = false;
  bool _includeInRate = false;
  String _appliesOn = 'purchase';
  bool _isActive = true;

  late final RawMaterialTaxController controller;
  late final RawMaterialGroupController groupController;

  bool get _isEditing => widget.taxId != null;

  @override
  void initState() {
    super.initState();
    controller = Get.find<RawMaterialTaxController>();
    groupController = Get.put(RawMaterialGroupController(repository: RawMaterialGroupRepositoryImpl()));
    groupController.loadGroups();

    if (_isEditing) {
      final tax = controller.taxes.firstWhereOrNull((t) => t.id == widget.taxId);
      if (tax != null) {
        _nameController.text = tax.taxName;
        _valueController.text = tax.taxValue.toString();
        _taxType = tax.taxType;
        _groupId = tax.rawMaterialGroupId;
        _isDividable = tax.isDividable;
        _includeInRate = tax.includeInRate;
        _appliesOn = tax.appliesOn;
        _isActive = tax.isActive;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final tax = RawMaterialTaxModel(
      id: widget.taxId ?? '',
      taxName: _nameController.text.trim(),
      taxValue: double.tryParse(_valueController.text.trim()) ?? 0.0,
      taxType: _taxType,
      rawMaterialGroupId: _groupId,
      isDividable: _isDividable,
      includeInRate: _includeInRate,
      appliesOn: _appliesOn,
      isActive: _isActive,
      createdAt: _isEditing
          ? (controller.taxes.firstWhereOrNull((t) => t.id == widget.taxId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
    );

    final success = _isEditing
        ? await controller.updateTax(widget.taxId!, tax)
        : await controller.createTax(tax);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Tax updated' : 'Tax created'), backgroundColor: Colors.green),
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
        title: Text(_isEditing ? 'Edit Tax' : 'New Tax'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextField(
              label: 'Tax Name',
              hint: 'e.g. VAT 5%',
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Tax Name is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    label: 'Tax Value',
                    hint: 'e.g. 5.0',
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Valid Tax Value is required' : null,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 3,
                  child: AppDropdownField<String>(
                    label: 'Tax Type',
                    value: _taxType,
                    items: const [
                      DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                      DropdownMenuItem(value: 'fixed', child: Text('Fixed Rate')),
                    ],
                    onChanged: (val) => setState(() => _taxType = val ?? 'percentage'),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Obx(() => AppDropdownField<String>(
                  label: 'Applies on Group (Optional)',
                  hint: 'Select group',
                  value: _groupId,
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('All Groups')),
                    ...groupController.groups.map((g) {
                      return DropdownMenuItem<String>(
                        value: g.id,
                        child: Text(g.groupName),
                      );
                    }),
                  ],
                  onChanged: (val) => setState(() => _groupId = val),
                )),
            SizedBox(height: AppSpacing.md),
            AppDropdownField<String>(
              label: 'Applies On Transaction',
              value: _appliesOn,
              items: const [
                DropdownMenuItem(value: 'purchase', child: Text('Purchase Only')),
                DropdownMenuItem(value: 'sales', child: Text('Sales Only')),
                DropdownMenuItem(value: 'both', child: Text('Both Purchase & Sales')),
              ],
              onChanged: (val) => setState(() => _appliesOn = val ?? 'purchase'),
            ),
            SizedBox(height: AppSpacing.lg),
            AppSwitchField(
              label: 'Include In Rate',
              description: 'Whether this tax is pre-included in the item rate',
              value: _includeInRate,
              onChanged: (val) => setState(() => _includeInRate = val),
            ),
            SizedBox(height: AppSpacing.md),
            AppSwitchField(
              label: 'Is Dividable',
              description: 'Whether the tax rate can be split or divided',
              value: _isDividable,
              onChanged: (val) => setState(() => _isDividable = val),
            ),
            SizedBox(height: AppSpacing.md),
            AppSwitchField(
              label: 'Active Status',
              description: 'Disable to deactivate this tax rule',
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(() => AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Tax',
                  isLoading: controller.isLoading.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}
