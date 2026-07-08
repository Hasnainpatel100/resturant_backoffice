import 'package:intl/intl.dart';

import '../../data/models/feedback_response_model.dart';
import '../../imports/core_imports.dart';

class _CustomerResponseItem {
  final String id;
  final DateTime submittedAt;
  final String customerName;
  final String branchName;
  final String orderId;
  final double rating;
  final FeedbackSource source;
  final FeedbackResponseStatus status;

  const _CustomerResponseItem({
    required this.id,
    required this.submittedAt,
    required this.customerName,
    required this.branchName,
    required this.orderId,
    required this.rating,
    required this.source,
    required this.status,
  });
}

class ScreenCustomerResponse extends StatefulWidget {
  const ScreenCustomerResponse({super.key});

  @override
  State<ScreenCustomerResponse> createState() => _ScreenCustomerResponseState();
}

class _ScreenCustomerResponseState extends State<ScreenCustomerResponse> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedBranch;
  double? _selectedRating;
  FeedbackSource? _selectedSource;
  DateTimeRange? _selectedDateRange;
  bool _isRefreshing = false;

  late List<_CustomerResponseItem> _allItems;

  static const List<String> _branchOptions = [
    'Koregaon Park',
    'Baner',
    'Viman Nagar',
    'Wakad',
  ];

  static const List<double> _ratingOptions = [5, 4, 3, 2, 1];

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

  // ── Dummy data ───────────────────────────────────────────────────────────

  List<_CustomerResponseItem> _buildDummyItems() {
    final now = DateTime.now();

    return [
      _CustomerResponseItem(
        id: 'resp_001',
        submittedAt: now.subtract(const Duration(hours: 2)),
        customerName: 'Aditi Sharma',
        branchName: 'Koregaon Park',
        orderId: 'ORD-10234',
        rating: 5,
        source: FeedbackSource.qrCode,
        status: FeedbackResponseStatus.submitted,
      ),
      _CustomerResponseItem(
        id: 'resp_002',
        submittedAt: now.subtract(const Duration(hours: 6)),
        customerName: 'Rohan Deshpande',
        branchName: 'Baner',
        orderId: 'ORD-10229',
        rating: 3,
        source: FeedbackSource.whatsApp,
        status: FeedbackResponseStatus.submitted,
      ),
      _CustomerResponseItem(
        id: 'resp_003',
        submittedAt: now.subtract(const Duration(days: 1)),
        customerName: 'Neha Kulkarni',
        branchName: 'Viman Nagar',
        orderId: 'ORD-10201',
        rating: 4,
        source: FeedbackSource.sms,
        status: FeedbackResponseStatus.pending,
      ),
      _CustomerResponseItem(
        id: 'resp_004',
        submittedAt: now.subtract(const Duration(days: 2, hours: 4)),
        customerName: 'Kunal Patil',
        branchName: 'Wakad',
        orderId: 'ORD-10188',
        rating: 2,
        source: FeedbackSource.qrCode,
        status: FeedbackResponseStatus.submitted,
      ),
      _CustomerResponseItem(
        id: 'resp_005',
        submittedAt: now.subtract(const Duration(days: 3)),
        customerName: 'Simran Kaur',
        branchName: 'Koregaon Park',
        orderId: 'ORD-10176',
        rating: 5,
        source: FeedbackSource.whatsApp,
        status: FeedbackResponseStatus.submitted,
      ),
      _CustomerResponseItem(
        id: 'resp_006',
        submittedAt: now.subtract(const Duration(days: 5)),
        customerName: 'Arjun Mehta',
        branchName: 'Baner',
        orderId: 'ORD-10142',
        rating: 1,
        source: FeedbackSource.whatsApp,
        status: FeedbackResponseStatus.pending,
      ),
      _CustomerResponseItem(
        id: 'resp_007',
        submittedAt: now.subtract(const Duration(days: 8)),
        customerName: 'Priya Nair',
        branchName: 'Viman Nagar',
        orderId: 'ORD-10098',
        rating: 4,
        source: FeedbackSource.qrCode,
        status: FeedbackResponseStatus.submitted,
      ),
    ];
  }

  // ── Filtering ────────────────────────────────────────────────────────────

  List<_CustomerResponseItem> get _filteredItems {
    return _allItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.customerName.toLowerCase().contains(_searchQuery) ||
          item.orderId.toLowerCase().contains(_searchQuery);

      final matchesBranch = _selectedBranch == null || item.branchName == _selectedBranch;

      final matchesRating = _selectedRating == null || item.rating == _selectedRating;

      final matchesSource = _selectedSource == null || item.source == _selectedSource;

      final matchesDateRange = _selectedDateRange == null ||
          (!item.submittedAt.isBefore(_selectedDateRange!.start) &&
              !item.submittedAt.isAfter(
                _selectedDateRange!.end.add(const Duration(days: 1)),
              ));

      return matchesSearch && matchesBranch && matchesRating && matchesSource && matchesDateRange;
    }).toList();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Placeholder for a real repository call, e.g.:
    // await context.read<CustomerResponseCubit>().loadCustomerResponses();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _allItems = _buildDummyItems();
      _isRefreshing = false;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _onView(_CustomerResponseItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ResponseDetailDialog(item: item),
    );
  }

  // ── Labels / colors ──────────────────────────────────────────────────────

  String _sourceLabel(FeedbackSource source) {
    switch (source) {
      case FeedbackSource.whatsApp:
        return 'WhatsApp'.tr();
      case FeedbackSource.sms:
        return 'SMS'.tr();
      case FeedbackSource.qrCode:
        return 'QR Code'.tr();
      case FeedbackSource.manualLink:
        return 'Manual Link'.tr();
        case FeedbackSource.googleForm:
        return 'Google Form'.tr();
      case FeedbackSource.unknown:
        return 'Unknown'.tr();
    }
  }

  IconData _sourceIcon(FeedbackSource source) {
    switch (source) {
      case FeedbackSource.whatsApp:
        return Icons.chat_outlined;
      case FeedbackSource.sms:
        return Icons.sms_outlined;
      case FeedbackSource.qrCode:
        return Icons.qr_code_2;
      case FeedbackSource.manualLink:
        return Icons.link_sharp;
        case FeedbackSource.googleForm:
        return Icons.format_align_justify_rounded;
      case FeedbackSource.unknown:
        return Icons.help_outline;
    }
  }

  String _statusLabel(FeedbackResponseStatus status) {
    switch (status) {
      case FeedbackResponseStatus.submitted:
        return 'submitted'.tr();
      case FeedbackResponseStatus.pending:
        return 'Pending'.tr();
        case FeedbackResponseStatus.expired:
        return 'Expired'.tr();
        case FeedbackResponseStatus.unknown:
        return 'Unknown'.tr();
    }
  }

  Color _statusColor(FeedbackResponseStatus status, ColorScheme cs) {
    switch (status) {
      case FeedbackResponseStatus.submitted:
        return Colors.green;
      case FeedbackResponseStatus.pending:
        return Colors.orange;
        case FeedbackResponseStatus.expired:
        return Colors.red;
        case FeedbackResponseStatus.unknown:
        return cs.onSurfaceVariant;
    }
  }

  // ── Summary metrics ──────────────────────────────────────────────────────

  int get _totalResponses => _allItems.length;

  double get _averageRating {
    if (_allItems.isEmpty) return 0;
    final sum = _allItems.fold<double>(0, (acc, item) => acc + item.rating);
    return sum / _allItems.length;
  }

  int get _qrResponses => _allItems.where((item) => item.source == FeedbackSource.qrCode).length;

  int get _pendingResponses =>
      _allItems.where((item) => item.status == FeedbackResponseStatus.pending).length;

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildHeader(ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Responses'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'View and manage customer feedback submissions'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.forum_outlined,
            label: 'Total Responses'.tr(),
            value: '$_totalResponses',
            color: cs.primary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SummaryCard(
            icon: Icons.star_outline,
            label: 'Average Rating'.tr(),
            value: _averageRating.toStringAsFixed(1),
            color: Colors.amber[800]!,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SummaryCard(
            icon: Icons.qr_code_2,
            label: 'Today`s Responses'.tr(),
            value: '$_qrResponses',
            color: Colors.teal,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SummaryCard(
            icon: Icons.hourglass_empty,
            label: 'Pending Responses'.tr(),
            value: '$_pendingResponses',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(ColorScheme cs) {
    final dateRangeLabel = _selectedDateRange == null
        ? 'Date Range'.tr()
        : '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - '
        '${DateFormat('dd MMM').format(_selectedDateRange!.end)}';

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AppTextField(
            controller: _searchController,
            label: 'Search'.tr(),
            hint: 'Search by customer or order ID...'.tr(),
            prefixIcon: const Icon(Icons.search, size: 20),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: AppDropdownField<String>(
            label: 'Branch'.tr(),
            hint: 'All Branches'.tr(),
            value: _selectedBranch,
            items: [
              DropdownMenuItem<String>(value: null, child: Text('All Branches'.tr())),
              ..._branchOptions.map(
                    (branch) => DropdownMenuItem<String>(value: branch, child: Text(branch)),
              ),
            ],
            onChanged: (value) => setState(() => _selectedBranch = value),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: AppDropdownField<double>(
            label: 'Rating'.tr(),
            hint: 'All Ratings'.tr(),
            value: _selectedRating,
            items: [
              DropdownMenuItem<double>(value: null, child: Text('All Ratings'.tr())),
              ..._ratingOptions.map(
                    (rating) => DropdownMenuItem<double>(
                  value: rating,
                  child: Text('${rating.toInt()} ★'),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _selectedRating = value),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: AppDropdownField<FeedbackSource>(
            label: 'Source'.tr(),
            hint: 'All Sources'.tr(),
            value: _selectedSource,
            items: [
              DropdownMenuItem<FeedbackSource>(value: null, child: Text('All Sources'.tr())),
              ...FeedbackSource.values.where((s) => s != FeedbackSource.unknown).map(
                    (source) => DropdownMenuItem<FeedbackSource>(
                  value: source,
                  child: Text(_sourceLabel(source)),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _selectedSource = value),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.date_range_outlined, size: 18),
            label: Text(
              dateRangeLabel,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Tooltip(
          message: 'Refresh'.tr(),
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

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating.round();
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 16,
          color: filled ? Colors.amber[700] : Colors.grey[400],
        );
      }),
    );
  }

  Widget _buildSourceChip(FeedbackSource source) {
    return Chip(
      avatar: Icon(_sourceIcon(source), size: 14),
      label: Text(
        _sourceLabel(source),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(FeedbackResponseStatus status, ColorScheme cs) {
    final color = _statusColor(status, cs);
    return Chip(
      label: Text(
        _statusLabel(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTable(ColorScheme cs) {
    final items = _filteredItems;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No customer responses match the current filters.'.tr(),
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(cs.surfaceContainerLowest),
          columns: [
            DataColumn(label: Text('Date'.tr())),
            DataColumn(label: Text('Customer'.tr())),
            DataColumn(label: Text('Branch'.tr())),
            DataColumn(label: Text('Order ID'.tr())),
            DataColumn(label: Text('Rating'.tr())),
            DataColumn(label: Text('Source'.tr())),
            DataColumn(label: Text('Status'.tr())),
            DataColumn(label: Text('Action'.tr())),
          ],
          rows: items.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(dateFormat.format(item.submittedAt))),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      item.customerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                DataCell(Text(item.branchName)),
                DataCell(Text(item.orderId)),
                DataCell(_buildRatingStars(item.rating)),
                DataCell(_buildSourceChip(item.source)),
                DataCell(_buildStatusChip(item.status, cs)),
                DataCell(
                  IconButton(
                    tooltip: 'View'.tr(),
                    icon: const Icon(Icons.visibility_outlined, size: 20),
                    onPressed: () => _onView(item),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(cs),
              SizedBox(height: AppSpacing.lg),
              _buildSummaryCards(cs),
              SizedBox(height: AppSpacing.md),
              AppCard(
                child: _buildFilterBar(cs),
              ),
              SizedBox(height: AppSpacing.md),
              AppCard(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: _buildTable(cs),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable summary metric card
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Response detail dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ResponseDetailDialog extends StatelessWidget {
  final _CustomerResponseItem item;

  const _ResponseDetailDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return AlertDialog(
      title: Text('Response Details'.tr()),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Customer'.tr(), value: item.customerName),
            _DetailRow(label: 'Branch'.tr(), value: item.branchName),
            _DetailRow(label: 'Order ID'.tr(), value: item.orderId),
            _DetailRow(label: 'Submitted'.tr(), value: dateFormat.format(item.submittedAt)),
            _DetailRow(label: 'Rating'.tr(), value: '${item.rating.toInt()} / 5'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'.tr()),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
