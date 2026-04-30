import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/menu_repository_impl.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/menu/menu_dashboard/cubit_menu.dart';
import 'package:back_office/ui/menu/menu_dashboard/state_menu.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';

class ScreenMenuDashboard extends StatefulWidget {
  final String brandId;

  const ScreenMenuDashboard({super.key, required this.brandId});

  @override
  State<ScreenMenuDashboard> createState() => _ScreenMenuDashboardState();
}

class _ScreenMenuDashboardState extends State<ScreenMenuDashboard> {
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CubitMenu(repository: MenuRepositoryImpl())),
        BlocProvider(create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranches(widget.brandId)),
      ],
      child: _MenuDashboardView(
        brandId: widget.brandId,
        selectedBranchId: _selectedBranchId,
        onBranchSelected: (branchId) {
          setState(() => _selectedBranchId = branchId);
        },
      ),
    );
  }
}

class _MenuDashboardView extends StatelessWidget {
  final String brandId;
  final String? selectedBranchId;
  final ValueChanged<String> onBranchSelected;

  const _MenuDashboardView({
    required this.brandId,
    this.selectedBranchId,
    required this.onBranchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/brands/$brandId')),
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
                      const Text('Select a branch to manage menu'),
                      SizedBox(height: AppSpacing.md),
                      BlocBuilder<CubitBranch, StateBranch>(
                        builder: (context, branchState) {
                          if (branchState.status == BranchStatus.loading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (branchState.branches.isEmpty) {
                            return Text('No branches found', style: TextStyle(color: cs.outline));
                          }
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Branch'),
                            hint: const Text('Select branch'),
                            items: branchState.branches.map((b) {
                              return DropdownMenuItem(value: b.id, child: Text(b.displayName));
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                onBranchSelected(value);
                                context.read<CubitMenu>().loadCategories(brandId, value);
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
              child: BlocBuilder<CubitMenu, StateMenu>(
                builder: (context, state) {
                  if (state.status == MenuStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == MenuStatus.error) {
                    return Center(child: Text(state.errorMessage ?? 'Error'));
                  }

                  return _buildMenuContent(context, state);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context, StateMenu state) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: () => _showCategoryDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (state.categories.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.category_outlined, size: 48, color: cs.outline),
                      SizedBox(height: AppSpacing.md),
                      const Text('No categories yet'),
                      SizedBox(height: AppSpacing.md),
                      ElevatedButton.icon(
                        onPressed: () => _showCategoryDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Category'),
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
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      context.read<CubitMenu>().loadMenuItems(brandId, selectedBranchId!, categoryId: category.id);
                      _showItemsSheet(context, category.id, category.name);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, color: cs.primary, size: 32),
                          SizedBox(height: AppSpacing.sm),
                          Text(category.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
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

  void _showCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Category Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<CubitMenu>().createCategories(brandId, [
                  {'name': nameController.text, 'branchId': selectedBranchId}
                ]);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showItemsSheet(BuildContext context, String categoryId, String categoryName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<CubitMenu>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) => Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(categoryName, style: Theme.of(context).textTheme.titleLarge),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheetContext)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: BlocBuilder<CubitMenu, StateMenu>(
                  builder: (_, state) {
                    if (state.status == MenuStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.menuItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('No items in this category'),
                            SizedBox(height: AppSpacing.md),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text('Add Item'),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.all(AppSpacing.md),
                      itemCount: state.menuItems.length,
                      itemBuilder: (_, index) {
                        final item = state.menuItems[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text('\u20b9${item.basePrice.toStringAsFixed(2)}'),
                            trailing: Switch(
                              value: item.isAvailable,
                              onChanged: (value) {
                                context.read<CubitMenu>().toggleMenuItemAvailability(item.id, {'isAvailable': value, 'brandId': brandId});
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}