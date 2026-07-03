import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/category_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/unit_repository_mock_impl.dart';
import 'package:back_office/data/models/inventory/inventory_category_model.dart';
import 'package:back_office/data/models/inventory/unit_model.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_item.dart';
import 'state_item.dart';

class ScreenItemForm extends StatelessWidget {
  final String brandId;
  final String? itemId;

  const ScreenItemForm({super.key, required this.brandId, this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CubitItem(
          itemRepository: ItemRepositoryMockImpl(),
          categoryRepository: CategoryRepositoryMockImpl(),
          unitRepository: UnitRepositoryMockImpl(),
        );
        if (itemId != null) {
          cubit.loadItem(brandId, itemId!);
          cubit.loadDropdowns(brandId);
        } else {
          cubit.loadDropdowns(brandId);
        }
        return cubit;
      },
      child: _ItemFormView(brandId: brandId, itemId: itemId),
    );
  }
}

class _ItemFormView extends StatefulWidget {
  final String brandId;
  final String? itemId;

  const _ItemFormView({required this.brandId, this.itemId});

  @override
  State<_ItemFormView> createState() => _ItemFormViewState();
}

class _ItemFormViewState extends State<_ItemFormView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _alertQtyController = TextEditingController();
  final _descController = TextEditingController();

  InventoryCategoryModel? _selectedCategory;
  UnitModel? _selectedUnit;
  bool _isActive = true;
  bool _prefilled = false;

  bool get _isEditing => widget.itemId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _currentStockController.dispose();
    _alertQtyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _prefill(StateItem state) {
    if (_prefilled || state.selected == null || state.categories.isEmpty) return;
    _prefilled = true;
    final item = state.selected!;
    _nameController.text = item.name;
    _skuController.text = item.sku ?? '';
    _barcodeController.text = item.barcode ?? '';
    _costPriceController.text = item.costPrice.toStringAsFixed(2);
    _sellingPriceController.text = item.sellingPrice.toStringAsFixed(2);
    _currentStockController.text = item.currentStock.toStringAsFixed(2);
    _alertQtyController.text = item.alertQty.toStringAsFixed(2);
    _descController.text = item.description ?? '';
    setState(() {
      _isActive = item.isActive;
      _selectedCategory = state.categories
          .where((c) => c.id == item.categoryId)
          .firstOrNull;
      _selectedUnit = state.units
          .where((u) => u.id == item.unitId)
          .firstOrNull;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameController.text.trim(),
      'sku': _skuController.text.trim().isEmpty
          ? null
          : _skuController.text.trim(),
      'barcode': _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      'categoryId': _selectedCategory?.id,
      'categoryName': _selectedCategory?.name,
      'unitId': _selectedUnit?.id,
      'unitName': _selectedUnit?.name,
      'unitCode': _selectedUnit?.code,
      'costPrice': double.tryParse(_costPriceController.text) ?? 0.0,
      'sellingPrice': double.tryParse(_sellingPriceController.text) ?? 0.0,
      'currentStock': double.tryParse(_currentStockController.text) ?? 0.0,
      'alertQty': double.tryParse(_alertQtyController.text) ?? 0.0,
      'description': _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      'isActive': _isActive,
    };

    if (_isEditing) {
      context.read<CubitItem>().updateItem(widget.brandId, widget.itemId!, data);
    } else {
      context.read<CubitItem>().createItem(widget.brandId, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CubitItem, StateItem>(
      listener: (context, state) {
        _prefill(state);
        if (state.status == ItemStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Item updated' : 'Item created'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
        if (state.status == ItemStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: cs.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ItemStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Item' : 'New Item'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Basic Info ─────────────────────────────────────────────
                  _SectionHeader(title: 'Basic Information', icon: Icons.info_outline, color: cs.primary),
                  SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: 'Item Name *',
                    hint: 'e.g. Basmati Rice',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Item name is required'
                        : null,
                  ),
                  SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'SKU / Item Code',
                          hint: 'e.g. SKU-001',
                          controller: _skuController,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: 'Barcode',
                          hint: 'Optional barcode',
                          controller: _barcodeController,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Category
                  AppDropdownField<InventoryCategoryModel>(
                    label: 'Category',
                    hint: 'Select category',
                    value: _selectedCategory,
                    expands: true,
                    items: state.categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Unit
                  AppDropdownField<UnitModel>(
                    label: 'Unit of Measurement',
                    hint: 'Select unit',
                    value: _selectedUnit,
                    expands: true,
                    items: state.units
                        .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(u.displayLabel),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedUnit = v),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // ── Pricing ────────────────────────────────────────────────
                  _SectionHeader(title: 'Pricing', icon: Icons.attach_money, color: cs.tertiary),
                  SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Cost Price (₹)',
                          hint: '0.00',
                          controller: _costPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: 'Selling Price (₹)',
                          hint: '0.00',
                          controller: _sellingPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // ── Stock ──────────────────────────────────────────────────
                  _SectionHeader(title: 'Stock', icon: Icons.inventory_outlined, color: cs.secondary),
                  SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Opening Stock',
                          hint: '0',
                          controller: _currentStockController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: 'Alert Quantity',
                          hint: '0',
                          controller: _alertQtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          suffixIcon: const Tooltip(
                            message: 'Get alerted when stock falls below this level',
                            child: Icon(Icons.info_outline, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // ── Description ────────────────────────────────────────────
                  _SectionHeader(title: 'Additional Info', icon: Icons.notes, color: cs.outline),
                  SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: 'Description',
                    hint: 'Optional notes about this item',
                    controller: _descController,
                    maxLines: 3,
                    minLines: 2,
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
                        _isActive ? 'Item is available' : 'Item is inactive',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // Submit
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
                              _isEditing ? 'Update Item' : 'Create Item',
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: color.withOpacity(0.3))),
      ],
    );
  }
}
