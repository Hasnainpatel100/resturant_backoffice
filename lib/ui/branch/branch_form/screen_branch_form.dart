import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';
import 'package:back_office/shared/shared.dart';

class ScreenBranchForm extends StatelessWidget {
  final String brandId;
  final String? branchId;

  const ScreenBranchForm({super.key, required this.brandId, this.branchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CubitBranch(repository: BranchRepositoryImpl());
        if (branchId != null) {
          cubit.loadBranch(branchId!);
        }
        return cubit;
      },
      child: _BranchFormView(brandId: brandId, branchId: branchId),
    );
  }
}

class _BranchFormView extends StatefulWidget {
  final String brandId;
  final String? branchId;

  const _BranchFormView({required this.brandId, this.branchId});

  @override
  State<_BranchFormView> createState() => _BranchFormViewState();
}

class _BranchFormViewState extends State<_BranchFormView> {
  final _formKey = GlobalKey<FormState>();

  // Basic
  final _nameController = TextEditingController();
  final _branchCodeController = TextEditingController();

  // Contact
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Address
  final _addressFullController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Registration
  final _gstNoController = TextEditingController();
  final _fssaiNoController = TextEditingController();

  // Settings
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();
  bool _isMasterBranch = false;

  bool _prefilled = false;

  bool get isEditing => widget.branchId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _branchCodeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressFullController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _gstNoController.dispose();
    _fssaiNoController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (isEditing) {
      context.go('/brands/${widget.brandId}/branches/${widget.branchId}');
    } else {
      context.go('/brands/${widget.brandId}/branches');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CubitBranch, StateBranch>(
      listener: (context, state) {
        // Pre-fill when editing
        if (state.status == BranchStatus.loaded && state.branch != null && !_prefilled) {
          final b = state.branch!;
          _nameController.text = b.displayName;
          _branchCodeController.text = b.branchCode;
          _emailController.text = b.contact.email;
          _phoneController.text = b.contact.phones.primary;
          _addressFullController.text = b.address.full;
          _cityController.text = b.address.city;
          _stateController.text = b.address.state;
          _countryController.text = b.address.country;
          _zipCodeController.text = b.address.zipCode;
          _gstNoController.text = b.registration.gstNo;
          _fssaiNoController.text = b.registration.fssaiNo;
          _openTimeController.text = b.settings.open;
          _closeTimeController.text = b.settings.close;
          _isMasterBranch = b.settings.isMasterBranch;
          _prefilled = true;
        }

        // Navigate on success
        if (state.status == BranchStatus.success) {
          showToast(
            context,
            message: isEditing ? 'Branch updated successfully' : 'Branch created successfully',
            status: 'success',
          );
          if (isEditing) {
            context.go('/brands/${widget.brandId}/branches/${widget.branchId}');
          } else {
            context.go('/brands/${widget.brandId}/branches');
          }
        }

        // Show error
        if (state.status == BranchStatus.error) {
          showToast(context, message: state.errorMessage ?? 'Something went wrong', status: 'error');
        }
      },
      builder: (context, state) {
        final isLoading = state.status == BranchStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Branch' : 'Create Branch'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goBack,
            ),
          ),
          body: isLoading && !_prefilled && isEditing
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(AppSpacing.md),
                    children: [
                      // ── Branch Identity ──
                      _SectionHeader(
                        icon: Icons.store,
                        title: 'Branch Identity',
                        color: cs.primary,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _nameController,
                                label: 'Branch Name *',
                                prefixIcon: const Icon(Icons.store),
                                validator: (v) =>
                                    v?.isEmpty == true ? 'Branch name is required' : null,
                              ),
                              SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _branchCodeController,
                                label: 'Branch Code',
                                prefixIcon: const Icon(Icons.tag),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // ── Contact ──
                      _SectionHeader(
                        icon: Icons.contact_phone,
                        title: 'Contact Information',
                        color: Colors.teal,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _emailController,
                                label: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _phoneController,
                                label: 'Phone',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // ── Address ──
                      _SectionHeader(
                        icon: Icons.location_on,
                        title: 'Address',
                        color: Colors.blue,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _addressFullController,
                                label: 'Full Address',
                                prefixIcon: const Icon(Icons.home_outlined),
                                maxLines: 2,
                              ),
                              SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _cityController,
                                      label: 'City',
                                      prefixIcon: const Icon(Icons.location_city),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _stateController,
                                      label: 'State',
                                      prefixIcon: const Icon(Icons.map_outlined),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _countryController,
                                      label: 'Country',
                                      prefixIcon: const Icon(Icons.public),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _zipCodeController,
                                      label: 'ZIP Code',
                                      prefixIcon: const Icon(Icons.pin_drop),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // ── Registration ──
                      _SectionHeader(
                        icon: Icons.description,
                        title: 'Registration Details',
                        color: Colors.orange,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _gstNoController,
                                label: 'GST Number',
                                prefixIcon: const Icon(Icons.receipt_long),
                              ),
                              SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _fssaiNoController,
                                label: 'FSSAI Number',
                                prefixIcon: const Icon(Icons.verified_outlined),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // ── Settings ──
                      _SectionHeader(
                        icon: Icons.settings,
                        title: 'Operating Hours',
                        color: Colors.purple,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _openTimeController,
                                      label: 'Opening Time',
                                      hint: 'e.g. 09:00 AM',
                                      prefixIcon: const Icon(Icons.access_time),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _closeTimeController,
                                      label: 'Closing Time',
                                      hint: 'e.g. 11:00 PM',
                                      prefixIcon: const Icon(Icons.access_time_filled),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.md),
                              SwitchListTile(
                                title: const Text('Master Branch'),
                                subtitle:
                                    const Text('This is the primary branch of the brand'),
                                value: _isMasterBranch,
                                onChanged: (v) => setState(() => _isMasterBranch = v),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // ── Actions ──
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : _goBack,
                              icon: const Icon(Icons.close),
                              label: const Text('Cancel'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : _submitForm,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(isEditing ? Icons.save : Icons.add),
                              label: Text(isEditing ? 'Update Branch' : 'Create Branch'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = {
      'name': {'en': _nameController.text.trim()},
      'branchCode': _branchCodeController.text.trim(),
      'contact': {
        'email': _emailController.text.trim(),
        'phones': {'primary': _phoneController.text.trim()},
      },
      'address': {
        'full': _addressFullController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'zipCode': _zipCodeController.text.trim(),
      },
      'registration': {
        'gstNo': _gstNoController.text.trim(),
        'fssaiNo': _fssaiNoController.text.trim(),
      },
      'settings': {
        'open': _openTimeController.text.trim(),
        'close': _closeTimeController.text.trim(),
        'isMasterBranch': _isMasterBranch,
      },
    };

    if (isEditing) {
      context.read<CubitBranch>().updateBranch(widget.branchId!, data);
    } else {
      context.read<CubitBranch>().createBranch(widget.brandId, data);
    }
  }
}

// ---------------------------------------------------------------------------
// Section header widget

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
