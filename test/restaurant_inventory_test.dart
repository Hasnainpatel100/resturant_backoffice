import 'package:flutter_test/flutter_test.dart';
import 'package:back_office/data/models/restaurant_inventory/location_model.dart';
import 'package:back_office/data/models/restaurant_inventory/unit_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_group_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_tax_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_model.dart';
import 'package:back_office/data/models/restaurant_inventory/vendor_model.dart';
import 'package:back_office/data/models/restaurant_inventory/bill_type_model.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_reason_model.dart';

void main() {
  group('Restaurant Inventory Model Mapping Tests', () {
    test('LocationModel mapping', () {
      final now = DateTime.now();
      final map = {
        'location_code': 'L01',
        'location_name': 'Main Kitchen',
        'location_type': 'kitchen',
        'address': 'Ground Floor',
        'contact_no': '12345',
        'manager_name': 'Chef John',
        'is_active': true,
        'branch_id': '5f67b5e408a2fc24bc6880bd',
        'created_at': now.toIso8601String(),
      };

      final model = LocationModel.fromMap(map);
      expect(model.locationCode, 'L01');
      expect(model.locationName, 'Main Kitchen');
      expect(model.locationType, 'kitchen');
      expect(model.address, 'Ground Floor');
      expect(model.contactNo, '12345');
      expect(model.managerName, 'Chef John');
      expect(model.isActive, true);
      expect(model.branchId, '5f67b5e408a2fc24bc6880bd');

      final backToMap = model.toMap();
      expect(backToMap['location_code'], 'L01');
      expect(backToMap['location_name'], 'Main Kitchen');
      expect(backToMap['branch_id'].toHexString(), '5f67b5e408a2fc24bc6880bd');
    });

    test('UnitModel mapping', () {
      final now = DateTime.now();
      final map = {
        'unit_name': 'Kilogram',
        'short_name': 'kg',
        'decimal_allowed': true,
        'is_active': true,
        'created_at': now.toIso8601String(),
      };

      final model = UnitModel.fromMap(map);
      expect(model.unitName, 'Kilogram');
      expect(model.shortName, 'kg');
      expect(model.decimalAllowed, true);

      final backToMap = model.toMap();
      expect(backToMap['unit_name'], 'Kilogram');
      expect(backToMap['short_name'], 'kg');
    });

    test('RawMaterialGroupModel mapping', () {
      final now = DateTime.now();
      final map = {
        'group_name': 'Meat',
        'group_code': 'MT',
        'description': 'Fresh poultry & beef',
        'is_active': true,
        'created_at': now.toIso8601String(),
      };

      final model = RawMaterialGroupModel.fromMap(map);
      expect(model.groupName, 'Meat');
      expect(model.groupCode, 'MT');
      expect(model.description, 'Fresh poultry & beef');

      final backToMap = model.toMap();
      expect(backToMap['group_name'], 'Meat');
      expect(backToMap['group_code'], 'MT');
    });

    test('RawMaterialTaxModel mapping', () {
      final now = DateTime.now();
      final map = {
        'tax_name': 'VAT 5%',
        'tax_value': 5.0,
        'tax_type': 'percentage',
        'applies_on': 'purchase',
        'is_dividable': false,
        'include_in_rate': true,
        'is_active': true,
        'created_at': now.toIso8601String(),
      };

      final model = RawMaterialTaxModel.fromMap(map);
      expect(model.taxName, 'VAT 5%');
      expect(model.taxValue, 5.0);
      expect(model.taxType, 'percentage');
      expect(model.appliesOn, 'purchase');
      expect(model.includeInRate, true);

      final backToMap = model.toMap();
      expect(backToMap['tax_name'], 'VAT 5%');
      expect(backToMap['tax_value'], 5.0);
    });

    test('RawMaterialModel mapping', () {
      final now = DateTime.now();
      final map = {
        'material_code': 'RM01',
        'material_name': 'Chicken Breast',
        'short_name': 'Chicken',
        'group_id': '5f67b5e408a2fc24bc6880bd',
        'base_unit_id': '5f67b5e408a2fc24bc6880bc',
        'purchase_rate': 6.5,
        'selling_rate': 12.0,
        'reorder_level': 10.0,
        'track_inventory': true,
        'is_active': true,
        'created_at': now.toIso8601String(),
      };

      final model = RawMaterialModel.fromMap(map);
      expect(model.materialCode, 'RM01');
      expect(model.materialName, 'Chicken Breast');
      expect(model.purchaseRate, 6.5);
      expect(model.sellingRate, 12.0);
      expect(model.reorderLevel, 10.0);
      expect(model.trackInventory, true);

      final backToMap = model.toMap();
      expect(backToMap['material_code'], 'RM01');
      expect(backToMap['purchase_rate'], 6.5);
    });

    test('VendorModel mapping', () {
      final now = DateTime.now();
      final map = {
        'vendor_code': 'V01',
        'vendor_name': 'Sysco',
        'contact_person': 'John',
        'phone': '123',
        'email': 'sysco@example.com',
        'credit_days': 15,
        'opening_balance': 200.0,
        'balance_type': 'credit',
        'is_active': true,
        'created_at': now.toIso8601String(),
      };

      final model = VendorModel.fromMap(map);
      expect(model.vendorCode, 'V01');
      expect(model.vendorName, 'Sysco');
      expect(model.contactPerson, 'John');
      expect(model.phone, '123');
      expect(model.creditDays, 15);
      expect(model.openingBalance, 200.0);

      final backToMap = model.toMap();
      expect(backToMap['vendor_code'], 'V01');
      expect(backToMap['opening_balance'], 200.0);
    });

    test('BillTypeModel mapping', () {
      final now = DateTime.now();
      final map = {
        'bill_type_name': 'Cash',
        'remark': 'Paid instantly in cash',
        'is_active': true,
        'created_at': now.toIso8601String(),
      };

      final model = BillTypeModel.fromMap(map);
      expect(model.billTypeName, 'Cash');
      expect(model.remark, 'Paid instantly in cash');

      final backToMap = model.toMap();
      expect(backToMap['bill_type_name'], 'Cash');
    });

    test('StockReasonModel mapping', () {
      final map = {
        'reason_name': 'Expired',
        'reason_type': 'expiry',
        'is_active': true,
      };

      final model = StockReasonModel.fromMap(map);
      expect(model.reasonName, 'Expired');
      expect(model.reasonType, 'expiry');

      final backToMap = model.toMap();
      expect(backToMap['reason_name'], 'Expired');
    });
  });
}
