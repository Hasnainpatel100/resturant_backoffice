import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_warehouse.dart';
import 'state_warehouse.dart';

class ScreenWarehouseForm extends StatelessWidget {
  final String brandId;
  final String? warehouseId;

  const ScreenWarehouseForm({
    super.key,
    required this.brandId,
    this.warehouseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit =
            CubitWarehouse(repository: WarehouseRepositoryMockImpl());
        if (warehouseId != null) cubit.loadWarehouse(brandId, warehouseId!);
        return cubit;
      },
      child: _WarehouseFormView(brandId: brandId, warehouseId: warehouseId),
    );
  }
}

class _WarehouseFormView extends StatefulWidget {
  final String brandId;
  final String? warehouseId;

  const _WarehouseFormView({required this.brandId, this.warehouseId});

  @override
  State<_WarehouseFormView> createState() => _WarehouseFormViewState();
}

class _WarehouseFormViewState extends State<_WarehouseFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isActive = true;
  bool _prefilled = false;

  bool get _isEditing => widget.warehouseId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _prefill(StateWarehouse state) {
    if (_prefilled || state.selected == null) return;
    _prefilled = true;
    final wh = state.selected!;
    _nameController.text = wh.name;
    _addressController.text = wh.address ?? '';
    setState(() => _isActive = wh.isActive);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      'isActive': _isActive,
    };
    if (_isEditing) {
      context
          .read<CubitWarehouse>()
          .updateWarehouse(widget.brandId, widget.warehouseId!, data);
    } else {
      context.read<CubitWarehouse>().createWarehouse(widget.brandId, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CubitWarehouse, StateWarehouse>(
      listener: (context, state) {
        _prefill(state);
        if (state.status == WarehouseStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  _isEditing ? 'Warehouse updated' : 'Warehouse created'),
              backgroundColor: Colors.green,
            ),
          );
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
        if (state.status == WarehouseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: cs.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == WarehouseStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Warehouse' : 'New Warehouse'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warehouse Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: 'Warehouse Name *',
                    hint: 'e.g. Main Kitchen Store',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Warehouse name is required'
                        : null,
                  ),
                  SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: 'Address / Location',
                    hint: 'e.g. Ground Floor, Kitchen Block',
                    controller: _addressController,
                    maxLines: 2,
                    minLines: 2,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text('Active'),
                      subtitle: Text(
                        _isActive
                            ? 'Warehouse is operational'
                            : 'Warehouse is inactive',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

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
                              _isEditing
                                  ? 'Update Warehouse'
                                  : 'Create Warehouse',
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
