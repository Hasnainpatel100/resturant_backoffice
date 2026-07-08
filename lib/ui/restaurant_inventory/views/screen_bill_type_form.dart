import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/bill_type_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';

class ScreenBillTypeForm extends StatefulWidget {
  final String brandId;
  final String? billTypeId;
  const ScreenBillTypeForm({super.key, required this.brandId, this.billTypeId});

  @override
  State<ScreenBillTypeForm> createState() => _ScreenBillTypeFormState();
}

class _ScreenBillTypeFormState extends State<ScreenBillTypeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _remarkController = TextEditingController();
  bool _isActive = true;
  late final BillTypeController controller;

  bool get _isEditing => widget.billTypeId != null;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BillTypeController>();
    if (_isEditing) {
      final bt = controller.billTypes.firstWhereOrNull((b) => b.id == widget.billTypeId);
      if (bt != null) {
        _nameController.text = bt.billTypeName;
        _remarkController.text = bt.remark ?? '';
        _isActive = bt.isActive;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bt = BillTypeModel(
      id: widget.billTypeId ?? '',
      billTypeName: _nameController.text.trim(),
      remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
      isActive: _isActive,
      createdAt: _isEditing
          ? (controller.billTypes.firstWhereOrNull((b) => b.id == widget.billTypeId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
    );

    final success = _isEditing
        ? await controller.updateBillType(widget.billTypeId!, bt)
        : await controller.createBillType(bt);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Bill type updated' : 'Bill type created'), backgroundColor: Colors.green),
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
        title: Text(_isEditing ? 'Edit Bill Type' : 'New Bill Type'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextField(
              label: 'Bill Type Name',
              hint: 'e.g. Credit Invoice',
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Bill Type Name is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Remark',
              hint: 'e.g. Purchases paid via monthly invoice cycle',
              controller: _remarkController,
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.lg),
            AppSwitchField(
              label: 'Active Status',
              description: 'Whether this billing method is currently active for goods receipts and purchases',
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(() => AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Bill Type',
                  isLoading: controller.isLoading.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}
