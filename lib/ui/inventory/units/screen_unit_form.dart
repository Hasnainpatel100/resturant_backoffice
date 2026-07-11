import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/unit_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_unit.dart';
import 'state_unit.dart';

class ScreenUnitForm extends StatelessWidget {
  final String brandId;
  final String? unitId;

  const ScreenUnitForm({super.key, required this.brandId, this.unitId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CubitUnit(repository: UnitRepositoryMockImpl());
        if (unitId != null) cubit.loadUnit(brandId, unitId!);
        return cubit;
      },
      child: _UnitFormView(brandId: brandId, unitId: unitId),
    );
  }
}

class _UnitFormView extends StatefulWidget {
  final String brandId;
  final String? unitId;
  const _UnitFormView({required this.brandId, this.unitId});

  @override
  State<_UnitFormView> createState() => _UnitFormViewState();
}

class _UnitFormViewState extends State<_UnitFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isActive = true;
  bool _prefilled = false;

  bool get _isEditing => widget.unitId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _prefill(StateUnit state) {
    if (_prefilled || state.selected == null) return;
    _prefilled = true;
    final unit = state.selected!;
    _nameController.text = unit.name;
    _codeController.text = unit.code;
    setState(() => _isActive = unit.isActive);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'isActive': _isActive,
    };
    if (_isEditing) {
      context
          .read<CubitUnit>()
          .updateUnit(widget.brandId, widget.unitId!, data);
    } else {
      context.read<CubitUnit>().createUnit(widget.brandId, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CubitUnit, StateUnit>(
      listener: (context, state) {
        _prefill(state);
        if (state.status == UnitStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(_isEditing ? 'Unit updated' : 'Unit created'),
              backgroundColor: Colors.green,
            ),
          );
          if (context.mounted) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/brands/${widget.brandId}/inventory/units');
            }
          }
        }
        if (state.status == UnitStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: cs.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == UnitStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Unit' : 'New Unit'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unit Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Name
                  AppTextField(
                    label: 'Unit Name *',
                    hint: 'e.g. Kilogram',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Unit name is required'
                        : null,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Code
                  AppTextField(
                    label: 'Unit Code *',
                    hint: 'e.g. kg',
                    controller: _codeController,
                    textInputAction: TextInputAction.done,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Unit code is required'
                        : null,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Status
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text('Active'),
                      subtitle: Text(
                        _isActive ? 'Unit is available for selection' : 'Unit is hidden',
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
                              _isEditing ? 'Update Unit' : 'Create Unit',
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
