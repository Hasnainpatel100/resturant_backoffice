import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/category_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_category.dart';
import 'state_category.dart';

class ScreenCategoryForm extends StatelessWidget {
  final String brandId;
  final String? categoryId;

  const ScreenCategoryForm({
    super.key,
    required this.brandId,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit =
            CubitCategory(repository: CategoryRepositoryMockImpl());
        if (categoryId != null) {
          cubit.loadCategory(brandId, categoryId!);
        }
        return cubit;
      },
      child: _CategoryFormView(brandId: brandId, categoryId: categoryId),
    );
  }
}

class _CategoryFormView extends StatefulWidget {
  final String brandId;
  final String? categoryId;

  const _CategoryFormView({required this.brandId, this.categoryId});

  @override
  State<_CategoryFormView> createState() => _CategoryFormViewState();
}

class _CategoryFormViewState extends State<_CategoryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isActive = true;
  bool _prefilled = false;

  bool get _isEditing => widget.categoryId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _prefill(StateCategory state) {
    if (_prefilled || state.selected == null) return;
    _prefilled = true;
    final cat = state.selected!;
    _nameController.text = cat.name;
    _descController.text = cat.description ?? '';
    setState(() => _isActive = cat.isActive);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      'isActive': _isActive,
    };

    if (_isEditing) {
      context
          .read<CubitCategory>()
          .updateCategory(widget.brandId, widget.categoryId!, data);
    } else {
      context.read<CubitCategory>().createCategory(widget.brandId, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CubitCategory, StateCategory>(
      listener: (context, state) {
        _prefill(state);
        if (state.status == CategoryStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  _isEditing ? 'Category updated' : 'Category created'),
              backgroundColor: Colors.green,
            ),
          );
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
        if (state.status == CategoryStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: cs.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == CategoryStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Category' : 'New Category'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section header
                  Text(
                    'Category Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Name
                  AppTextField(
                    label: 'Category Name *',
                    hint: 'e.g. Beverages',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Category name is required'
                            : null,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Description
                  AppTextField(
                    label: 'Description',
                    hint: 'Optional short description',
                    controller: _descController,
                    maxLines: 3,
                    minLines: 2,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // ── Status toggle
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text('Active'),
                      subtitle: Text(
                        _isActive
                            ? 'Category is visible and usable'
                            : 'Category is hidden from selection',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // ── Submit button
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
                              _isEditing ? 'Update Category' : 'Create Category',
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
