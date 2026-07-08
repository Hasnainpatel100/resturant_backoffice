import 'package:flutter_test/flutter_test.dart';
import 'package:back_office/data/models/restaurant_inventory/manual_stock_entry_model.dart';
import 'package:back_office/data/models/restaurant_inventory/manual_stock_out_model.dart';

void main() {
  group('Restaurant Manual Inventory Model Mapping Tests', () {
    test('ManualStockEntryModel mapping with embedded items', () {
      final now = DateTime.now();
      final map = {
        'entry_no': 'ENT-TEST-01',
        'entry_date': now.toIso8601String(),
        'warehouse_id': '5f67b5e408a2fc24bc6880bd',
        'vendor_id': '5f67b5e408a2fc24bc6880bd',
        'bill_type_id': '5f67b5e408a2fc24bc6880bd',
        'no_of_raw_material': 1,
        'amount': 100.0,
        'tax_amount': 5.0,
        'total_with_tax': 105.0,
        'status': 'draft',
        'remark': 'test entry remark',
        'created_by': 'Test User',
        'created_at': now.toIso8601String(),
        'items': [
          {
            'id': 'ITEM-01',
            'raw_material_id': '5f67b5e408a2fc24bc6880bd',
            'unit_id': '5f67b5e408a2fc24bc6880bd',
            'qty': 10.0,
            'rate': 10.0,
            'tax_id': '5f67b5e408a2fc24bc6880bd',
            'tax_percent': 5.0,
            'tax_amount': 5.0,
            'line_total': 105.0,
            'batch_no': 'B01',
            'expiry_date': now.toIso8601String(),
            'remark': 'item remark',
          }
        ]
      };

      final model = ManualStockEntryModel.fromMap(map);
      expect(model.entryNo, 'ENT-TEST-01');
      expect(model.noOfRawMaterial, 1);
      expect(model.amount, 100.0);
      expect(model.taxAmount, 5.0);
      expect(model.totalWithTax, 105.0);
      expect(model.status, 'draft');
      expect(model.items.length, 1);

      final item = model.items.first;
      expect(item.id, 'ITEM-01');
      expect(item.qty, 10.0);
      expect(item.rate, 10.0);
      expect(item.taxPercent, 5.0);
      expect(item.taxAmount, 5.0);
      expect(item.lineTotal, 105.0);
      expect(item.batchNo, 'B01');

      final backToMap = model.toMap();
      expect(backToMap['entry_no'], 'ENT-TEST-01');
      expect(backToMap['items'].length, 1);
      expect(backToMap['items'][0]['id'], 'ITEM-01');
    });

    test('ManualStockOutModel mapping with embedded items', () {
      final now = DateTime.now();
      final map = {
        'stock_out_no': 'OUT-TEST-01',
        'stock_out_date': now.toIso8601String(),
        'warehouse_id': '5f67b5e408a2fc24bc6880bd',
        'reason_id': '5f67b5e408a2fc24bc6880bd',
        'status': 'posted',
        'remark': 'test out remark',
        'created_by': 'Test User',
        'created_at': now.toIso8601String(),
        'items': [
          {
            'id': 'ITEM-02',
            'raw_material_id': '5f67b5e408a2fc24bc6880bd',
            'unit_id': '5f67b5e408a2fc24bc6880bd',
            'qty': 5.0,
            'rate': 8.0,
            'line_amount': 40.0,
            'remark': 'item out remark',
          }
        ]
      };

      final model = ManualStockOutModel.fromMap(map);
      expect(model.stockOutNo, 'OUT-TEST-01');
      expect(model.status, 'posted');
      expect(model.items.length, 1);

      final item = model.items.first;
      expect(item.id, 'ITEM-02');
      expect(item.qty, 5.0);
      expect(item.rate, 8.0);
      expect(item.lineAmount, 40.0);

      final backToMap = model.toMap();
      expect(backToMap['stock_out_no'], 'OUT-TEST-01');
      expect(backToMap['items'].length, 1);
      expect(backToMap['items'][0]['line_amount'], 40.0);
    });
  });
}
