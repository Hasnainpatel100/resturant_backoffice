import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/bill_repository_impl.dart';
import 'package:back_office/ui/bills/cubit_bill.dart';
import 'package:back_office/ui/bills/state_bill.dart';
import 'package:back_office/shared/helpers/format_number.dart';

class ScreenBillDetail extends StatelessWidget {
  final String brandId;
  final String billId;

  const ScreenBillDetail({super.key, required this.brandId, required this.billId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => CubitBill(repository: BillRepositoryImpl())..loadBillDetail(billId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bill Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/brands/$brandId/bills'),
          ),
        ),
        body: BlocBuilder<CubitBill, StateBill>(
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
                    Text(state.errorMessage ?? 'Error loading bill details'),
                    SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CubitBill>().loadBillDetail(billId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final bill = state.activeBill;
            if (bill == null) {
              return const Center(child: Text('Bill not found'));
            }

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorders.lg,
                      side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Invoice Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'INVOICE',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: cs.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bill.billNumber,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              _buildStatusBadge(bill.paymentStatus, isPayment: true),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),

                          // Metadata Fields
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMetaItem('Date', bill.billDate),
                                    const SizedBox(height: 12),
                                    _buildMetaItem('Service Type', bill.serviceType),
                                    const SizedBox(height: 12),
                                    if (bill.tableName != null)
                                      _buildMetaItem('Table Name', bill.tableName!),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMetaItem('Payment Mode', bill.paymentMode),
                                    const SizedBox(height: 12),
                                    if (bill.waiterName != null)
                                      _buildMetaItem('Waiter', bill.waiterName!),
                                    const SizedBox(height: 12),
                                    _buildMetaItem('Status', bill.status),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),

                          // Itemized Table Header
                          Text(
                            'ORDER ITEMS',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.outline,
                                ),
                          ),
                          const SizedBox(height: 12),

                          // Table of Items
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bill.items.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = bill.items[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: item.isVeg ? Colors.green : Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item.name,
                                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (item.size != null && item.size!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Size: ${item.size}',
                                              style: TextStyle(color: cs.outline, fontSize: 12),
                                            ),
                                          ],
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.categoryName} • Tax: ${item.taxPercentage}% (₹${formatNumber(item.taxAmount)})',
                                            style: TextStyle(color: cs.outline, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${item.quantity} x ₹${formatNumber(item.unitPrice)}',
                                      style: TextStyle(color: cs.outline),
                                    ),
                                    const SizedBox(width: 24),
                                    Text(
                                      '₹${formatNumber(item.total)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),

                          // Summary Totals
                          _buildSummaryRow('Subtotal', '₹${formatNumber(bill.subTotal)}', cs),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Tax Amount', '₹${formatNumber(bill.taxAmount)}', cs),
                          if (bill.packagingCharges > 0) ...[
                            const SizedBox(height: 8),
                            _buildSummaryRow('Packaging Charges', '₹${formatNumber(bill.packagingCharges)}', cs),
                          ],
                          if (bill.deliveryCharges > 0) ...[
                            const SizedBox(height: 8),
                            _buildSummaryRow('Delivery Charges', '₹${formatNumber(bill.deliveryCharges)}', cs),
                          ],
                          if (bill.tipAmount > 0) ...[
                            const SizedBox(height: 8),
                            _buildSummaryRow('Tip Amount', '₹${formatNumber(bill.tipAmount)}', cs),
                          ],
                          if (bill.discountAmount > 0) ...[
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Discount (${bill.discountPercent}%)',
                              '-₹${formatNumber(bill.discountAmount)}',
                              cs,
                              valueColor: Colors.green,
                            ),
                            if (bill.discountReason != null && bill.discountReason!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  'Reason: ${bill.discountReason}',
                                  style: TextStyle(color: cs.outline, fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ],

                          const SizedBox(height: 16),
                          const Divider(height: 1, thickness: 1.5),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL AMOUNT',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '₹${formatNumber(bill.totalAmount)}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: cs.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Amount Paid', '₹${formatNumber(bill.amountPaid)}', cs, isSmall: true),
                          const SizedBox(height: 4),
                          _buildSummaryRow('Change Returned', '₹${formatNumber(bill.changeAmount)}', cs, isSmall: true),

                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),

                          // Print Info Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Created By: ${bill.createdBy}',
                                style: TextStyle(color: cs.outline, fontSize: 11),
                              ),
                              Text(
                                'Printed: ${bill.printCount} time(s)',
                                style: TextStyle(color: cs.outline, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, ColorScheme cs, {Color? valueColor, bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: cs.outline,
            fontSize: isSmall ? 13 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isSmall ? FontWeight.normal : FontWeight.w600,
            fontSize: isSmall ? 13 : 14,
            color: valueColor,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppBorders.sm,
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        isPayment ? 'PAYMENT: $status' : status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
