
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/user_repository_impl.dart';
import 'package:back_office/ui/users/user_list/cubit_user.dart';
import 'package:back_office/ui/users/user_list/state_user.dart';
import 'package:back_office/shared/shared.dart';

/// All available permissions matching the API spec.
const List<String> _allPermissions = [
  'USER_CREATE',
  'USER_READ',
  'USER_UPDATE',
  'USER_DELETE',
  'ORDER_CREATE',
  'ORDER_READ',
  'ORDER_UPDATE',
  'ORDER_DELETE',
  'PAYMENT_PROCESS',
  'REFUND_PROCESS',
  'REPORT_VIEW',
  'REPORT_EXPORT',
  'REPORT_CREATE',
  'REPORT_UPDATE',
  'REPORT_DELETE',
  'INVENTORY_CREATE',
  'INVENTORY_READ',
  'INVENTORY_UPDATE',
  'INVENTORY_DELETE',
  'DEVICE_MANAGE',
  'BRANCH_CREATE',
  'BRANCH_READ',
  'BRANCH_UPDATE',
  'BRANCH_DELETE',
  'RESTAURANT_READ',
  'RESTAURANT_UPDATE',
  'DASHBOARD_VIEW',
  'DASHBOARD_EXPORT',
  'EXPENSE_CREATE',
  'EXPENSE_READ',
  'EXPENSE_UPDATE',
  'EXPENSE_DELETE',
  'EXPENSE_APPROVE',
  'ACCOUNT_CREATE',
  'ACCOUNT_READ',
  'ACCOUNT_UPDATE',
  'ACCOUNT_DELETE',
  'ACCOUNT_MANAGE',
];

/// Grouped permissions for better UX in the form.
const Map<String, List<String>> _permissionGroups = {
  'User': ['USER_CREATE', 'USER_READ', 'USER_UPDATE', 'USER_DELETE'],
  'Order': ['ORDER_CREATE', 'ORDER_READ', 'ORDER_UPDATE', 'ORDER_DELETE'],
  'Payment': ['PAYMENT_PROCESS', 'REFUND_PROCESS'],
  'Report': ['REPORT_VIEW', 'REPORT_EXPORT', 'REPORT_CREATE', 'REPORT_UPDATE', 'REPORT_DELETE'],
  'Inventory': ['INVENTORY_CREATE', 'INVENTORY_READ', 'INVENTORY_UPDATE', 'INVENTORY_DELETE'],
  'Device': ['DEVICE_MANAGE'],
  'Branch': ['BRANCH_CREATE', 'BRANCH_READ', 'BRANCH_UPDATE', 'BRANCH_DELETE'],
  'Restaurant': ['RESTAURANT_READ', 'RESTAURANT_UPDATE'],
  'Dashboard': ['DASHBOARD_VIEW', 'DASHBOARD_EXPORT'],
  'Expense': ['EXPENSE_CREATE', 'EXPENSE_READ', 'EXPENSE_UPDATE', 'EXPENSE_DELETE', 'EXPENSE_APPROVE'],
  'Account': ['ACCOUNT_CREATE', 'ACCOUNT_READ', 'ACCOUNT_UPDATE', 'ACCOUNT_DELETE', 'ACCOUNT_MANAGE'],
};

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
        } else {
          cubit.loadBranches(brandId);
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

  // Core fields matching the API
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  String _selectedRole = 'SUPPORT_TEAM';
  String _selectedUserType = 'PLATFORM';
  String? _selectedBranchId;
  List<String> _selectedPermissions = [];

  bool get _isEditing => widget.userId != null;

  final List<String> _roles = [
    'ADMIN',
    'MANAGER',
    'CASHIER',
    'OWNER',
    'SUPPORT_TEAM',
  ];

  final List<String> _userTypes = [
    'PLATFORM',
    'BRAND',
    'BRANCH',
  ];

  bool _dataPopulated = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _populateData(StateUser state) {
    if (state.user == null || _dataPopulated) return;
    _dataPopulated = true;

    final user = state.user!.user;
    _firstNameCtrl.text = user.firstName;
    _lastNameCtrl.text = user.lastName;
    _usernameCtrl.text = user.username;
    _emailCtrl.text = user.email;
    _phoneCtrl.text = user.phoneNumber;
    
    // Ensure the role exists in the dropdown list, otherwise default or add it
    if (user.role.isNotEmpty) {
      if (_roles.contains(user.role)) {
        _selectedRole = user.role;
      } else {
        _roles.add(user.role);
        _selectedRole = user.role;
      }
    }

    if (user.userType.isNotEmpty) {
      if (_userTypes.contains(user.userType)) {
        _selectedUserType = user.userType;
      } else {
        _userTypes.add(user.userType);
        _selectedUserType = user.userType;
      }
    }

    _selectedBranchId = user.branchId.isNotEmpty ? user.branchId : null;
    _selectedPermissions = List<String>.from(user.permissions);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CubitUser, StateUser>(
      listener: (context, state) {
        if (state.status == UserStatus.loaded && !_submitting) {
          _populateData(state);
        }
        if (!_isEditing && _selectedBranchId == null && state.branches.isNotEmpty) {
          _selectedBranchId = state.branches.first.id;
        }
        // Navigate on successful save
        if (_submitting && state.status == UserStatus.loaded) {
          _submitting = false;
          if (_isEditing) {
            showToast(context, message: 'User updated successfully', status: 'success');
            context.go('/brands/${widget.brandId}/users/${widget.userId}');
          } else {
            showToast(context, message: 'User created successfully', status: 'success');
            // Navigate to the newly created user's detail screen
            final newUserId = state.user?.user.id ?? '';
            if (newUserId.isNotEmpty) {
              context.go('/brands/${widget.brandId}/users/$newUserId');
            } else {
              context.go('/brands/${widget.brandId}/users');
            }
          }
        }
        if (state.status == UserStatus.error && state.errorMessage != null) {
          _submitting = false;
          showToast(context, message: state.errorMessage!, status: 'error');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Update User' : 'Create User'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/brands/${widget.brandId}/users');
                }
              },
            ),
          ),
          body: state.status == UserStatus.loading && state.user == null && _isEditing
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    children: [
                      if (!_isEditing) ..._buildCreateFields(state),
                      if (_isEditing)
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.lg),
                          child: Text(
                            'Update Permissions',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (_isEditing)
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: Text(
                            'You can only modify the permissions for this user.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                      if (!_isEditing) SizedBox(height: AppSpacing.lg),
                      _buildPermissionsSection(),
                      SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/brands/${widget.brandId}/users'),
                      child: const Text('Cancel'),
                    ),
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
            ),
          ),
        );
      },
    );
  }

  /// Build fields shown only when creating a new user.
  List<Widget> _buildCreateFields(StateUser state) {
    final cs = Theme.of(context).colorScheme;

    return [
      Text(
        'Basic Information',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: AppSpacing.sm),
      Text(
        'Enter the fundamental details for this user.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.outline),
      ),
      SizedBox(height: AppSpacing.md),
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.lg,
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        color: cs.surface,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      decoration: InputDecoration(
                        labelText: 'User Type',
                        border: OutlineInputBorder(borderRadius: AppBorders.sm),
                        filled: true,
                        fillColor: cs.surfaceContainerLowest,
                      ),
                      items: _userTypes
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: _isEditing ? null : (value) => setState(() => _selectedUserType = value!),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(borderRadius: AppBorders.sm),
                        filled: true,
                        fillColor: cs.surfaceContainerLowest,
                      ),
                      items: _roles
                          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
                      onChanged: _isEditing ? null : (value) => setState(() => _selectedRole = value!),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstNameCtrl,
                      label: 'First Name',
                      readOnly: _isEditing,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _lastNameCtrl,
                      label: 'Last Name',
                      readOnly: _isEditing,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _usernameCtrl,
                label: 'Username',
                readOnly: _isEditing,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              if (!_isEditing) ...[
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _pinCtrl,
                  label: 'Login PIN (6 digits)',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  readOnly: _isEditing,
                  validator: (v) => v == null || v.length != 6 ? 'PIN must be 6 digits' : null,
                ),
              ],
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      readOnly: _isEditing,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      readOnly: _isEditing,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              _buildBranchDropdown(state),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildBranchDropdown(StateUser state) {
    final cs = Theme.of(context).colorScheme;
    if (state.status == UserStatus.loading && state.branches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.branches.isEmpty) {
      return Text(
        'No branches found. Create a branch first.',
        style: TextStyle(color: cs.error),
      );
    }
    
    // Ensure selected branch exists in the list
    if (_selectedBranchId != null && !state.branches.any((b) => b.id == _selectedBranchId)) {
      _selectedBranchId = null;
    }

    return DropdownButtonFormField<String>(
      value: _selectedBranchId,
      decoration: InputDecoration(
        labelText: 'Branch (Optional)',
        border: OutlineInputBorder(borderRadius: AppBorders.sm),
        filled: true,
        fillColor: cs.surfaceContainerLowest,
      ),
      hint: const Text('Select branch'),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('None (Brand Level)')),
        ...state.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.displayName))),
      ],
      onChanged: _isEditing ? null : (value) => setState(() => _selectedBranchId = value),
    );
  }

  /// Build the permissions section with categorized checkboxes.
  Widget _buildPermissionsSection() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with select all / deselect all
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Permissions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPermissions = List<String>.from(_allPermissions);
                    });
                  },
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPermissions = [];
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          '${_selectedPermissions.length} of ${_allPermissions.length} selected',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline),
        ),
        SizedBox(height: AppSpacing.md),

        // Permission groups
        ..._permissionGroups.entries.map((entry) {
          final groupName = entry.key;
          final groupPerms = entry.value;
          final allSelected = groupPerms.every((p) => _selectedPermissions.contains(p));
          final someSelected = groupPerms.any((p) => _selectedPermissions.contains(p));

          return Card(
            margin: EdgeInsets.only(bottom: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppBorders.lg,
              side: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
            ),
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                backgroundColor: cs.surfaceContainerLowest,
                collapsedBackgroundColor: cs.surface,
                leading: Checkbox(
                  value: allSelected
                      ? true
                      : someSelected
                          ? null
                          : false,
                  tristate: true,
                  onChanged: (value) {
                    setState(() {
                      if (allSelected) {
                        _selectedPermissions.removeWhere((p) => groupPerms.contains(p));
                      } else {
                        for (final p in groupPerms) {
                          if (!_selectedPermissions.contains(p)) {
                            _selectedPermissions.add(p);
                          }
                        }
                      }
                    });
                  },
                ),
                title: Text(
                  groupName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                subtitle: Text(
                  '${groupPerms.where((p) => _selectedPermissions.contains(p)).length} of ${groupPerms.length} assigned',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline),
                ),
                children: [
                  Container(
                    color: cs.surface,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: groupPerms.map((perm) {
                        final isSelected = _selectedPermissions.contains(perm);
                        final displayName = perm.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
                          return word[0].toUpperCase() + word.substring(1);
                        }).join(' ');

                        return FilterChip(
                          selected: isSelected,
                          label: Text(displayName, style: TextStyle(fontSize: 13)),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPermissions.add(perm);
                              } else {
                                _selectedPermissions.remove(perm);
                              }
                            });
                          },
                          backgroundColor: cs.surfaceContainerHigh,
                          selectedColor: cs.primaryContainer,
                          checkmarkColor: cs.onPrimaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: AppBorders.sm),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _submitForm() {
    if (!_isEditing && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _submitting = true);

    if (_isEditing) {
      // The update API only takes permissions
      final data = {
        'permissions': _selectedPermissions,
      };
      context.read<CubitUser>().updateUser(widget.userId!, data);
    } else {
      // Create user sends all fields
      final data = {
        'brandId': widget.brandId,
        'branchId': _selectedBranchId,
        'userType': _selectedUserType,
        'role': _selectedRole,
        'firstName': _firstNameCtrl.text,
        'lastName': _lastNameCtrl.text,
        'username': _usernameCtrl.text,
        if (_pinCtrl.text.isNotEmpty) 'loginPin': _pinCtrl.text,
        'email': _emailCtrl.text,
        'phoneNumber': _phoneCtrl.text,
        'permissions': _selectedPermissions,
      };
      context.read<CubitUser>().createUser(data);
    }
    // Navigation is handled in BlocConsumer listener after API responds
  }
}