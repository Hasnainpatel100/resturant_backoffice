import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/repositories/branch_plan_repository_impl.dart';
import '../../../theme/theme_constants.dart';
import 'cubit_branch_plan.dart';
import 'state_branch_plan.dart';

class ScreenBranchPlanForm extends StatefulWidget {
  final String brandId;
  final String branchId;

  const ScreenBranchPlanForm({
    super.key,
    required this.brandId,
    required this.branchId,
  });

  @override
  State<ScreenBranchPlanForm> createState() => _ScreenBranchPlanFormState();
}

class _ScreenBranchPlanFormState extends State<ScreenBranchPlanForm> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _maxUsersController = TextEditingController();
  final _maxPosDevicesController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime? _selectedExpiryDate;
  final _dateController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _maxUsersController.dispose();
    _maxPosDevicesController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _submit(BuildContext blocContext) {
    if (_formKey.currentState!.validate()) {
      if (_selectedExpiryDate == null) {
        _showSnackBar('Please select an expiry date');
        return;
      }

      // Convert date to UTC milliseconds as string
      final expiryAtMs = _selectedExpiryDate!.toUtc().millisecondsSinceEpoch.toString();

      final data = {
        'maxUsers': int.tryParse(_maxUsersController.text) ?? 0,
        'maxPosDevices': int.tryParse(_maxPosDevicesController.text) ?? 0,
        'expiryAt': expiryAtMs,
        'note': _noteController.text,
      };

      // Call the API via cubit
      blocContext.read<CubitBranchPlan>().assignPlan(widget.branchId, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitBranchPlan(repository: BranchPlanRepositoryImpl()),
      child: Builder(
        builder: (blocContext) {
          final cs = Theme.of(blocContext).colorScheme;

          return ScaffoldMessenger(
            key: _scaffoldMessengerKey,
            child: BlocListener<CubitBranchPlan, StateBranchPlan>(
              listener: (context, state) {
                if (state.status == BranchPlanStatus.loading) {
                  setState(() => _isSaving = true);
                } else {
                  setState(() => _isSaving = false);
                }

                if (state.status == BranchPlanStatus.success) {
                  _showSnackBar('Plan assigned successfully!');
                  // Navigate back after a short delay so user sees the message
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) context.pop();
                  });
                } else if (state.status == BranchPlanStatus.error) {
                  _showSnackBar(state.errorMessage ?? 'Failed to assign plan');
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text('common.assign_plan'.tr()),
                  actions: [
                    TextButton.icon(
                      onPressed: _isSaving ? null : () => _submit(blocContext),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save'),
                      style: TextButton.styleFrom(foregroundColor: cs.primary),
                    ),
                    SizedBox(width: AppSpacing.md),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(cs),
                            SizedBox(height: AppSpacing.xl),
                            
                            // Max Users
                            _buildLabel('Max Users'),
                            TextFormField(
                              controller: _maxUsersController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                hintText: 'common.e_g_10'.tr(),
                                prefixIcon: const Icon(Icons.people_outline),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: AppSpacing.lg),

                            // Max POS Devices
                            _buildLabel('Max POS Devices'),
                            TextFormField(
                              controller: _maxPosDevicesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                hintText: 'common.e_g_5'.tr(),
                                prefixIcon: const Icon(Icons.devices_outlined),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: AppSpacing.lg),

                            // Expiry Date
                            _buildLabel('Expiry Date'),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              decoration: InputDecoration(
                                hintText: 'common.select_date'.tr(),
                                prefixIcon: const Icon(Icons.calendar_today_outlined),
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: AppSpacing.lg),

                            // Note
                            _buildLabel('Note'),
                            TextFormField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'common.premium_plan_assigned'.tr(),
                                prefixIcon: const Icon(Icons.note_outlined),
                              ),
                            ),
                            
                            SizedBox(height: AppSpacing.xxl),
                            
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : () => _submit(blocContext),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                  backgroundColor: cs.primary,
                                  foregroundColor: cs.onPrimary,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text('common.assign_plan'.tr()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('common.assign_plan_to_branch'.tr(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          'Enter plan details for branch ID: ${widget.branchId}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.xs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
