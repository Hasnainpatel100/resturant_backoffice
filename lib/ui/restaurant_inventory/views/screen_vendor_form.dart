import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/vendor_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';

class ScreenVendorForm extends StatefulWidget {
  final String brandId;
  final String? supplierId;
  const ScreenVendorForm({super.key, required this.brandId, this.supplierId});

  @override
  State<ScreenVendorForm> createState() => _ScreenVendorFormState();
}

class _ScreenVendorFormState extends State<ScreenVendorForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNoController = TextEditingController();
  final _creditDaysController = TextEditingController();
  final _balanceController = TextEditingController();

  String _balanceType = 'credit';
  bool _isActive = true;
  late final VendorController controller;

  bool get _isEditing => widget.supplierId != null;

  @override
  void initState() {
    super.initState();
    controller = Get.find<VendorController>();
    if (_isEditing) {
      final v = controller.vendors.firstWhereOrNull((v) => v.id == widget.supplierId);
      if (v != null) {
        _codeController.text = v.vendorCode;
        _nameController.text = v.vendorName;
        _contactController.text = v.contactPerson ?? '';
        _phoneController.text = v.phone ?? '';
        _emailController.text = v.email ?? '';
        _addressController.text = v.address ?? '';
        _taxNoController.text = v.taxNumber ?? '';
        _creditDaysController.text = v.creditDays.toString();
        _balanceController.text = v.openingBalance.toString();
        _balanceType = v.balanceType;
        _isActive = v.isActive;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _taxNoController.dispose();
    _creditDaysController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final v = VendorModel(
      id: widget.supplierId ?? '',
      vendorCode: _codeController.text.trim(),
      vendorName: _nameController.text.trim(),
      contactPerson: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      taxNumber: _taxNoController.text.trim().isEmpty ? null : _taxNoController.text.trim(),
      creditDays: int.tryParse(_creditDaysController.text.trim()) ?? 0,
      openingBalance: double.tryParse(_balanceController.text.trim()) ?? 0.0,
      balanceType: _balanceType,
      isActive: _isActive,
      createdAt: _isEditing
          ? (controller.vendors.firstWhereOrNull((v) => v.id == widget.supplierId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
    );

    final success = _isEditing
        ? await controller.updateVendor(widget.supplierId!, v)
        : await controller.createVendor(v);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Vendor updated' : 'Vendor created'), backgroundColor: Colors.green),
      );
      if (context.mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/brands/${widget.brandId}/inventory/suppliers');
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
        title: Text(_isEditing ? 'Edit Vendor' : 'New Vendor'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextField(
              label: 'Vendor Code',
              hint: 'e.g. VEN001',
              controller: _codeController,
              validator: (v) => v == null || v.isEmpty ? 'Vendor Code is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Vendor Name',
              hint: 'e.g. Sysco Food Supplies',
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Vendor Name is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Contact Person',
              hint: 'e.g. Jane Smith',
              controller: _contactController,
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Phone Number',
                    hint: 'e.g. +12345678',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Email',
                    hint: 'e.g. sales@sysco.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Tax Registration Number / GSTIN',
              hint: 'e.g. TAX-987654321',
              controller: _taxNoController,
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Credit Days',
                    hint: 'e.g. 30',
                    controller: _creditDaysController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Opening Balance',
                    hint: 'e.g. 1000.0',
                    controller: _balanceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Balance Type',
                    value: _balanceType,
                    items: const [
                      DropdownMenuItem(value: 'credit', child: Text('Credit (Owe)')),
                      DropdownMenuItem(value: 'debit', child: Text('Debit (Advance)')),
                    ],
                    onChanged: (val) => setState(() => _balanceType = val ?? 'credit'),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Address',
              hint: 'e.g. 123 Industrial Area, Suite 4',
              controller: _addressController,
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.lg),
            AppSwitchField(
              label: 'Active Status',
              description: 'Whether this vendor is currently active for creating purchase orders',
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(() => AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Vendor',
                  isLoading: controller.isLoading.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}
