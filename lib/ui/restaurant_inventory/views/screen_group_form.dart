import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_group_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';

class ScreenGroupForm extends StatefulWidget {
  final String brandId;
  final String? groupId;
  const ScreenGroupForm({super.key, required this.brandId, this.groupId});

  @override
  State<ScreenGroupForm> createState() => _ScreenGroupFormState();
}

class _ScreenGroupFormState extends State<ScreenGroupForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isActive = true;
  late final RawMaterialGroupController controller;

  bool get _isEditing => widget.groupId != null;

  @override
  void initState() {
    super.initState();
    controller = Get.find<RawMaterialGroupController>();
    if (_isEditing) {
      final grp = controller.groups.firstWhereOrNull((g) => g.id == widget.groupId);
      if (grp != null) {
        _codeController.text = grp.groupCode;
        _nameController.text = grp.groupName;
        _descController.text = grp.description ?? '';
        _isActive = grp.isActive;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final grp = RawMaterialGroupModel(
      id: widget.groupId ?? '',
      groupCode: _codeController.text.trim(),
      groupName: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      isActive: _isActive,
      createdAt: _isEditing
          ? (controller.groups.firstWhereOrNull((g) => g.id == widget.groupId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
    );

    final success = _isEditing
        ? await controller.updateGroup(widget.groupId!, grp)
        : await controller.createGroup(grp);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Group updated' : 'Group created'), backgroundColor: Colors.green),
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
        title: Text(_isEditing ? 'Edit Group' : 'New Group'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextField(
              label: 'Group Code',
              hint: 'e.g. GR01',
              controller: _codeController,
              validator: (v) => v == null || v.isEmpty ? 'Group Code is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Group Name',
              hint: 'e.g. Meat & Poultry',
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Group Name is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Description',
              hint: 'e.g. All fresh and frozen meat ingredients',
              controller: _descController,
              maxLines: 3,
            ),
            SizedBox(height: AppSpacing.lg),
            AppSwitchField(
              label: 'Active Status',
              description: 'Disable to prevent adding new raw materials under this group',
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(() => AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Group',
                  isLoading: controller.isLoading.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}
