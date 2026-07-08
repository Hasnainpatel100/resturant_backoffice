import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/supplier_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_supplier.dart';
import 'state_supplier.dart';

class ScreenSupplierForm extends StatelessWidget {
  final String brandId;
  final String? supplierId;

  const ScreenSupplierForm({
    super.key,
    required this.brandId,
    this.supplierId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CubitSupplier(repository: SupplierRepositoryMockImpl());
        if (supplierId != null) {
          cubit.loadSupplier(brandId, supplierId!);
        }
        return cubit;
      },
      child: _SupplierFormView(brandId: brandId, supplierId: supplierId),
    );
  }
}

class _SupplierFormView extends StatefulWidget {
  final String brandId;
  final String? supplierId;

  const _SupplierFormView({required this.brandId, this.supplierId});

  @override
  State<_SupplierFormView> createState() => _SupplierFormViewState();
}

class _SupplierFormViewState extends State<_SupplierFormView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _balController = TextEditingController();

  bool _isActive = true;
  bool _prefilled = false;

  bool get _isEditing => widget.supplierId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _balController.dispose();
    super.dispose();
  }

  void _prefill(StateSupplier state) {
    if (_prefilled || state.selected == null) return;
    _prefilled = true;
    final s = state.selected!;
    _nameController.text = s.name;
    _contactController.text = s.contactPerson ?? '';
    _emailController.text = s.email ?? '';
    _phoneController.text = s.phone ?? '';
    _addressController.text = s.address ?? '';
    _balController.text = s.openingBalance.toStringAsFixed(2);
    setState(() => _isActive = s.isActive);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameController.text.trim(),
      'contactPerson': _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'openingBalance': double.tryParse(_balController.text) ?? 0.0,
      'isActive': _isActive,
    };

    if (_isEditing) {
      context.read<CubitSupplier>().updateSupplier(widget.brandId, widget.supplierId!, data);
    } else {
      context.read<CubitSupplier>().createSupplier(widget.brandId, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CubitSupplier, StateSupplier>(
      listener: (context, state) {
        _prefill(state);
        if (state.status == SupplierStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Supplier details updated' : 'Supplier profile created'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
        if (state.status == SupplierStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: cs.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == SupplierStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Supplier' : 'New Supplier'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supplier Profile Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Name
                  AppTextField(
                    label: 'Supplier Name *',
                    hint: 'e.g. Metro Cash & Carry',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Supplier name is required' : null,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Contact Person
                  AppTextField(
                    label: 'Contact Person',
                    hint: 'e.g. Rahul Sharma',
                    controller: _contactController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Phone
                  AppTextField(
                    label: 'Contact Phone',
                    hint: 'e.g. +91 98765 43210',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Email
                  AppTextField(
                    label: 'Email Address',
                    hint: 'e.g. contact@metro.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Opening Balance
                  AppTextField(
                    label: 'Opening Balance (₹)',
                    hint: '0.00',
                    controller: _balController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    enabled: !_isEditing, // cannot change opening balance after creation
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Address
                  AppTextField(
                    label: 'Address',
                    hint: 'e.g. Chandigarh Industrial Area',
                    controller: _addressController,
                    maxLines: 2,
                    minLines: 2,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Status toggle
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text('Active Status'),
                      subtitle: Text(
                        _isActive ? 'Supplier is active and selectable' : 'Supplier profile is suspended',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // Save
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditing ? 'Update Supplier' : 'Create Supplier',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
