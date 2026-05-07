import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/brand_repository_impl.dart';
import 'package:back_office/ui/brand/brand_list/cubit_brand.dart';
import 'package:back_office/ui/brand/brand_list/state_brand.dart';
import 'package:back_office/routing/app_routes.dart';
import 'package:back_office/shared/shared.dart';

class ScreenBrandForm extends StatelessWidget {
  final String? brandId;

  const ScreenBrandForm({super.key, this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CubitBrand(repository: BrandRepositoryImpl());
        if (brandId != null) {
          cubit.loadBrand(brandId!);
        }
        return cubit;
      },
      child: _BrandFormView(brandId: brandId),
    );
  }
}

class _BrandFormView extends StatefulWidget {
  final String? brandId;

  const _BrandFormView({this.brandId});

  @override
  State<_BrandFormView> createState() => _BrandFormViewState();
}

class _BrandFormViewState extends State<_BrandFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _gstNoController = TextEditingController();
  final _fssaiNoController = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _gstNoController.dispose();
    _fssaiNoController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.brandId != null;

  void _goBack() {
    if (isEditing) {
      context.go('/brands/${widget.brandId}');
    } else {
      context.go(AppRoutes.brandList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CubitBrand, StateBrand>(
      listener: (context, state) {
        // Pre-fill form fields when editing
        if (state.status == BrandStatus.loaded && state.brand != null && !_prefilled) {
          _nameController.text = state.brand!.displayName;
          _emailController.text = state.brand!.contact.email;
          _phoneController.text = state.brand!.contact.phones.primary;
          _websiteController.text = state.brand!.contact.website;
          _gstNoController.text = state.brand!.registration.gstNo;
          _fssaiNoController.text = state.brand!.registration.fssaiNo;
          _prefilled = true;
        }

        // Navigate on success — only after the API has responded
        if (state.status == BrandStatus.success) {
          showToast(
            context,
            message: isEditing ? 'Brand updated successfully' : 'Brand created successfully',
            status: 'success',
          );
          if (isEditing) {
            context.go('/brands/${widget.brandId}');
          } else {
            context.go(AppRoutes.brandList);
          }
        }

        // Show error
        if (state.status == BrandStatus.error) {
          showToast(context, message: state.errorMessage ?? 'Something went wrong', status: 'error');
        }
      },
      builder: (context, state) {
        final isLoading = state.status == BrandStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Brand' : 'Create Brand'),
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
                      // ── Brand Identity Section ──
                      _SectionHeader(
                        icon: Icons.store,
                        title: 'Brand Identity',
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
                                label: 'Brand Name *',
                                prefixIcon: const Icon(Icons.business),
                                validator: (v) => v?.isEmpty == true ? 'Brand name is required' : null,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // ── Contact Section ──
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
                              SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _websiteController,
                                label: 'Website',
                                prefixIcon: const Icon(Icons.language),
                                keyboardType: TextInputType.url,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // ── Registration Section ──
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

                      SizedBox(height: AppSpacing.xl),

                      // ── Action Buttons ──
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
                              label: Text(isEditing ? 'Update Brand' : 'Create Brand'),
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
      'contact': {
        'email': _emailController.text.trim(),
        'phones': {'primary': _phoneController.text.trim()},
        'website': _websiteController.text.trim(),
      },
      'registration': {
        'gstNo': _gstNoController.text.trim(),
        'fssaiNo': _fssaiNoController.text.trim(),
      },
    };

    if (isEditing) {
      context.read<CubitBrand>().updateBrand(widget.brandId!, data);
    } else {
      context.read<CubitBrand>().createBrand(data);
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