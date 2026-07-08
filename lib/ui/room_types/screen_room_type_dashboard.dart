import 'package:back_office/ui/room_types/state_room_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/room_type_repository_impl.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';

import 'cubit_room_type.dart';
import 'package:back_office/ui/room_types/screen_room_tables.dart';

class ScreenRoomTypeDashboard extends StatefulWidget {
  final String brandId;

  const ScreenRoomTypeDashboard({super.key, required this.brandId});

  @override
  State<ScreenRoomTypeDashboard> createState() => _ScreenRoomTypeDashboardState();
}

class _ScreenRoomTypeDashboardState extends State<ScreenRoomTypeDashboard> {
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CubitRoomType(repository: RoomTypeRepositoryImpl())),
        BlocProvider(create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranches(widget.brandId)),
      ],
      child: _RoomTypeDashboardView(
        brandId: widget.brandId,
        selectedBranchId: _selectedBranchId,
        onBranchSelected: (branchId) {
          setState(() => _selectedBranchId = branchId);
        },
      ),
    );
  }
}

class _RoomTypeDashboardView extends StatelessWidget {
  final String brandId;
  final String? selectedBranchId;
  final ValueChanged<String> onBranchSelected;

  const _RoomTypeDashboardView({
    required this.brandId,
    this.selectedBranchId,
    required this.onBranchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('common.room_types'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands/$brandId'),
        ),
      ),
      body: Column(
        children: [
          if (selectedBranchId == null)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Icon(Icons.store, size: 48, color: cs.outline),
                      SizedBox(height: AppSpacing.md),
                      Text('common.select_a_branch_to_manage_room'.tr()),
                      SizedBox(height: AppSpacing.md),
                      BlocBuilder<CubitBranch, StateBranch>(
                        builder: (context, branchState) {
                          if (branchState.status == BranchStatus.loading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (branchState.branches.isEmpty) {
                            return Text('common.no_branches_found'.tr(), style: TextStyle(color: cs.outline));
                          }
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Branch'),
                            hint: Text('common.select_branch'.tr()),
                            items: branchState.branches.map((b) {
                              return DropdownMenuItem(value: b.id, child: Text(b.displayName));
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                onBranchSelected(value);
                                context.read<CubitRoomType>().loadRoomTypes(brandId, value);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: BlocBuilder<CubitRoomType, StateRoomType>(
                builder: (context, state) {
                  if (state.status == RoomTypeStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == RoomTypeStatus.error) {
                    return Center(child: Text(state.errorMessage ?? 'Error'));
                  }
                  return _buildContent(context, state);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, StateRoomType state) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('common.room_types'.tr(), style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add),
                label: Text('common.add'.tr()),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (state.roomTypes.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.meeting_room_outlined, size: 48, color: cs.outline),
                      SizedBox(height: AppSpacing.md),
                      Text('common.no_room_types_yet'.tr()),
                      SizedBox(height: AppSpacing.md),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateDialog(context),
                        icon: const Icon(Icons.add),
                        label: Text('common.add_room_type'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.5,
              ),
              itemCount: state.roomTypes.length,
              itemBuilder: (context, index) {
                final roomType = state.roomTypes[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScreenRoomTables(
                            brandId: brandId,
                            branchId: selectedBranchId!,
                            roomTypeId: roomType.id,
                            roomTypeName: roomType.name,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.meeting_room, color: cs.primary, size: 32),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            roomType.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => _showEditDialog(context, roomType.id, roomType.name),
                                child: Icon(Icons.edit_outlined, size: 18, color: cs.primary),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              InkWell(
                                onTap: () => _confirmDelete(context, roomType.id, roomType.name),
                                child: Icon(Icons.delete_outline, size: 18, color: cs.error),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('common.add_room_type'.tr()),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Room Type Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<CubitRoomType>().createRoomTypes(brandId, [
                  {'name': nameController.text, 'branchId': selectedBranchId},
                ]);
                Navigator.pop(dialogContext);
              }
            },
            child: Text('common.add'.tr()),
          ),
        ],
      ),
    );
  }
  void _showEditDialog(BuildContext context, String roomTypeId, String currentName) {
    // Pass the full roomType object instead of just the name
    final roomType = context.read<CubitRoomType>().state.roomTypes
        .firstWhere((r) => r.id == roomTypeId);
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('common.edit_room_type'.tr()),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Room Type Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && nameController.text != currentName) {
                context.read<CubitRoomType>().updateRoomType(roomTypeId, {
                  'name': nameController.text,
                  'brandId': brandId,
                  // ✅ preserve existing values, no branchId
                  'displayOrder': roomType.displayOrder,
                  'isActive': roomType.isActive,
                });
                Navigator.pop(dialogContext);
              }
            },
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String roomTypeId, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('common.delete_room_type'.tr()),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              context.read<CubitRoomType>().deleteRoomType(
                roomTypeId,
                brandId: brandId,
                branchId: selectedBranchId!,
              );
              Navigator.pop(dialogContext);
            },
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }
}
