import 'package:flutter_test/flutter_test.dart';
import 'package:back_office/data/models/restaurant_inventory/purchase_order_model.dart';
import 'package:back_office/data/models/restaurant_inventory/goods_receipt_model.dart';
import 'package:back_office/data/models/restaurant_inventory/supplier_invoice_model.dart';

void main() {
  group('Restaurant Procurement Model Mapping Tests', () {
    test('PurchaseOrderModel mapping', () {
      final now = DateTime.now();
      final map = {
        'po_no': 'PO-TEST-01',
        'po_date': now.toIso8601String(),
        'vendor_id': '5f67b5e408a2fc24bc6880bd',
        'delivery_date': now.toIso8601String(),
        'delivery_address': 'Main warehouse delivery',
        'status': 'submitted',
        'amount': 250.0,
        'tax_amount': 12.5,
        'total_with_tax': 262.5,
        'remark': 'urgent delivery',
        'created_by': 'Admin',
        'created_at': now.toIso8601String(),
        'items': [
          {
            'id': 'ITEM-PO-01',
            'raw_material_id': '5f67b5e408a2fc24bc6880bd',
            'unit_id': '5f67b5e408a2fc24bc6880bd',
            'qty': 25.0,
            'rate': 10.0,
            'tax_id': '5f67b5e408a2fc24bc6880bd',
            'tax_percent': 5.0,
            'tax_amount': 12.5,
            'line_total': 262.5,
            'remark': 'po item note',
          }
        ]
      };

      final model = PurchaseOrderModel.fromMap(map);
      expect(model.poNo, 'PO-TEST-01');
      expect(model.deliveryAddress, 'Main warehouse delivery');
      expect(model.status, 'submitted');
      expect(model.amount, 250.0);
      expect(model.items.length, 1);
      expect(model.items.first.id, 'ITEM-PO-01');

      final backToMap = model.toMap();
      expect(backToMap['po_no'], 'PO-TEST-01');
      expect(backToMap['items'].length, 1);
    });

    test('GoodsReceiptModel mapping', () {
      final now = DateTime.now();
      final map = {
        'grn_no': 'GRN-TEST-01',
        'grn_date': now.toIso8601String(),
        'purchase_order_id': '5f67b5e408a2fc24bc6880bd',
        'vendor_id': '5f67b5e408a2fc24bc6880bd',
        'status': 'posted',
        'amount': 150.0,
        'tax_amount': 7.5,
        'total_with_tax': 157.5,
        'remark': 'received in good shape',
        'created_by': 'Admin',
        'created_at': now.toIso8601String(),
        'items': [
          {
            'id': 'ITEM-GRN-01',
            'raw_material_id': '5f67b5e408a2fc24bc6880bd',
            'unit_id': '5f67b5e408a2fc24bc6880bd',
            'qty': 15.0,
            'rate': 10.0,
            'tax_percent': 5.0,
            'tax_amount': 7.5,
            'line_total': 157.5,
            'batch_no': 'B-GRN-99',
            'expiry_date': now.toIso8601String(),
            'remark': 'grn item note',
          }
        ]
      };

      final model = GoodsReceiptModel.fromMap(map);
      expect(model.grnNo, 'GRN-TEST-01');
      expect(model.purchaseOrderId, '5f67b5e408a2fc24bc6880bd');
      expect(model.status, 'posted');
      expect(model.items.length, 1);
      expect(model.items.first.batchNo, 'B-GRN-99');

      final backToMap = model.toMap();
      expect(backToMap['grn_no'], 'GRN-TEST-01');
    });

    test('SupplierInvoiceModel mapping', () {
      final now = DateTime.now();
      final map = {
        'invoice_no': 'INV-TEST-01',
        'invoice_date': now.toIso8601String(),
        'grn_id': '5f67b5e408a2fc24bc6880bd',
        'purchase_order_id': '5f67b5e408a2fc24bc6880bd',
        'vendor_id': '5f67b5e408a2fc24bc6880bd',
        'status': 'draft',
        'amount': 300.0,
        'tax_amount': 15.0,
        'total_with_tax': 315.0,
        'remark': 'payment pending',
        'created_by': 'Accountant',
        'created_at': now.toIso8601String(),
        'items': [
          {
            'id': 'ITEM-INV-01',
            'raw_material_id': '5f67b5e408a2fc24bc6880bd',
            'unit_id': '5f67b5e408a2fc24bc6880bd',
            'qty': 30.0,
            'rate': 10.0,
            'tax_percent': 5.0,
            'tax_amount': 15.0,
            'line_total': 315.0,
            'remark': 'invoice item note',
          }
        ]
      };

      final model = SupplierInvoiceModel.fromMap(map);
      expect(model.invoiceNo, 'INV-TEST-01');
      expect(model.grnId, '5f67b5e408a2fc24bc6880bd');
      expect(model.purchaseOrderId, '5f67b5e408a2fc24bc6880bd');
      expect(model.amount, 300.0);
      expect(model.items.length, 1);

      final backToMap = model.toMap();
      expect(backToMap['invoice_no'], 'INV-TEST-01');
    });
  });
}
