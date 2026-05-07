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

class _UserFormViewState extends State<_UserFormView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Core Info
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  String _selectedRole = 'CASHIER';
  String? _selectedBranchId;
  
  // Employment Info
  final _employeeIdCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _shiftCtrl = TextEditingController();
  final _joinDateCtrl = TextEditingController();

  // Personal Details
  final _dobCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();

  // Address
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  // Emergency Contact
  final _emNameCtrl = TextEditingController();
  final _emRelCtrl = TextEditingController();
  final _emPhoneCtrl = TextEditingController();

  // Bank Details
  final _bankNameCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  final _accountNumCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _branchNameCtrl = TextEditingController();

  bool get _isEditing => widget.userId != null;
  final List<String> _roles = ['ADMIN', 'MANAGER', 'CASHIER', 'OWNER'];
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    _employeeIdCtrl.dispose();
    _departmentCtrl.dispose();
    _designationCtrl.dispose();
    _shiftCtrl.dispose();
    _joinDateCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
    _fatherNameCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCodeCtrl.dispose();
    _countryCtrl.dispose();
    _emNameCtrl.dispose();
    _emRelCtrl.dispose();
    _emPhoneCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNameCtrl.dispose();
    _accountNumCtrl.dispose();
    _ifscCtrl.dispose();
    _branchNameCtrl.dispose();
    super.dispose();
  }

  void _populateData(StateUser state) {
    if (state.user == null || _firstNameCtrl.text.isNotEmpty) return;
    
    final user = state.user!.user;
    final details = state.user!.userDetails;

    _firstNameCtrl.text = user.firstName;
    _lastNameCtrl.text = user.lastName;
    _emailCtrl.text = user.email;
    _phoneCtrl.text = user.phoneNumber;
    _selectedRole = user.role;
    
    if (details != null) {
      _employeeIdCtrl.text = details.employeeId ?? '';
      _departmentCtrl.text = details.department ?? '';
      _designationCtrl.text = details.designation ?? '';
      _shiftCtrl.text = details.shift ?? '';
      _joinDateCtrl.text = details.joinDate ?? '';
      
      _dobCtrl.text = details.dateOfBirth ?? '';
      _genderCtrl.text = details.gender ?? '';
      _fatherNameCtrl.text = details.fatherName ?? '';

      if (details.address != null) {
        _streetCtrl.text = details.address!.street;
        _cityCtrl.text = details.address!.city;
        _stateCtrl.text = details.address!.state;
        _postalCodeCtrl.text = details.address!.postalCode;
        _countryCtrl.text = details.address!.country;
      }

      if (details.emergencyContact != null) {
        _emNameCtrl.text = details.emergencyContact!.name;
        _emRelCtrl.text = details.emergencyContact!.relationship;
        _emPhoneCtrl.text = details.emergencyContact!.phone;
      }

      if (details.bankDetails != null) {
        _bankNameCtrl.text = details.bankDetails!.bankName ?? '';
        _accountNameCtrl.text = details.bankDetails!.accountHolderName ?? '';
        _accountNumCtrl.text = details.bankDetails!.accountNumber ?? '';
        _ifscCtrl.text = details.bankDetails!.ifscCode ?? '';
        _branchNameCtrl.text = details.bankDetails!.branchName ?? '';
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CubitUser, StateUser>(
      listener: (context, state) {
        if (state.status == UserStatus.loaded) {
          _populateData(state);
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
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Basic Info'),
                Tab(text: 'Employment'),
                Tab(text: 'Address/Contact'),
                Tab(text: 'Bank Details'),
              ],
            ),
          ),
          body: state.status == UserStatus.loading && state.user == null
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBasicInfoTab(state),
                      _buildEmploymentTab(),
                      _buildAddressContactTab(),
                      _buildBankDetailsTab(),
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
                      child: const Text('Cancel')
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

  Widget _buildBasicInfoTab(StateUser state) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            Expanded(child: AppTextField(controller: _firstNameCtrl, label: 'First Name', validator: (v) => v?.isEmpty == true ? 'Required' : null)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: AppTextField(controller: _lastNameCtrl, label: 'Last Name', validator: (v) => v?.isEmpty == true ? 'Required' : null)),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _emailCtrl,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _phoneCtrl,
          label: 'Phone',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: AppSpacing.md),
        if (!_isEditing) _buildBranchDropdown(state),
        if (!_isEditing) SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: const InputDecoration(labelText: 'Role'),
          items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
          onChanged: (value) => setState(() => _selectedRole = value!),
        ),
        SizedBox(height: AppSpacing.md),
        if (!_isEditing)
          AppTextField(
            controller: _pinCtrl,
            label: 'PIN (4 digits)',
            keyboardType: TextInputType.number,
            obscureText: true,
            validator: (v) => v?.length != 4 ? 'PIN must be 4 digits' : null,
          ),
      ],
    );
  }

  Widget _buildEmploymentTab() {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        AppTextField(controller: _employeeIdCtrl, label: 'Employee ID'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _designationCtrl, label: 'Designation'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _departmentCtrl, label: 'Department'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _shiftCtrl, label: 'Shift'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _joinDateCtrl, label: 'Join Date'),
      ],
    );
  }

  Widget _buildAddressContactTab() {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Personal', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: AppSpacing.sm),
        AppTextField(controller: _dobCtrl, label: 'Date of Birth'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _genderCtrl, label: 'Gender'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _fatherNameCtrl, label: 'Father\'s Name'),
        const Divider(height: 32),
        Text('Address', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: AppSpacing.sm),
        AppTextField(controller: _streetCtrl, label: 'Street'),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: AppTextField(controller: _cityCtrl, label: 'City')),
            SizedBox(width: AppSpacing.md),
            Expanded(child: AppTextField(controller: _stateCtrl, label: 'State')),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: AppTextField(controller: _postalCodeCtrl, label: 'Postal Code')),
            SizedBox(width: AppSpacing.md),
            Expanded(child: AppTextField(controller: _countryCtrl, label: 'Country')),
          ],
        ),
        const Divider(height: 32),
        Text('Emergency Contact', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: AppSpacing.sm),
        AppTextField(controller: _emNameCtrl, label: 'Contact Name'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _emRelCtrl, label: 'Relationship'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _emPhoneCtrl, label: 'Phone Number', keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildBankDetailsTab() {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        AppTextField(controller: _bankNameCtrl, label: 'Bank Name'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _accountNameCtrl, label: 'Account Holder Name'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _accountNumCtrl, label: 'Account Number'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _ifscCtrl, label: 'IFSC Code'),
        SizedBox(height: AppSpacing.md),
        AppTextField(controller: _branchNameCtrl, label: 'Branch Name'),
      ],
    );
  }

  Widget _buildBranchDropdown(StateUser state) {
    if (state.status == UserStatus.loading && state.branches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.branches.isEmpty) {
      return Text('No branches found. Create a branch first.', style: TextStyle(color: Theme.of(context).colorScheme.error));
    }
    return DropdownButtonFormField<String>(
      value: _selectedBranchId,
      decoration: const InputDecoration(labelText: 'Branch'),
      hint: const Text('Select branch'),
      items: state.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.displayName))).toList(),
      onChanged: (value) => setState(() => _selectedBranchId = value),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _tabController.animateTo(0);
      return;
    }

    final data = {
      'firstName': _firstNameCtrl.text,
      'lastName': _lastNameCtrl.text,
      'email': _emailCtrl.text,
      'phoneNumber': _phoneCtrl.text,
      'username': _emailCtrl.text.split('@').first,
      'role': _selectedRole,
      'userType': 'BRAND',
      'brandId': widget.brandId,
      if (!_isEditing) 'loginPin': _pinCtrl.text,
      if (!_isEditing && _selectedBranchId != null) 'branchId': _selectedBranchId,
      
      'userDetails': {
        'employeeId': _employeeIdCtrl.text,
        'department': _departmentCtrl.text,
        'designation': _designationCtrl.text,
        'shift': _shiftCtrl.text,
        'joinDate': _joinDateCtrl.text,
        'dateOfBirth': _dobCtrl.text,
        'gender': _genderCtrl.text,
        'fatherName': _fatherNameCtrl.text,
        'address': {
          'street': _streetCtrl.text,
          'city': _cityCtrl.text,
          'state': _stateCtrl.text,
          'postalCode': _postalCodeCtrl.text,
          'country': _countryCtrl.text,
        },
        'emergencyContact': {
          'name': _emNameCtrl.text,
          'relationship': _emRelCtrl.text,
          'phone': _emPhoneCtrl.text,
        },
        'bankDetails': {
          'bankName': _bankNameCtrl.text,
          'accountHolderName': _accountNameCtrl.text,
          'accountNumber': _accountNumCtrl.text,
          'ifscCode': _ifscCtrl.text,
          'branchName': _branchNameCtrl.text,
        }
      }
    };

    if (_isEditing) {
      context.read<CubitUser>().updateUser(widget.userId!, data);
      showToast(context, message: 'User updated successfully', status: 'success');
      context.go('/brands/${widget.brandId}/users/${widget.userId}');
    } else {
      context.read<CubitUser>().createUser(data);
      showToast(context, message: 'User created successfully', status: 'success');
      context.go('/brands/${widget.brandId}/users');
    }
  }
}