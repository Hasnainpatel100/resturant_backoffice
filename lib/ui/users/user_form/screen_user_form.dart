import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/user_repository_impl.dart';
import 'package:back_office/ui/users/user_list/cubit_user.dart';
import 'package:back_office/ui/users/user_list/state_user.dart';
import 'package:back_office/shared/shared.dart';

class ScreenUserForm extends StatelessWidget {
  final String brandId;
  final String? userId;

  const ScreenUserForm({super.key, required this.brandId, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CubitUser(repository: UserRepositoryImpl());
        if (userId != null) {
          cubit.loadUser(userId!);
        }
        return cubit;
      },
      child: _UserFormView(brandId: brandId, userId: userId),
    );
  }
}

class _UserFormView extends StatefulWidget {
  final String brandId;
  final String? userId;

  const _UserFormView({required this.brandId, this.userId});

  @override
  State<_UserFormView> createState() => _UserFormViewState();
}

class _UserFormViewState extends State<_UserFormView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  String _selectedRole = 'CASHIER';
  String? _selectedBranchId;
  bool get _isEditing => widget.userId != null;

  final List<String> _roles = ['ADMIN', 'MANAGER', 'CASHIER', 'OWNER'];

  @override
  void initState() {
    super.initState();
    if (widget.userId == null) {
      context.read<CubitUser>().loadBranches(widget.brandId);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CubitUser, StateUser>(
      listener: (context, state) {
        if (state.status == UserStatus.loaded && state.user != null && _firstNameController.text.isEmpty) {
          _firstNameController.text = state.user!.user.firstName;
          _lastNameController.text = state.user!.user.lastName;
          _emailController.text = state.user!.user.email;
          _phoneController.text = state.user!.user.phoneNumber;
          setState(() => _selectedRole = state.user!.user.role);
        }
        if (!_isEditing && _selectedBranchId == null && state.branches.isNotEmpty) {
          _selectedBranchId = state.branches.first.id;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit User' : 'Create User'),
            leading: IconButton(icon: const Icon(Icons.close), onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/brands/${widget.brandId}/users');
              }
            }),
          ),
          body: state.status == UserStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(AppSpacing.md),
                    children: [
                      Text('Personal Information', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(controller: _firstNameController, label: 'First Name'),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(controller: _lastNameController, label: 'Last Name'),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: AppSpacing.xl),
                      Text('Account', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: AppSpacing.md),
                      if (!_isEditing)
                        _buildBranchDropdown(state),
                      SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                        onChanged: (value) => setState(() => _selectedRole = value!),
                      ),
                      SizedBox(height: AppSpacing.md),
                      if (!_isEditing)
                        AppTextField(
                          controller: _pinController,
                          label: 'PIN (4 digits)',
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: (v) {
                            if (v?.length != 4) return 'PIN must be 4 digits';
                            return null;
                          },
                        ),
                      SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(onPressed: () => context.go('/brands/${widget.brandId}/users'), child: const Text('Cancel')),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: _isEditing ? 'Update' : 'Create',
                              isLoading: state.status == UserStatus.loading,
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

  Widget _buildBranchDropdown(StateUser state) {
    if (state.status == UserStatus.loading && state.branches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.branches.isEmpty) {
      return Text(
        'No branches found. Create a branch first.',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: _selectedBranchId,
      decoration: const InputDecoration(labelText: 'Branch'),
      hint: const Text('Select branch'),
      items: state.branches.map((branch) {
        return DropdownMenuItem(
          value: branch.id,
          child: Text(branch.displayName),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedBranchId = value),
    );
  }

  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isEditing && _selectedBranchId == null) {
      showToast(context, message: 'Please select a branch', status: 'error');
      return;
    }

    final data = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneController.text,
      'username': _emailController.text.split('@').first,
      'loginPin': _pinController.text,
      'role': _selectedRole,
      'userType': 'BRAND',
      'brandId': widget.brandId,
      'branchId': _selectedBranchId ?? '',
    };

    if (widget.userId != null) {
      context.read<CubitUser>().updateUser(widget.userId!, data);
      showToast(context, message: 'User updated', status: 'success');
      context.go('/brands/${widget.brandId}/users');
    } else {
      context.read<CubitUser>().createUser(data);
      showToast(context, message: 'User created', status: 'success');
      context.go('/brands/${widget.brandId}/users');
    }
  }
}