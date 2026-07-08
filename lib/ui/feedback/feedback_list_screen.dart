import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/feedback_configuration_model.dart';
import 'feedback_details_drawer.dart';

/// Lightweight display wrapper around [FeedbackConfigurationModel].
///
/// The configuration model itself doesn't carry a human-readable branch
/// name or a question count (those live in separate collections), so this
/// screen pairs each dummy [FeedbackConfigurationModel] with the extra
/// display-only fields it needs for the table.
class _FeedbackListItem {
  final FeedbackConfigurationModel config;
  final String branchName;
  final int questionCount;

  const _FeedbackListItem({
    required this.config,
    required this.branchName,
    required this.questionCount,
  });
}

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  _FeedbackListItem? _selectedItemForDrawer;

  String _searchQuery = '';
  String? _selectedBranch;
  String? _selectedStatus;
  bool _isRefreshing = false;

  late List<_FeedbackListItem> _allItems;

  static const List<String> _branchOptions = [
    'Koregaon Park',
    'Baner',
    'Viman Nagar',
    'Wakad',
  ];

  static const List<String> _statusOptions = [
    'DRAFT',
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED',
  ];

  @override
  void initState() {
    super.initState();
    _allItems = _buildDummyItems();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FeedbackListItem> _buildDummyItems() {
    final now = DateTime.now();

    FeedbackConfigurationModel config({
      required String id,
      required String branchId,
      required String title,
      required String status,
      required String sendMethod,
      required DateTime updatedAt,
    }) {
      return FeedbackConfigurationModel(
        id: id,
        brandId: 'brand_001',
        branchId: branchId,
        title: title,
        status: status,
        sendMethod: sendMethod,
        delayMinutes: 15,
        minimumOrderAmount: 0,
        createdAt: updatedAt.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
        createdBy: 'admin@brand.com',
        updatedAt: updatedAt.millisecondsSinceEpoch,
        updatedBy: 'admin@brand.com',
        isActive: true,
      );
    }

    return [
      _FeedbackListItem(
        config: config(
          id: 'fbc_001',
          branchId: 'branch_kp',
          title: 'Post-Dine Experience Survey',
          status: 'ACTIVE',
          sendMethod: 'WHATSAPP',
          updatedAt: now.subtract(const Duration(hours: 3)),
        ),
        branchName: 'Koregaon Park',
        questionCount: 8,
      ),
      _FeedbackListItem(
        config: config(
          id: 'fbc_002',
          branchId: 'branch_baner',
          title: 'Delivery Order Feedback',
          status: 'ACTIVE',
          sendMethod: 'SMS',
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        branchName: 'Baner',
        questionCount: 6,
      ),
      _FeedbackListItem(
        config: config(
          id: 'fbc_003',
          branchId: 'branch_vn',
          title: 'Table Service Quality Check',
          status: 'DRAFT',
          sendMethod: 'DISABLED',
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        branchName: 'Viman Nagar',
        questionCount: 5,
      ),
      _FeedbackListItem(
        config: config(
          id: 'fbc_004',
          branchId: 'branch_wakad',
          title: 'QR Table Feedback',
          status: 'ACTIVE',
          sendMethod: 'QR_CODE',
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        branchName: 'Wakad',
        questionCount: 10,
      ),
      _FeedbackListItem(
        config: config(
          id: 'fbc_005',
          branchId: 'branch_kp',
          title: 'Loyalty Program Feedback',
          status: 'INACTIVE',
          sendMethod: 'ALL',
          updatedAt: now.subtract(const Duration(days: 12)),
        ),
        branchName: 'Koregaon Park',
        questionCount: 7,
      ),
      _FeedbackListItem(
        config: config(
          id: 'fbc_006',
          branchId: 'branch_baner',
          title: 'Legacy Feedback Form',
          status: 'ARCHIVED',
          sendMethod: 'DISABLED',
          updatedAt: now.subtract(const Duration(days: 60)),
        ),
        branchName: 'Baner',
        questionCount: 4,
      ),
    ];
  }

  List<_FeedbackListItem> get _filteredItems {
    return _allItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.config.title.toLowerCase().contains(_searchQuery) ||
          item.branchName.toLowerCase().contains(_searchQuery);

      final matchesBranch = _selectedBranch == null || item.branchName == _selectedBranch;

      final matchesStatus = _selectedStatus == null || item.config.status == _selectedStatus;

      return matchesSearch && matchesBranch && matchesStatus;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Placeholder for a real repository call, e.g.:
    // await context.read<FeedbackConfigurationCubit>().loadFeedbackConfigurations();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _allItems = _buildDummyItems();
      _isRefreshing = false;
    });
  }

  void _onCreateFeedback() {
    context.push('/feedback/create');
  }

  void _onView(_FeedbackListItem item) {
    setState(() {
      _selectedItemForDrawer = item;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _onEdit(_FeedbackListItem item) {
    context.push('/feedback/${item.config.id}/edit', extra: item.config);
  }

  void _onDuplicate(_FeedbackListItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicated "${item.config.title}"')),
    );
  }

  void _onToggleStatus(_FeedbackListItem item) {
    final nextStatus = item.config.isActiveStatus ? 'INACTIVE' : 'ACTIVE';
    setState(() {
      final index = _allItems.indexWhere((e) => e.config.id == item.config.id);
      if (index != -1) {
        _allItems[index] = _FeedbackListItem(
          config: item.config.copyWith(status: nextStatus),
          branchName: item.branchName,
          questionCount: item.questionCount,
        );
      }
    });
  }

  void _onDelete(_FeedbackListItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Feedback Form'),
        content: Text('Are you sure you want to delete "${item.config.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _allItems.removeWhere((e) => e.config.id == item.config.id);
              });
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.active:
        return Colors.green;
      case FeedbackStatus.draft:
        return Colors.blueGrey;
      case FeedbackStatus.inactive:
        return Colors.orange;
      case FeedbackStatus.archived:
        return Colors.red;
      case FeedbackStatus.unknown:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'DRAFT':
        return 'Draft';
      case 'INACTIVE':
        return 'Inactive';
      case 'ARCHIVED':
        return 'Archived';
      default:
        return status;
    }
  }

  String _sendMethodLabel(FeedbackSendMethod method) {
    switch (method) {
      case FeedbackSendMethod.sms:
        return 'SMS';
      case FeedbackSendMethod.whatsApp:
        return 'WhatsApp';
      case FeedbackSendMethod.qrCode:
        return 'QR Code';
      case FeedbackSendMethod.all:
        return 'All Channels';
      case FeedbackSendMethod.disabled:
        return 'Disabled';
      case FeedbackSendMethod.unknown:
        return 'Unknown';
    }
  }

  Widget _buildStatusChip(FeedbackConfigurationModel config) {
    final status = config.feedbackStatus;
    final color = _statusColor(status);
    return Chip(
      label: Text(
        _statusLabel(config.status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feedback Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage customer feedback forms',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: _onCreateFeedback,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create Feedback'),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by title or branch...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => _searchController.clear(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedBranch,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Branch',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('All Branches')),
              ..._branchOptions.map(
                    (branch) => DropdownMenuItem<String>(value: branch, child: Text(branch)),
              ),
            ],
            onChanged: (value) => setState(() => _selectedBranch = value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Status',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('All Statuses')),
              ..._statusOptions.map(
                    (status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(_statusLabel(status)),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _selectedStatus = value),
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Refresh',
          child: IconButton.filledTonal(
            onPressed: _isRefreshing ? null : _handleRefresh,
            icon: _isRefreshing
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCell(_FeedbackListItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'View',
          icon: const Icon(Icons.visibility_outlined, size: 20),
          onPressed: () => _onView(item),
        ),
        IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: () => _onEdit(item),
        ),
        PopupMenuButton<String>(
          tooltip: 'More',
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) {
            switch (value) {
              case 'duplicate':
                _onDuplicate(item);
                break;
              case 'toggle_status':
                _onToggleStatus(item);
                break;
              case 'delete':
                _onDelete(item);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy_outlined),
                title: Text('Duplicate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: ListTile(
                leading: Icon(
                  item.config.isActiveStatus ? Icons.pause_circle_outline : Icons.play_circle_outline,
                ),
                title: Text(item.config.isActiveStatus ? 'Deactivate' : 'Activate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTable() {
    final items = _filteredItems;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No feedback forms match the current filters.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
          columns: const [
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Branch')),
            DataColumn(label: Text('Questions')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Send Method')),
            DataColumn(label: Text('Last Updated')),
            DataColumn(label: Text('Actions')),
          ],
          rows: items.map((item) {
            final updatedAtMs = item.config.updatedAt ?? item.config.createdAt;
            final updatedAt = DateTime.fromMillisecondsSinceEpoch(updatedAtMs);

            return DataRow(
              cells: [
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      item.config.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                DataCell(Text(item.branchName)),
                DataCell(Text('${item.questionCount}')),
                DataCell(_buildStatusChip(item.config)),
                DataCell(Text(_sendMethodLabel(item.config.feedbackSendMethod))),
                DataCell(Text(dateFormat.format(updatedAt))),
                DataCell(_buildActionsCell(item)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      endDrawer: _selectedItemForDrawer != null
          ? FeedbackDetailsDrawer(
              config: _selectedItemForDrawer!.config,
              branchName: _selectedItemForDrawer!.branchName,
              questions: FeedbackDetailsDrawer.buildDummyQuestions(
                _selectedItemForDrawer!.config.id,
                _selectedItemForDrawer!.questionCount,
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildFilterBar(),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildTable(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
