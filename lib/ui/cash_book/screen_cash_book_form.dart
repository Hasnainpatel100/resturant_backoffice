import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../data/models/cash_book/cash_book_model.dart';
import '../../data/models/cash_book/cash_transaction_type.dart';
import '../../shared/shared.dart';

/// New / Edit Cash Book Entry form.
///
/// Pass [existing] to pre-populate the form for editing.
class ScreenCashBookForm extends StatefulWidget {
  final String brandId;
  final CashBookModel? existing;

  const ScreenCashBookForm({
    super.key,
    required this.brandId,
    this.existing,
  });

  @override
  State<ScreenCashBookForm> createState() => _ScreenCashBookFormState();
}

class _ScreenCashBookFormState extends State<ScreenCashBookForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _refNoCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // State
  CashTransactionType _txType = CashTransactionType.cashSale;
  DateTime _txDate = DateTime.now();
  String _paymentMethod = 'Cash';
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  static const _paymentMethods = ['Cash', 'Cheque', 'Bank Transfer', 'Other'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _txType = e.transactionType;
      _refNoCtrl.text = e.referenceNo ?? '';
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _descCtrl.text = e.description ?? '';
      _notesCtrl.text = e.notes ?? '';
      _txDate = e.transactionDateTime;
      _paymentMethod = e.paymentMethod ?? 'Cash';
    } else {
      _refNoCtrl.text = _generateRef(_txType);
    }
  }

  @override
  void dispose() {
    _refNoCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _generateRef(CashTransactionType type) {
    final seq = (DateTime.now().millisecondsSinceEpoch % 10000)
        .toString()
        .padLeft(4, '0');
    return switch (type) {
      CashTransactionType.cashSale => 'SALE-$seq',
      CashTransactionType.cashPurchase => 'PURCH-$seq',
      CashTransactionType.customerPayment => 'CPAY-$seq',
      CashTransactionType.supplierPayment => 'SPAY-$seq',
      CashTransactionType.expense => 'EXP-$seq',
      CashTransactionType.deposit => 'DEP-$seq',
      CashTransactionType.withdrawal => 'WD-$seq',
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _txDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _txDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      _showError('Amount must be greater than zero.');
      return;
    }

    setState(() => _isSaving = true);

    // TODO: Wire up to your actual datasource / controller.
    await Future.delayed(const Duration(milliseconds: 600)); // sim save

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing
            ? 'Entry updated successfully'
            : 'Entry saved successfully'),
        backgroundColor: Colors.green.shade600,
      ),
    );
    Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade600),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        title: Text(
          _isEditing ? 'Edit Cash Entry' : 'New Cash Entry',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Scrollable form body ─────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  // ── Transaction Type Selector ──────────────────────────
                  _SectionCard(
                    title: 'Transaction Type',
                    icon: Icons.category_rounded,
                    child: _TypeSelector(
                      selected: _txType,
                      onChanged: (t) => setState(() {
                        _txType = t;
                        if (!_isEditing) {
                          _refNoCtrl.text = _generateRef(t);
                        }
                      }),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // ── Entry Details ──────────────────────────────────────
                  _SectionCard(
                    title: 'Entry Details',
                    icon: Icons.edit_note_rounded,
                    child: Column(
                      children: [
                        // Reference No
                        TextFormField(
                          controller: _refNoCtrl,
                          readOnly: true,
                          decoration: _inputDeco(
                            context,
                            label: 'Reference No.',
                            prefix: const Icon(Icons.tag_rounded, size: 18),
                          ),
                        ),
                        SizedBox(height: AppSpacing.formFieldGap),

                        // Date picker
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: _inputDeco(
                              context,
                              label: 'Transaction Date',
                              prefix: const Icon(Icons.calendar_today_rounded,
                                  size: 18),
                              suffix: const Icon(Icons.arrow_drop_down_rounded),
                            ),
                            child: Text(
                              DateFormat('dd MMMM yyyy').format(_txDate),
                              style: tt.bodyLarge,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.formFieldGap),

                        // Amount
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                          decoration: _inputDeco(
                            context,
                            label: 'Amount',
                            prefix: const Icon(Icons.currency_rupee_rounded,
                                size: 18),
                          ),
                          style: tt.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _txType.isCashIn
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.formFieldGap),

                        // Payment method
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          items: _paymentMethods
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _paymentMethod = v ?? 'Cash'),
                          decoration: _inputDeco(
                            context,
                            label: 'Payment Method',
                            prefix:
                                const Icon(Icons.payment_rounded, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // ── Remarks ────────────────────────────────────────────
                  _SectionCard(
                    title: 'Remarks',
                    icon: Icons.notes_rounded,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 1,
                          decoration: _inputDeco(
                            context,
                            label: 'Description',
                            hint: 'Short description…',
                          ),
                        ),
                        SizedBox(height: AppSpacing.formFieldGap),
                        TextFormField(
                          controller: _notesCtrl,
                          maxLines: 3,
                          decoration: _inputDeco(
                            context,
                            label: 'Internal Notes',
                            hint: 'Optional longer notes…',
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),

            // ── Bottom Save Bar ──────────────────────────────────────────
            _BottomBar(
              txType: _txType,
              isSaving: _isSaving,
              onSave: _save,
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(
    BuildContext context, {
    required String label,
    String? hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      isDense: true,
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: cs.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              children: [
                Icon(icon, size: 18, color: cs.primary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction Type Selector — horizontal scrollable chips
// ─────────────────────────────────────────────────────────────────────────────
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});

  final CashTransactionType selected;
  final ValueChanged<CashTransactionType> onChanged;

  IconData _iconFor(CashTransactionType t) {
    return switch (t) {
      CashTransactionType.cashSale => Icons.point_of_sale_rounded,
      CashTransactionType.cashPurchase => Icons.shopping_cart_rounded,
      CashTransactionType.customerPayment => Icons.person_rounded,
      CashTransactionType.supplierPayment => Icons.local_shipping_rounded,
      CashTransactionType.expense => Icons.receipt_long_rounded,
      CashTransactionType.deposit => Icons.add_card_rounded,
      CashTransactionType.withdrawal => Icons.money_off_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CashTransactionType.values.map((t) {
          final isSelected = t == selected;
          final color = t.isCashIn ? Colors.green.shade600 : Colors.red.shade600;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.12)
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : cs.outlineVariant,
                  width: isSelected ? 1.5 : 0.8,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(t),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconFor(t),
                        size: 22,
                        color: isSelected ? color : cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.label,
                        style: tt.labelSmall?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? color : cs.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom action bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.txType,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  final CashTransactionType txType;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = txType.isCashIn ? Colors.green.shade600 : Colors.red.shade600;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel
          Expanded(
            child: OutlinedButton(
              onPressed: isSaving ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Save
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: isSaving ? null : onSave,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      txType.isCashIn
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 18,
                    ),
              label: Text(isSaving ? 'Saving…' : 'Save Entry'),
            ),
          ),
        ],
      ),
    );
  }
}
