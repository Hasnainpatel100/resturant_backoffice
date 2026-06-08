import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/bill_repository_impl.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/bills/cubit_bill.dart';
import 'package:back_office/ui/bills/state_bill.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';
import 'package:back_office/shared/helpers/format_number.dart';

class ScreenBillList extends StatefulWidget {
  final String brandId;
  final String? branchId;

  const ScreenBillList({super.key, required this.brandId, this.branchId});

  @override
  State<ScreenBillList> createState() => _ScreenBillListState();
}

class _ScreenBillListState extends State<ScreenBillList> {
  String? _selectedBranchId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.branchId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranches(widget.brandId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bills'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/brands/${widget.brandId}'),
          ),
          actions: [
            if (_selectedBranchId != null)
              BlocProvider<CubitBill>(
                create: (context) => CubitBill(repository: BillRepositoryImpl())
                  ..loadBills(widget.brandId, _selectedBranchId!),
                child: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<CubitBill>().loadBills(widget.brandId, _selectedBranchId!);
                      },
                      tooltip: 'Refresh Bills',
                    );
                  },
                ),
              ),
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
                            Icon(Icons.receipt_long_outlined, size: 64, color: cs.outline),
                            SizedBox(height: AppSpacing.md),
                            const Text('No branches found'),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: cs.outline),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Select a branch to view bills',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Branch',
                              border: OutlineInputBorder(),
                            ),
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
                create: (context) => CubitBill(repository: BillRepositoryImpl())
                  ..loadBills(widget.brandId, _selectedBranchId!),
                child: BlocBuilder<CubitBill, StateBill>(
                  builder: (context, state) {
                    if (state.status == StateBillStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == StateBillStatus.error) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: cs.error),
                            SizedBox(height: AppSpacing.md),
                            Text(state.errorMessage ?? 'Error loading bills'),
                            SizedBox(height: AppSpacing.md),
                            ElevatedButton(
                              onPressed: () {
                                context.read<CubitBill>().loadBills(widget.brandId, _selectedBranchId!);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredBills = state.bills.where((bill) {
                      final query = _searchQuery.toLowerCase().trim();
                      if (query.isEmpty) return true;
                      return bill.billNumber.toLowerCase().contains(query) ||
                          (bill.tableName != null && bill.tableName!.toLowerCase().contains(query)) ||
                          (bill.waiterName != null && bill.waiterName!.toLowerCase().contains(query));
                    }).toList();

                    return Column(
                      children: [
                        // Search & Branch selector header
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search by bill number, table, waiter...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: const OutlineInputBorder(),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              setState(() {
                                                _searchController.clear();
                                                _searchQuery = '';
                                              });
                                            },
                                          )
                                        : null,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              // Quick Branch Switcher
                              BlocBuilder<CubitBranch, StateBranch>(
                                builder: (context, branchState) {
                                  if (branchState.branches.isEmpty) return const SizedBox.shrink();
                                  return SizedBox(
                                    width: 200,
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: 'Branch',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                      initialValue: _selectedBranchId,
                                      items: branchState.branches.map((b) {
                                        return DropdownMenuItem(value: b.id, child: Text(b.displayName));
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null && value != _selectedBranchId) {
                                          setState(() {
                                            _selectedBranchId = value;
                                          });
                                          context.read<CubitBill>().loadBills(widget.brandId, value);
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // List Body
                        Expanded(
                          child: filteredBills.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.receipt_long_outlined, size: 64, color: cs.outline),
                                      SizedBox(height: AppSpacing.md),
                                      Text(
                                        _searchQuery.isNotEmpty ? 'No matching bills found' : 'No bills found',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    context.read<CubitBill>().loadBills(widget.brandId, _selectedBranchId!);
                                  },
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                    itemCount: filteredBills.length,
                                    itemBuilder: (context, index) {
                                      final bill = filteredBills[index];
                                      return Card(
                                        margin: EdgeInsets.only(bottom: AppSpacing.sm),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppBorders.md,
                                          side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            context.go('/brands/${widget.brandId}/bills/${bill.id}');
                                          },
                                          borderRadius: AppBorders.md,
                                          child: Padding(
                                            padding: EdgeInsets.all(AppSpacing.md),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor: cs.primaryContainer,
                                                  foregroundColor: cs.onPrimaryContainer,
                                                  child: const Icon(Icons.receipt_long),
                                                ),
                                                SizedBox(width: AppSpacing.md),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            bill.billNumber,
                                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                          ),
                                                          const Spacer(),
                                                          _buildStatusBadge(bill.paymentStatus, isPayment: true),
                                                          SizedBox(width: AppSpacing.xs),
                                                          _buildStatusBadge(bill.status),
                                                        ],
                                                      ),
                                                      SizedBox(height: AppSpacing.xs),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Date: ${bill.billDate}',
                                                            style: TextStyle(color: cs.outline, fontSize: 13),
                                                          ),
                                                          SizedBox(width: AppSpacing.md),
                                                          if (bill.tableName != null)
                                                            Text(
                                                              'Table: ${bill.tableName}',
                                                              style: TextStyle(color: cs.outline, fontSize: 13),
                                                            ),
                                                          SizedBox(width: AppSpacing.md),
                                                          Text(
                                                            'Type: ${bill.serviceType}',
                                                            style: TextStyle(color: cs.outline, fontSize: 13),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: AppSpacing.xs),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Mode: ${bill.paymentMode}',
                                                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                                          ),
                                                          if (bill.waiterName != null) ...[
                                                            SizedBox(width: AppSpacing.md),
                                                            Text(
                                                              'Waiter: ${bill.waiterName}',
                                                              style: TextStyle(color: cs.outline, fontSize: 13),
                                                            ),
                                                          ],
                                                          const Spacer(),
                                                          Text(
                                                            'Total: ₹${formatNumber(bill.totalAmount)}',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: cs.primary,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: AppSpacing.sm),
                                                Icon(Icons.chevron_right, color: cs.outline),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, {bool isPayment = false}) {
    Color color;
    Color textColor;

    final normalized = status.toUpperCase();
    if (normalized == 'PAID' || normalized == 'FULFILLED') {
      color = Colors.green.shade50;
      textColor = Colors.green.shade700;
    } else if (normalized == 'PENDING') {
      color = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
    } else if (normalized == 'CANCELLED') {
      color = Colors.red.shade50;
      textColor = Colors.red.shade700;
    } else {
      color = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppBorders.xs,
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        isPayment ? 'Payment: $status' : status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
