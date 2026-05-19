import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/theme_constants.dart';

class ScreenBranchPlanHistory extends StatelessWidget {
  final String brandId;
  final String branchId;

  const ScreenBranchPlanHistory({
    super.key,
    required this.brandId,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan History'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => context.pushNamed(
              'branchPlanForm',
              pathParameters: {
                'brandId': brandId,
                'branchId': branchId,
              },
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: cs.outline),
            SizedBox(height: AppSpacing.md),
            const Text('Plan history will be listed here'),
            SizedBox(height: AppSpacing.md),
            Text('Branch: $branchId', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
