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
  final _gstNoController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gstNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.brandId != null;

    return BlocConsumer<CubitBrand, StateBrand>(
      listener: (context, state) {
        if (state.status == BrandStatus.loaded && state.brand != null && _nameController.text.isEmpty) {
          _nameController.text = state.brand!.displayName;
          _emailController.text = state.brand!.contact.email;
          _phoneController.text = state.brand!.contact.phones.primary;
          _gstNoController.text = state.brand!.registration.gstNo;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Brand' : 'Create Brand'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                if (widget.brandId != null) {
                  context.go('/brands/${widget.brandId}');
                } else {
                  try {
                    context.pop();
                  } catch (_) {}
                }
              },
            ),
          ),
          body: state.status == BrandStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(AppSpacing.md),
                    children: [
                      Text('Basic Information', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _nameController,
                        label: 'Brand Name',
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text('Contact Information', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text('Registration', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _gstNoController,
                        label: 'GST Number',
                      ),
                      SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                if (widget.brandId != null) {
                                  context.go('/brands/${widget.brandId}');
                                } else {
                                  try {
                                    context.pop();
                                  } catch (_) {}
                                }
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: isEditing ? 'Update' : 'Create',
                              isLoading: state.status == BrandStatus.loading,
                              onPressed: _submitForm,
                            ),
                          ),
                        ],
                      ),
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
      'name': {'en': _nameController.text},
      'contact': {
        'email': _emailController.text,
        'phones': {'primary': _phoneController.text},
      },
      'registration': {'gstNo': _gstNoController.text},
    };

    if (widget.brandId != null) {
      context.read<CubitBrand>().updateBrand(widget.brandId!, data);
      showToast(context, message: 'Brand updated', status: 'success');
      context.go('/brands/${widget.brandId}');
    } else {
      context.read<CubitBrand>().createBrand(data);
      showToast(context, message: 'Brand created', status: 'success');
      context.go(AppRoutes.brandList);
    }
  }
}