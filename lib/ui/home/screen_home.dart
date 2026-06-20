import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/bill_repository_impl.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';
import 'package:back_office/ui/auth/login/cubit_session.dart';
import 'package:back_office/shared/helpers/format_number.dart';

import 'cubit_dashboard.dart';
import 'state_dashboard.dart';
import '../../data/models/dashboard_report_model.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<CubitSession>().state;
    final brandId = sessionState.user?.brandId;

    if (brandId == null || brandId.isEmpty) {
      return Scaffold(
        appBar: AppTopBar(title: 'Dashboard'),
        body: const Center(
          child: Text('No active brand found. Please contact support.'),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<CubitBranch>(
          create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranches(brandId),
        ),
        BlocProvider<CubitDashboard>(
          create: (context) => CubitDashboard(repository: BillRepositoryImpl()),
        ),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<CubitSession>().state.user;
      final branchId = user?.branchId;

      if (branchId != null && branchId.isNotEmpty) {
        context.read<CubitDashboard>().loadDashboard(branchId: branchId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<CubitBranch, StateBranch>(
      listener: (context, branchState) {
        if (branchState.status == BranchStatus.loaded && branchState.branches.isNotEmpty) {
          final dashboardCubit = context.read<CubitDashboard>();
          if (dashboardCubit.state.selectedBranchId == null) {
            // Default to the first branch in the loaded branches
            final defaultBranch = branchState.branches.first.id;
            dashboardCubit.loadDashboard(branchId: defaultBranch);
          }
        }
      },
      child: BlocBuilder<CubitDashboard, StateDashboard>(
        builder: (context, dashboardState) {
          return Scaffold(
            backgroundColor: cs.surface,
            appBar: AppTopBar(
              title: 'Dashboard',
              actions: [
                _buildBranchSelector(context, dashboardState),
                const SizedBox(width: 12),
                _buildDateRangeSelector(context, dashboardState),
                const SizedBox(width: 16),
              ],
            ),
            body: SafeArea(
              child: _buildBody(context, dashboardState),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBranchSelector(BuildContext context, StateDashboard dashboardState) {
    return BlocBuilder<CubitBranch, StateBranch>(
      builder: (context, branchState) {
        if (branchState.branches.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
            ),
            value: branchState.branches.any((b) => b.id == dashboardState.selectedBranchId)
                ? dashboardState.selectedBranchId
                : null,
            hint: const Text('Select Branch'),
            items: branchState.branches.map((b) {
              return DropdownMenuItem(value: b.id, child: Text(b.displayName));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<CubitDashboard>().changeBranch(value);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, StateDashboard dashboardState) {
    final df = DateFormat('MMM dd, yyyy');
    final rangeText = '${df.format(dashboardState.fromDate)} - ${df.format(dashboardState.toDate)}';

    return OutlinedButton.icon(
      icon: const Icon(Icons.date_range, size: 18),
      label: Text(rangeText),
      onPressed: () async {
        final selectedRange = await showDateRangePicker(
          context: context,
          initialDateRange: DateTimeRange(
            start: dashboardState.fromDate,
            end: dashboardState.toDate,
          ),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );

        if (selectedRange != null && mounted) {
          context.read<CubitDashboard>().changeDateRange(
                selectedRange.start,
                selectedRange.end,
              );
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, StateDashboard state) {
    final cs = Theme.of(context).colorScheme;

    if (state.status == DashboardStatus.branchSelectionRequired) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.dashboard_outlined, size: 64, color: cs.outline),
              const SizedBox(height: 16),
              Text(
                'Please select a branch from the dropdown above to view the dashboard report.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == DashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == DashboardStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Error loading dashboard report',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<CubitDashboard>().loadDashboard();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.report == null) {
      return const Center(
        child: Text('No report data available.'),
      );
    }

    final report = state.report!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDashboardHeader(context, state),
          const SizedBox(height: 24),
          _buildMetricsGrid(context, report),
          const SizedBox(height: 24),
          _buildChartsGrid(context, report),
          const SizedBox(height: 24),
          _buildTablesGrid(context, report),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context, StateDashboard state) {
    final df = DateFormat('MMM dd, yyyy');
    final subtitle = 'Business Performance Overview • ${df.format(state.fromDate)} - ${df.format(state.toDate)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Report',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, DashboardReportModel report) {
    final summary = report.summary;
    final cancellation = report.cancellationReport;

    final metrics = [
      _MetricCard(
        title: 'Total Revenue',
        value: '₹${formatNumber(summary.totalRevenue)}',
        subtitle: '${summary.totalBills} bills generated',
        color: Colors.purple.shade600,
        icon: Icons.currency_rupee,
      ),
      _MetricCard(
        title: 'Avg Order Value',
        value: '₹${formatNumber(double.parse(summary.avgOrderValue.toStringAsFixed(2)))}',
        subtitle: 'Per bill average',
        color: Colors.amber.shade700,
        icon: Icons.analytics_outlined,
      ),
      _MetricCard(
        title: 'Collection Rate',
        value: '${summary.collectionPercent.toStringAsFixed(1)}%',
        subtitle: 'Pending collection',
        color: Colors.green.shade600,
        icon: Icons.pie_chart_outline,
        progressValue: summary.collectionPercent / 100,
      ),
      _MetricCard(
        title: 'Outstanding',
        value: '₹${formatNumber(summary.outstandingAmount)}',
        subtitle: 'Pending collection',
        color: Colors.orange.shade700,
        icon: Icons.pending_actions,
      ),
      _MetricCard(
        title: 'Cancelled',
        value: '${cancellation.rate.toStringAsFixed(1)}%',
        subtitle: '${cancellation.count} bill cancelled',
        color: Colors.red.shade600,
        icon: Icons.cancel_outlined,
      ),
      _MetricCard(
        title: 'Total Discount',
        value: '₹${formatNumber(summary.totalDiscount)}',
        subtitle: 'Given to customers',
        color: Colors.teal.shade600,
        icon: Icons.discount_outlined,
      ),
      _MetricCard(
        title: 'CGST Collected',
        value: '₹${formatNumber(summary.totalCgst)}',
        subtitle: 'Central tax',
        color: Colors.blue.shade600,
        icon: Icons.account_balance_outlined,
      ),
      _MetricCard(
        title: 'SGST Collected',
        value: '₹${formatNumber(summary.totalSgst)}',
        subtitle: 'State tax',
        color: Colors.blue.shade600,
        icon: Icons.account_balance_outlined,
      ),
    ];

    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    if (width <= 600) {
      crossAxisCount = 1;
    } else if (width <= 1024) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 110,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) => metrics[index],
    );
  }

  Widget _buildChartsGrid(BuildContext context, DashboardReportModel report) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 800;

    final charts = [
      _buildSalesByPaymentMode(report),
      _buildSalesByServiceType(report),
      _buildHourlySalesDistribution(report),
      _buildDayWiseSales(report),
      _buildTopSellingItems(report),
      _buildTaxBreakdown(report),
    ];

    if (isMobile) {
      return Column(
        children: charts.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: c,
            )).toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 350,
      ),
      itemCount: charts.length,
      itemBuilder: (context, index) => charts[index],
    );
  }

  Widget _buildSalesByPaymentMode(DashboardReportModel report) {
    final List<Color> colors = [
      Colors.blue.shade600,
      Colors.orange.shade600,
      Colors.green.shade600,
      Colors.red.shade600,
      Colors.purple.shade600,
    ];

    final sections = List.generate(report.paymentModes.length, (index) {
      final pm = report.paymentModes[index];
      return PieChartSectionData(
        value: pm.amount,
        color: colors[index % colors.length],
        radius: 35,
        title: '',
      );
    });

    final legends = List.generate(report.paymentModes.length, (index) {
      final pm = report.paymentModes[index];
      return _LegendItem(
        color: colors[index % colors.length],
        label: pm.mode,
      );
    });

    return _buildChartContainer(
      title: 'Sales by Payment Mode',
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 45,
                sectionsSpace: 2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: legends,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesByServiceType(DashboardReportModel report) {
    final List<Color> colors = [
      Colors.purple.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
      Colors.amber.shade600,
      Colors.indigo.shade600,
  ];

    final sections = List.generate(report.serviceTypes.length, (index) {
      final st = report.serviceTypes[index];
      return PieChartSectionData(
        value: st.amount,
        color: colors[index % colors.length],
        radius: 35,
        title: '',
      );
    });

    final legends = List.generate(report.serviceTypes.length, (index) {
      final st = report.serviceTypes[index];
      return _LegendItem(
        color: colors[index % colors.length],
        label: st.type.replaceAll('_', ' '),
      );
    });

    return _buildChartContainer(
      title: 'Sales by Service Type',
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 45,
                sectionsSpace: 2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: legends,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlySalesDistribution(DashboardReportModel report) {
    final hourlyData = List<DashboardHourlySaleModel>.from(report.hourlySales)
      ..sort((a, b) => a.hour.compareTo(b.hour));

    double maxVal = 100.0;
    final barGroups = List.generate(hourlyData.length, (index) {
      final data = hourlyData[index];
      if (data.amount > maxVal) maxVal = data.amount;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.amount,
            color: Colors.purple.shade400,
            width: 28,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });

    // Determine nice Y-axis interval
    maxVal = (maxVal / 1000).ceil() * 1000.0;
    if (maxVal == 0) maxVal = 1000.0;

    return _buildChartContainer(
      title: 'Hourly Sales Distribution',
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade100,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                  return Text(
                    '₹${value.toInt()}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < hourlyData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${hourlyData[idx].hour}:00',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxVal,
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildDayWiseSales(DashboardReportModel report) {
    const daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const shortDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final dayAmountMap = {for (var item in report.dayWise) item.day: item.amount};
    final spots = List.generate(7, (index) {
      final day = daysOfWeek[index];
      final amount = dayAmountMap[day] ?? 0.0;
      return FlSpot(index.toDouble(), amount);
    });

    double maxAmount = 100.0;
    for (var spot in spots) {
      if (spot.y > maxAmount) maxAmount = spot.y;
    }
    maxAmount = (maxAmount / 1000).ceil() * 1000.0;
    if (maxAmount == 0) maxAmount = 1000.0;

    return _buildChartContainer(
      title: 'Day-Wise Sales',
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade100,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                  return Text(
                    '₹${value.toInt()}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        shortDays[idx],
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: maxAmount,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue.shade600,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue.shade600,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.shade600.withOpacity(0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingItems(DashboardReportModel report) {
    return _buildChartContainer(
      title: 'Top Selling Items',
      child: _TopItemsList(items: report.topItems),
    );
  }

  Widget _buildTaxBreakdown(DashboardReportModel report) {
    final taxData = [
      {'name': 'CGST', 'amount': report.taxReport.cgst},
      {'name': 'SGST', 'amount': report.taxReport.sgst},
      {'name': 'IGST', 'amount': report.taxReport.igst},
    ];

    double maxTaxVal = 100.0;
    final taxGroups = List.generate(taxData.length, (index) {
      final amount = taxData[index]['amount'] as double;
      if (amount > maxTaxVal) maxTaxVal = amount;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: Colors.blue.shade500,
            width: 36,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });

    maxTaxVal = (maxTaxVal / 20).ceil() * 20.0;
    if (maxTaxVal == 0) maxTaxVal = 100.0;

    return _buildChartContainer(
      title: 'Tax Breakdown',
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade100,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                  return Text(
                    '₹${value.toInt()}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < taxData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        taxData[idx]['name'] as String,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxTaxVal,
          barGroups: taxGroups,
        ),
      ),
    );
  }

  Widget _buildChartContainer({required String title, required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.md,
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildTablesGrid(BuildContext context, DashboardReportModel report) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 800;

    final tables = [
      _buildPaymentModesTable(report),
      _buildDiscountBreakdownTable(report),
      _buildDayWiseDetailsTable(report),
    ];

    if (isMobile) {
      return Column(
        children: tables.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: t,
            )).toList(),
      );
    }

    // 2-column or 3-column layout depending on size
    if (width <= 1200) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: tables[0]),
              const SizedBox(width: 16),
              Expanded(child: tables[1]),
            ],
          ),
          const SizedBox(height: 16),
          tables[2],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: tables[0]),
        const SizedBox(width: 16),
        Expanded(child: tables[1]),
        const SizedBox(width: 16),
        Expanded(child: tables[2]),
      ],
    );
  }

  Widget _buildPaymentModesTable(DashboardReportModel report) {
    final cs = Theme.of(context).colorScheme;
    final totalRevenue = report.summary.totalRevenue;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.md,
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Modes Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.outlineVariant))),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('MODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('COUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('SHARE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                ),
                ...report.paymentModes.map((pm) {
                  final share = totalRevenue > 0 ? (pm.amount / totalRevenue * 100).round() : 0;
                  return TableRow(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.3)))),
                    children: [
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: _buildPaymentBadge(pm.mode)),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text('${pm.count}', style: const TextStyle(fontSize: 13))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text('₹${formatNumber(pm.amount)}', style: const TextStyle(fontSize: 13))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text('$share%', style: const TextStyle(fontSize: 13))),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String mode) {
    Color bg;
    Color fg;
    if (mode == 'CARD') {
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade700;
    } else if (mode == 'UPI') {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
    } else if (mode == 'CASH') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade700;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          mode,
          style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
    );
  }

  Widget _buildDiscountBreakdownTable(DashboardReportModel report) {
    final cs = Theme.of(context).colorScheme;
    final disc = report.discountReport;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.md,
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discount Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.outlineVariant))),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('REASON', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                ),
                ...disc.byReason.entries.map((e) {
                  return TableRow(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.3)))),
                    children: [
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text(e.key, style: const TextStyle(fontSize: 13))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text('₹${formatNumber(e.value)}', style: const TextStyle(fontSize: 13))),
                    ],
                  );
                }),
                TableRow(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: Text('₹${formatNumber(disc.total)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayWiseDetailsTable(DashboardReportModel report) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.md,
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day-Wise Sales Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.outlineVariant))),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('DAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('ORDERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('REVENUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('AVG PER ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                ),
                ...report.dayWise.map((dw) {
                  final avgOrder = dw.count > 0 ? (dw.amount / dw.count) : 0.0;
                  return TableRow(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.3)))),
                    children: [
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text(dw.day, style: const TextStyle(fontSize: 13))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text('${dw.count}', style: const TextStyle(fontSize: 13))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text('₹${formatNumber(dw.amount)}', style: const TextStyle(fontSize: 13))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text('₹${formatNumber(double.parse(avgOrder.toStringAsFixed(2)))}', style: const TextStyle(fontSize: 13))),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final double? progressValue;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.md,
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurfaceVariant,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 2),
            if (progressValue != null) ...[
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 2),
            ],
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopItemsList extends StatelessWidget {
  final List<DashboardTopItemModel> items;

  const _TopItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (items.isEmpty) {
      return const Center(child: Text('No item data available'));
    }

    final displayedItems = items.take(5).toList();
    final maxQty = displayedItems.fold<int>(1, (prev, element) => prev > element.quantity ? prev : element.quantity);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: displayedItems.map((item) {
        final ratio = maxQty > 0 ? (item.quantity / maxQty) : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  Text(
                    '${item.quantity} units (₹${formatNumber(item.amount)})',
                    style: TextStyle(color: cs.outline, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}