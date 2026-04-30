import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/pos_device_repository_impl.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/pos_devices/pos_device_list/cubit_pos_device.dart';
import 'package:back_office/ui/pos_devices/pos_device_list/state_pos_device.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';

class ScreenPosDeviceList extends StatefulWidget {
  final String brandId;
  final String? branchId;

  const ScreenPosDeviceList({super.key, required this.brandId, this.branchId});

  @override
  State<ScreenPosDeviceList> createState() => _ScreenPosDeviceListState();
}

class _ScreenPosDeviceListState extends State<ScreenPosDeviceList> {
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.branchId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranches(widget.brandId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('POS Devices'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/brands/${widget.brandId}')),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: () => _showRegisterDialog(context)),
          ],
        ),
        body: _selectedBranchId == null
            ? BlocBuilder<CubitBranch, StateBranch>(
                builder: (context, branchState) {
                  if (branchState.status == BranchStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (branchState.branches.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tablet_android_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                            SizedBox(height: AppSpacing.md),
                            const Text('No branches found'),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tablet_android_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                          SizedBox(height: AppSpacing.md),
                          const Text('Select a branch to view POS devices'),
                          SizedBox(height: AppSpacing.md),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Branch'),
                            hint: const Text('Select branch'),
                            items: branchState.branches.map((b) {
                              return DropdownMenuItem(value: b.id, child: Text(b.displayName));
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedBranchId = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : BlocProvider(
                create: (context) => CubitPosDevice(repository: PosDeviceRepositoryImpl())..loadDevices(_selectedBranchId!),
                child: BlocBuilder<CubitPosDevice, StatePosDevice>(
                  builder: (context, state) {
                    if (state.status == StatePosDeviceStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == StatePosDeviceStatus.error) {
                      return Center(child: Text(state.errorMessage ?? 'Error'));
                    }

                    if (state.devices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tablet_android_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                            SizedBox(height: AppSpacing.md),
                            Text('No POS devices registered', style: Theme.of(context).textTheme.titleMedium),
                            SizedBox(height: AppSpacing.sm),
                            ElevatedButton.icon(
                              onPressed: () => _showRegisterDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Register Device'),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<CubitPosDevice>().loadDevices(_selectedBranchId!);
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.all(AppSpacing.md),
                        itemCount: state.devices.length,
                        itemBuilder: (context, index) {
                          final device = state.devices[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: device.isActive ? Colors.green.shade100 : Colors.grey.shade200,
                                child: Icon(Icons.tablet_android, color: device.isActive ? Colors.green : Colors.grey),
                              ),
                              title: Text(device.deviceName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(device.deviceId),
                                  Text('Type: ${device.deviceType}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: device.isActive ? Colors.green.shade100 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  device.status.toUpperCase(),
                                  style: TextStyle(fontSize: 12, color: device.isActive ? Colors.green.shade700 : Colors.grey.shade600),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    if (_selectedBranchId == null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Branch Required'),
          content: const Text('Please select a branch to register a device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final deviceNameController = TextEditingController();
    final deviceIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Register Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: deviceNameController, decoration: const InputDecoration(labelText: 'Device Name')),
            SizedBox(height: AppSpacing.md),
            TextField(controller: deviceIdController, decoration: const InputDecoration(labelText: 'Device ID')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (deviceNameController.text.isNotEmpty && deviceIdController.text.isNotEmpty) {
                context.read<CubitPosDevice>().registerDevice({
                  'branchId': _selectedBranchId,
                  'brandId': widget.brandId,
                  'deviceName': deviceNameController.text,
                  'deviceId': deviceIdController.text,
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}