import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_reason_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';

class ScreenStockReasonForm extends StatefulWidget {
  final String brandId;
  final String? reasonId;
  const ScreenStockReasonForm({super.key, required this.brandId, this.reasonId});

  @override
  State<ScreenStockReasonForm> createState() => _ScreenStockReasonFormState();
}

class _ScreenStockReasonFormState extends State<ScreenStockReasonForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _reasonType = 'manual_adjustment';
  bool _isActive = true;
  late final StockReasonController controller;

  bool get _isEditing => widget.reasonId != null;

  final List<String> _reasonTypes = [
    'wastage',
    'theft',
    'manual_adjustment',
    'transfer',
    'internal_consumption',
    'expiry'
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<StockReasonController>();
    if (_isEditing) {
      final r = controller.reasons.firstWhereOrNull((reason) => reason.id == widget.reasonId);
      if (r != null) {
        _nameController.text = r.reasonName;
        _reasonType = _reasonTypes.contains(r.reasonType) ? r.reasonType : 'manual_adjustment';
        _isActive = r.isActive;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final r = StockReasonModel(
      id: widget.reasonId ?? '',
      reasonName: _nameController.text.trim(),
      reasonType: _reasonType,
      isActive: _isActive,
    );

    final success = _isEditing
        ? await controller.updateReason(widget.reasonId!, r)
        : await controller.createReason(r);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Reason updated' : 'Reason created'), backgroundColor: Colors.green),
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
        title: Text(_isEditing ? 'Edit Stock Reason' : 'New Stock Reason'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextField(
              label: 'Reason Name',
              hint: 'e.g. Spoilage / Rotten vegetables',
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Reason Name is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppDropdownField<String>(
              label: 'Reason Category / Type',
              value: _reasonType,
              items: _reasonTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _reasonType = val ?? 'manual_adjustment'),
            ),
            SizedBox(height: AppSpacing.lg),
            AppSwitchField(
              label: 'Active Status',
              description: 'Whether this reason can currently be selected for stock write-offs and corrections',
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(() => AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Stock Reason',
                  isLoading: controller.isLoading.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}
