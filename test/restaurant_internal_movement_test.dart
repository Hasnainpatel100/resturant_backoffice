import 'package:flutter_test/flutter_test.dart';
import 'package:back_office/data/models/restaurant_inventory/indent_model.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_transfer_model.dart';

void main() {
  group('Restaurant Internal Movement (Phase 4) Model Mapping Tests', () {
    test('IndentModel mapping', () {
      final now = DateTime.now();
      final map = {
        'indent_no': 'IND-TEST-01',
        'indent_date': now.toIso8601String(),
        'from_warehouse_id': '5f67b5e408a2fc24bc6880bd',
        'to_warehouse_id': '5f67b5e408a2fc24bc6880be',
        'status': 'draft',
        'remark': 'need items soon',
        'created_by': 'Chef John',
        'created_at': now.toIso8601String(),
        'items': [
          {
            'id': 'ITEM-IND-01',
            'raw_material_id': '5f67b5e408a2fc24bc6880bd',
            'unit_id': '5f67b5e408a2fc24bc6880bd',
            'qty_request': 50.0,
            'qty_approved': 40.0,
            'remark': 'half size packaging allowed',
          }
        ]
      };

      final model = IndentModel.fromMap(map);
      expect(model.indentNo, 'IND-TEST-01');
      expect(model.fromWarehouseId, '5f67b5e408a2fc24bc6880bd');
      expect(model.toWarehouseId, '5f67b5e408a2fc24bc6880be');
      expect(model.status, 'draft');
      expect(model.items.length, 1);
      expect(model.items.first.qtyRequest, 50.0);
      expect(model.items.first.qtyApproved, 40.0);

      final backToMap = model.toMap();
      expect(backToMap['indent_no'], 'IND-TEST-01');
      expect(backToMap['items'].length, 1);
    });

    test('StockTransferModel mapping', () {
      final now = DateTime.now();
      final map = {
        'transfer_no': 'TRF-TEST-01',
        'transfer_date': now.toIso8601String(),
        'from_warehouse_id': '5f67b5e408a2fc24bc6880bd',
        'to_warehouse_id': '5f67b5e408a2fc24bc6880be',
        'indent_id': '5f67b5e408a2fc24bc6880bd',
        'status': 'posted',
        'remark': 'delivered via transit van',
        'created_by': 'Driver Sam',
        'created_at': now.toIso8601String(),
        'items': [
          {
            'id': 'ITEM-TRF-01',
            'raw_material_id': '5f67b5e408a2fc24bc6880bd',
            'unit_id': '5f67b5e408a2fc24bc6880bd',
            'qty_transfer': 45.0,
            'remark': 'all items ok',
          }
        ]
      };

      final model = StockTransferModel.fromMap(map);
      expect(model.transferNo, 'TRF-TEST-01');
      expect(model.fromWarehouseId, '5f67b5e408a2fc24bc6880bd');
      expect(model.toWarehouseId, '5f67b5e408a2fc24bc6880be');
      expect(model.indentId, '5f67b5e408a2fc24bc6880bd');
      expect(model.status, 'posted');
      expect(model.items.length, 1);
      expect(model.items.first.qtyTransfer, 45.0);

      final backToMap = model.toMap();
      expect(backToMap['transfer_no'], 'TRF-TEST-01');
    });
  });
}
