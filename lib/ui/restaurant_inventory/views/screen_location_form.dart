import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/location_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenLocationForm extends StatefulWidget {
  final String brandId;
  final String? locationId;
  const ScreenLocationForm({super.key, required this.brandId, this.locationId});

  @override
  State<ScreenLocationForm> createState() => _ScreenLocationFormState();
}

class _ScreenLocationFormState extends State<ScreenLocationForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _managerController = TextEditingController();
  String _locationType = 'warehouse';
  bool _isActive = true;
  String? _branchId;
  late final LocationController controller;
  late final MongoBranchController branchController;

  bool get _isEditing => widget.locationId != null;

  final List<String> _locationTypes = ['warehouse', 'kitchen', 'store', 'outlet'];

  @override
  void initState() {
    super.initState();
    controller = Get.find<LocationController>();
    branchController = Get.put(MongoBranchController(repository: MongoBranchRepositoryImpl()));
    branchController.loadBranches();
    
    if (_isEditing) {
      final loc = controller.locations.firstWhereOrNull((l) => l.id == widget.locationId);
      if (loc != null) {
        _codeController.text = loc.locationCode;
        _nameController.text = loc.locationName;
        _addressController.text = loc.address ?? '';
        _contactController.text = loc.contactNo ?? '';
        _managerController.text = loc.managerName ?? '';
        _locationType = _locationTypes.contains(loc.locationType) ? loc.locationType : 'warehouse';
        _isActive = loc.isActive;
        _branchId = loc.branchId;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _managerController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = LocationModel(
      id: widget.locationId ?? '',
      branchId: _branchId,
      locationCode: _codeController.text.trim(),
      locationName: _nameController.text.trim(),
      locationType: _locationType,
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      contactNo: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      managerName: _managerController.text.trim().isEmpty ? null : _managerController.text.trim(),
      isActive: _isActive,
      createdAt: _isEditing
          ? (controller.locations.firstWhereOrNull((l) => l.id == widget.locationId)?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
    );

    final success = _isEditing
        ? await controller.updateLocation(widget.locationId!, loc)
        : await controller.createLocation(loc);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Location updated' : 'Location created'), backgroundColor: Colors.green),
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
        title: Text(_isEditing ? 'Edit Location' : 'New Location'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextField(
              label: 'Location Code',
              hint: 'e.g. LOC01',
              controller: _codeController,
              validator: (v) => v == null || v.isEmpty ? 'Location Code is required' : null,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Location Name',
              hint: 'e.g. Main Kitchen Store',
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Location Name is required' : null,
            ),
            AppDropdownField<String>(
              label: 'Location Type',
              value: _locationType,
              items: _locationTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _locationType = val ?? 'warehouse'),
            ),
            SizedBox(height: AppSpacing.md),
            Obx(() => AppDropdownField<String>(
                  label: 'Parent Branch Reference (Optional)',
                  value: _branchId,
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('No Branch (Central Inventory)')),
                    ...branchController.branches.map((b) {
                      return DropdownMenuItem<String>(
                        value: b.id,
                        child: Text(b.name.en.isNotEmpty ? b.name.en : b.branchCode),
                      );
                    }),
                  ],
                  onChanged: (val) => setState(() => _branchId = val),
                )),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Manager Name',
              hint: 'e.g. John Doe',
              controller: _managerController,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Contact Number',
              hint: 'e.g. +1234567890',
              controller: _contactController,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Address',
              hint: 'e.g. Ground Floor, Block A',
              controller: _addressController,
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.lg),
            AppSwitchField(
              label: 'Active Status',
              description: 'Whether this location can currently receive or transfer stock',
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(() => AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Location',
                  isLoading: controller.isLoading.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}
