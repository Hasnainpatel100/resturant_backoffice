import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/user_repository_impl.dart';
import 'package:back_office/ui/users/user_list/cubit_user.dart';
import 'package:back_office/ui/users/user_list/state_user.dart';

class ScreenUserDetail extends StatelessWidget {
  final String brandId;
  final String userId;

  const ScreenUserDetail({
    super.key,
    required this.brandId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitUser(repository: UserRepositoryImpl())..loadUser(userId),
      child: _UserDetailView(brandId: brandId),
    );
  }
}

class _UserDetailView extends StatelessWidget {
  final String brandId;

  const _UserDetailView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands/$brandId/users'),
        ),
        actions: [
          BlocBuilder<CubitUser, StateUser>(
            builder: (context, state) {
              if (state.status == UserStatus.loaded && state.user != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/brands/$brandId/users/${state.user!.user.id}/edit'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CubitUser, StateUser>(
        builder: (context, state) {
          if (state.status == UserStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UserStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Failed to load user'));
          }

          final userProfile = state.user;
          if (userProfile == null) {
            return const Center(child: Text('User not found'));
          }

          final user = userProfile.user;
          final details = userProfile.userDetails;

          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: cs.primaryContainer,
                        child: Text(
                          user.initials,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                      if (user.phoneNumber.isNotEmpty)
                        Text(user.phoneNumber, style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(user.role),
                            backgroundColor: cs.secondaryContainer,
                            labelStyle: TextStyle(color: cs.onSecondaryContainer),
                          ),
                          if (details?.designation != null && details!.designation!.isNotEmpty)
                            Chip(
                              label: Text(details.designation!),
                              backgroundColor: cs.tertiaryContainer,
                              labelStyle: TextStyle(color: cs.onTertiaryContainer),
                            ),
                          Chip(
                            label: Text(user.isActive ? 'Active' : 'Inactive'),
                            backgroundColor: user.isActive ? Colors.green.shade100 : Colors.red.shade100,
                            labelStyle: TextStyle(color: user.isActive ? Colors.green.shade800 : Colors.red.shade800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              if (details != null) ...[
                _buildSection(
                  context,
                  title: 'Employment Details',
                  icon: Icons.work_outline,
                  children: [
                    _buildInfoRow('Employee ID', details.employeeId),
                    _buildInfoRow('Department', details.department),
                    _buildInfoRow('Shift', details.shift),
                    _buildInfoRow('Join Date', details.joinDate),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                _buildSection(
                  context,
                  title: 'Personal Details',
                  icon: Icons.person_outline,
                  children: [
                    _buildInfoRow('Date of Birth', details.dateOfBirth),
                    _buildInfoRow('Gender', details.gender),
                    _buildInfoRow('Father\'s Name', details.fatherName),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                if (details.address != null)
                  _buildSection(
                    context,
                    title: 'Address',
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildInfoRow('Street', details.address!.street),
                      _buildInfoRow('City', details.address!.city),
                      _buildInfoRow('State', details.address!.state),
                      _buildInfoRow('Postal Code', details.address!.postalCode),
                      _buildInfoRow('Country', details.address!.country),
                    ],
                  ),
                SizedBox(height: AppSpacing.md),
                if (details.emergencyContact != null)
                  _buildSection(
                    context,
                    title: 'Emergency Contact',
                    icon: Icons.emergency_outlined,
                    children: [
                      _buildInfoRow('Name', details.emergencyContact!.name),
                      _buildInfoRow('Relationship', details.emergencyContact!.relationship),
                      _buildInfoRow('Phone', details.emergencyContact!.phone),
                    ],
                  ),
                SizedBox(height: AppSpacing.md),
                if (details.bankDetails != null)
                  _buildSection(
                    context,
                    title: 'Bank Details',
                    icon: Icons.account_balance_outlined,
                    children: [
                      _buildInfoRow('Bank Name', details.bankDetails!.bankName),
                      _buildInfoRow('Account Name', details.bankDetails!.accountHolderName),
                      _buildInfoRow('Account Number', details.bankDetails!.accountNumber),
                      _buildInfoRow('IFSC Code', details.bankDetails!.ifscCode),
                      _buildInfoRow('Branch', details.bankDetails!.branchName),
                    ],
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    final validChildren = children.where((child) => child is! SizedBox).toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: AppSpacing.sm),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            ...validChildren,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
