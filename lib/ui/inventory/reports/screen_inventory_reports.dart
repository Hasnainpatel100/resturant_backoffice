import 'package:flutter/material.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/purchase_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/stock_adjustment_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/stock_transfer_repository_mock_impl.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/data/models/inventory/purchase_model.dart';
import 'package:back_office/data/models/inventory/stock_adjustment_model.dart';
import 'package:back_office/data/models/inventory/stock_transfer_model.dart';
import 'package:back_office/shared/shared.dart';
import 'package:intl/intl.dart';

class ScreenInventoryReports extends StatefulWidget {
  final String brandId;

  const ScreenInventoryReports({super.key, required this.brandId});

  @override
  State<ScreenInventoryReports> createState() => _ScreenInventoryReportsState();
}

class _ScreenInventoryReportsState extends State<ScreenInventoryReports>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Repositories
  final _itemRepo = ItemRepositoryMockImpl();
  final _purchaseRepo = PurchaseRepositoryMockImpl();
  final _adjustmentRepo = StockAdjustmentRepositoryMockImpl();
  final _transferRepo = StockTransferRepositoryMockImpl();

  // State loaded variables
  List<ItemModel> _items = [];
  List<PurchaseModel> _purchases = [];
  List<StockAdjustmentModel> _adjustments = [];
  List<StockTransferModel> _transfers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() => _loading = true);

    final itemRes = await _itemRepo.getItems(widget.brandId);
    final purRes = await _purchaseRepo.getPurchases(widget.brandId);
    final adjRes = await _adjustmentRepo.getAdjustments(widget.brandId);
    final transRes = await _transferRepo.getTransfers(widget.brandId);

    setState(() {
      _items = itemRes.getOrElse((_) => throw _).items;
      _purchases = purRes.getOrElse((_) => throw _).items;
      _adjustments = adjRes.getOrElse((_) => throw _).items;
      _transfers = transRes.getOrElse((_) => throw _).items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Reports Data',
            onPressed: _loadReportData,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Current Stock'),
            Tab(icon: Icon(Icons.warning_amber_outlined), text: 'Low Stock'),
            Tab(icon: Icon(Icons.history_toggle_off), text: 'Movement'),
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Valuation'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentStockTab(cs),
                _buildLowStockTab(cs),
                _buildMovementTab(cs),
                _buildValuationTab(cs),
              ],
            ),
    );
  }

  // ── 1. Current Stock Tab
  Widget _buildCurrentStockTab(ColorScheme cs) {
    if (_items.isEmpty) {
      return const AppEmptyState(title: 'No inventory items registered');
    }
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isLow = item.isLowStock;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isLow ? Colors.orange.withOpacity(0.1) : cs.primary.withOpacity(0.1),
              child: Icon(
                Icons.inventory_2_outlined,
                color: isLow ? Colors.orange : cs.primary,
                size: 20,
              ),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Category: ${item.categoryName ?? "—"} • SKU: ${item.sku ?? "—"}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.currentStock} ${item.unitCode ?? ""}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isLow ? Colors.orange : cs.onSurface,
                  ),
                ),
                Text(
                  isLow ? 'Low Stock Alert' : 'In Stock',
                  style: TextStyle(
                    fontSize: 11,
                    color: isLow ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 2. Low Stock Tab
  Widget _buildLowStockTab(ColorScheme cs) {
    final lowStockItems = _items.where((i) => i.isLowStock).toList();
    if (lowStockItems.isEmpty) {
      return const AppEmptyState(
        icon: Icons.check_circle_outline,
        title: 'All Stock Levels Healthy',
        subtitle: 'No items are currently below their alert quantities.',
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: lowStockItems.length,
      itemBuilder: (context, index) {
        final item = lowStockItems[index];
        return Card(
          color: Colors.orange.withOpacity(0.05),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.2),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Min Alert level: ${item.alertQty} ${item.unitCode ?? ""}'),
            trailing: Text(
              'Stock: ${item.currentStock} ${item.unitCode ?? ""}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
            ),
          ),
        );
      },
    );
  }

  // ── 3. Stock Movement Tab (Aggregates POs, Adjustments, Transfers)
  Widget _buildMovementTab(ColorScheme cs) {
    final List<_MovementLog> logs = [];

    // Add purchases
    for (final p in _purchases) {
      for (final pi in p.items) {
        logs.add(_MovementLog(
          date: p.purchaseDate,
          ref: p.referenceNo,
          type: 'Stock In (Purchase)',
          itemName: pi.itemName,
          qty: pi.quantity,
          badgeColor: Colors.green,
        ));
      }
    }

    // Add adjustments
    for (final adj in _adjustments) {
      for (final ai in adj.items) {
        logs.add(_MovementLog(
          date: adj.adjustmentDate,
          ref: adj.referenceNo,
          type: 'Stock Adjustment (${ai.reason})',
          itemName: ai.itemName,
          qty: ai.quantity,
          badgeColor: ai.quantity > 0 ? Colors.blue : Colors.red,
        ));
      }
    }

    // Add transfers
    for (final t in _transfers) {
      for (final ti in t.items) {
        logs.add(_MovementLog(
          date: t.transferDate,
          ref: t.referenceNo,
          type: 'Transfer: ${t.fromWarehouseName} ➔ ${t.toWarehouseName}',
          itemName: ti.itemName,
          qty: ti.quantity,
          badgeColor: Colors.purple,
        ));
      }
    }

    // Sort by newest date
    logs.sort((a, b) => b.date.compareTo(a.date));

    if (logs.isEmpty) {
      return const AppEmptyState(title: 'No stock movements logged yet');
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(log.date),
        );

        return Card(
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    log.itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${log.qty > 0 ? "+" : ""}${log.qty.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: log.qty > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: log.badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log.type,
                        style: TextStyle(color: log.badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(log.ref, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(dateStr, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 4. Valuation Tab
  Widget _buildValuationTab(ColorScheme cs) {
    double totalCostVal = 0.0;
    double totalSaleVal = 0.0;

    for (final item in _items) {
      totalCostVal += item.currentStock * item.costPrice;
      totalSaleVal += item.currentStock * item.sellingPrice;
    }

    final potentialProfit = totalSaleVal - totalCostVal;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Valuation Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on current stock levels across all categories.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          SizedBox(height: AppSpacing.lg),

          // Total cost price card
          _ValuationCard(
            label: 'Total Valuation at Cost',
            val: totalCostVal,
            color: cs.secondary,
            icon: Icons.shopping_bag_outlined,
          ),
          SizedBox(height: AppSpacing.md),

          // Total selling price card
          _ValuationCard(
            label: 'Total Valuation at Retail',
            val: totalSaleVal,
            color: cs.primary,
            icon: Icons.sell_outlined,
          ),
          SizedBox(height: AppSpacing.md),

          // Potential margin card
          _ValuationCard(
            label: 'Potential Profit Margin',
            val: potentialProfit,
            color: Colors.green,
            icon: Icons.trending_up,
          ),
        ],
      ),
    );
  }
}

class _ValuationCard extends StatelessWidget {
  final String label;
  final double val;
  final Color color;
  final IconData icon;

  const _ValuationCard({
    required this.label,
    required this.val,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${val.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementLog {
  final int date;
  final String ref;
  final String type;
  final String itemName;
  final double qty;
  final Color badgeColor;

  const _MovementLog({
    required this.date,
    required this.ref,
    required this.type,
    required this.itemName,
    required this.qty,
    required this.badgeColor,
  });
}
