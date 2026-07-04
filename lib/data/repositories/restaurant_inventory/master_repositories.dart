import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:back_office/data/models/restaurant_inventory/location_model.dart';
import 'package:back_office/data/models/restaurant_inventory/unit_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_group_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_tax_model.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_model.dart';
import 'package:back_office/data/models/restaurant_inventory/vendor_model.dart';
import 'package:back_office/data/models/restaurant_inventory/bill_type_model.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_reason_model.dart';
import 'package:back_office/data/models/branch_model.dart';
import 'package:back_office/data/models/user_model.dart';

import 'package:back_office/data/datasources/restaurant_inventory/master_datasources.dart';

// ── 1. LOCATION REPOSITORY ───────────────────────────────────────────────────
abstract class LocationRepository {
  Future<List<LocationModel>> getAllLocations();
  Future<LocationModel?> getLocationById(String id);
  Future<LocationModel> createLocation(LocationModel location);
  Future<bool> updateLocation(String id, LocationModel location);
  Future<bool> deleteLocation(String id);
}

class LocationRepositoryImpl implements LocationRepository {
  final LocationMongoDataSource _dataSource = LocationMongoDataSource();

  @override
  Future<List<LocationModel>> getAllLocations() async {
    final list = await _dataSource.getAll();
    return list.map((map) => LocationModel.fromMap(map)).toList();
  }

  @override
  Future<LocationModel?> getLocationById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return LocationModel.fromMap(map);
  }

  @override
  Future<LocationModel> createLocation(LocationModel location) async {
    final map = await _dataSource.create(location.toMap()..remove('_id'));
    return LocationModel.fromMap(map);
  }

  @override
  Future<bool> updateLocation(String id, LocationModel location) async {
    return await _dataSource.update(id, location.toMap());
  }

  @override
  Future<bool> deleteLocation(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 2. UNIT REPOSITORY ───────────────────────────────────────────────────────
abstract class UnitRepository {
  Future<List<UnitModel>> getAllUnits();
  Future<UnitModel?> getUnitById(String id);
  Future<UnitModel> createUnit(UnitModel unit);
  Future<bool> updateUnit(String id, UnitModel unit);
  Future<bool> deleteUnit(String id);
}

class UnitRepositoryImpl implements UnitRepository {
  final UnitMongoDataSource _dataSource = UnitMongoDataSource();

  @override
  Future<List<UnitModel>> getAllUnits() async {
    final list = await _dataSource.getAll();
    return list.map((map) => UnitModel.fromMap(map)).toList();
  }

  @override
  Future<UnitModel?> getUnitById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return UnitModel.fromMap(map);
  }

  @override
  Future<UnitModel> createUnit(UnitModel unit) async {
    final map = await _dataSource.create(unit.toMap()..remove('_id'));
    return UnitModel.fromMap(map);
  }

  @override
  Future<bool> updateUnit(String id, UnitModel unit) async {
    return await _dataSource.update(id, unit.toMap());
  }

  @override
  Future<bool> deleteUnit(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 3. RAW MATERIAL GROUP REPOSITORY ──────────────────────────────────────────
abstract class RawMaterialGroupRepository {
  Future<List<RawMaterialGroupModel>> getAllGroups();
  Future<RawMaterialGroupModel?> getGroupById(String id);
  Future<RawMaterialGroupModel> createGroup(RawMaterialGroupModel group);
  Future<bool> updateGroup(String id, RawMaterialGroupModel group);
  Future<bool> deleteGroup(String id);
}

class RawMaterialGroupRepositoryImpl implements RawMaterialGroupRepository {
  final RawMaterialGroupMongoDataSource _dataSource = RawMaterialGroupMongoDataSource();

  @override
  Future<List<RawMaterialGroupModel>> getAllGroups() async {
    final list = await _dataSource.getAll();
    return list.map((map) => RawMaterialGroupModel.fromMap(map)).toList();
  }

  @override
  Future<RawMaterialGroupModel?> getGroupById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return RawMaterialGroupModel.fromMap(map);
  }

  @override
  Future<RawMaterialGroupModel> createGroup(RawMaterialGroupModel group) async {
    final map = await _dataSource.create(group.toMap()..remove('_id'));
    return RawMaterialGroupModel.fromMap(map);
  }

  @override
  Future<bool> updateGroup(String id, RawMaterialGroupModel group) async {
    return await _dataSource.update(id, group.toMap());
  }

  @override
  Future<bool> deleteGroup(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 4. RAW MATERIAL TAX REPOSITORY ───────────────────────────────────────────
abstract class RawMaterialTaxRepository {
  Future<List<RawMaterialTaxModel>> getAllTaxes();
  Future<RawMaterialTaxModel?> getTaxById(String id);
  Future<RawMaterialTaxModel> createTax(RawMaterialTaxModel tax);
  Future<bool> updateTax(String id, RawMaterialTaxModel tax);
  Future<bool> deleteTax(String id);
}

class RawMaterialTaxRepositoryImpl implements RawMaterialTaxRepository {
  final RawMaterialTaxMongoDataSource _dataSource = RawMaterialTaxMongoDataSource();

  @override
  Future<List<RawMaterialTaxModel>> getAllTaxes() async {
    final list = await _dataSource.getAll();
    return list.map((map) => RawMaterialTaxModel.fromMap(map)).toList();
  }

  @override
  Future<RawMaterialTaxModel?> getTaxById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return RawMaterialTaxModel.fromMap(map);
  }

  @override
  Future<RawMaterialTaxModel> createTax(RawMaterialTaxModel tax) async {
    final map = await _dataSource.create(tax.toMap()..remove('_id'));
    return RawMaterialTaxModel.fromMap(map);
  }

  @override
  Future<bool> updateTax(String id, RawMaterialTaxModel tax) async {
    return await _dataSource.update(id, tax.toMap());
  }

  @override
  Future<bool> deleteTax(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 5. RAW MATERIAL REPOSITORY ────────────────────────────────────────────────
abstract class RawMaterialRepository {
  Future<List<RawMaterialModel>> getAllMaterials();
  Future<RawMaterialModel?> getMaterialById(String id);
  Future<RawMaterialModel> createMaterial(RawMaterialModel material);
  Future<bool> updateMaterial(String id, RawMaterialModel material);
  Future<bool> deleteMaterial(String id);
}

class RawMaterialRepositoryImpl implements RawMaterialRepository {
  final RawMaterialMongoDataSource _dataSource = RawMaterialMongoDataSource();

  @override
  Future<List<RawMaterialModel>> getAllMaterials() async {
    final list = await _dataSource.getAll();
    return list.map((map) => RawMaterialModel.fromMap(map)).toList();
  }

  @override
  Future<RawMaterialModel?> getMaterialById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return RawMaterialModel.fromMap(map);
  }

  @override
  Future<RawMaterialModel> createMaterial(RawMaterialModel material) async {
    final map = await _dataSource.create(material.toMap()..remove('_id'));
    return RawMaterialModel.fromMap(map);
  }

  @override
  Future<bool> updateMaterial(String id, RawMaterialModel material) async {
    return await _dataSource.update(id, material.toMap());
  }

  @override
  Future<bool> deleteMaterial(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 6. VENDOR REPOSITORY ─────────────────────────────────────────────────────
abstract class VendorRepository {
  Future<List<VendorModel>> getAllVendors();
  Future<VendorModel?> getVendorById(String id);
  Future<VendorModel> createVendor(VendorModel vendor);
  Future<bool> updateVendor(String id, VendorModel vendor);
  Future<bool> deleteVendor(String id);
}

class VendorRepositoryImpl implements VendorRepository {
  final VendorMongoDataSource _dataSource = VendorMongoDataSource();

  @override
  Future<List<VendorModel>> getAllVendors() async {
    final list = await _dataSource.getAll();
    return list.map((map) => VendorModel.fromMap(map)).toList();
  }

  @override
  Future<VendorModel?> getVendorById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return VendorModel.fromMap(map);
  }

  @override
  Future<VendorModel> createVendor(VendorModel vendor) async {
    final map = await _dataSource.create(vendor.toMap()..remove('_id'));
    return VendorModel.fromMap(map);
  }

  @override
  Future<bool> updateVendor(String id, VendorModel vendor) async {
    return await _dataSource.update(id, vendor.toMap());
  }

  @override
  Future<bool> deleteVendor(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 7. BILL TYPE REPOSITORY ──────────────────────────────────────────────────
abstract class BillTypeRepository {
  Future<List<BillTypeModel>> getAllBillTypes();
  Future<BillTypeModel?> getBillTypeById(String id);
  Future<BillTypeModel> createBillType(BillTypeModel billType);
  Future<bool> updateBillType(String id, BillTypeModel billType);
  Future<bool> deleteBillType(String id);
}

class BillTypeRepositoryImpl implements BillTypeRepository {
  final BillTypeMongoDataSource _dataSource = BillTypeMongoDataSource();

  @override
  Future<List<BillTypeModel>> getAllBillTypes() async {
    final list = await _dataSource.getAll();
    return list.map((map) => BillTypeModel.fromMap(map)).toList();
  }

  @override
  Future<BillTypeModel?> getBillTypeById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return BillTypeModel.fromMap(map);
  }

  @override
  Future<BillTypeModel> createBillType(BillTypeModel billType) async {
    final map = await _dataSource.create(billType.toMap()..remove('_id'));
    return BillTypeModel.fromMap(map);
  }

  @override
  Future<bool> updateBillType(String id, BillTypeModel billType) async {
    return await _dataSource.update(id, billType.toMap());
  }

  @override
  Future<bool> deleteBillType(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 8. STOCK REASON REPOSITORY ───────────────────────────────────────────────
abstract class StockReasonRepository {
  Future<List<StockReasonModel>> getAllStockReasons();
  Future<StockReasonModel?> getStockReasonById(String id);
  Future<StockReasonModel> createStockReason(StockReasonModel stockReason);
  Future<bool> updateStockReason(String id, StockReasonModel stockReason);
  Future<bool> deleteStockReason(String id);
}

class StockReasonRepositoryImpl implements StockReasonRepository {
  final StockReasonMongoDataSource _dataSource = StockReasonMongoDataSource();

  @override
  Future<List<StockReasonModel>> getAllStockReasons() async {
    final list = await _dataSource.getAll();
    return list.map((map) => StockReasonModel.fromMap(map)).toList();
  }

  @override
  Future<StockReasonModel?> getStockReasonById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return StockReasonModel.fromMap(map);
  }

  @override
  Future<StockReasonModel> createStockReason(StockReasonModel stockReason) async {
    final map = await _dataSource.create(stockReason.toMap()..remove('_id'));
    return StockReasonModel.fromMap(map);
  }

  @override
  Future<bool> updateStockReason(String id, StockReasonModel stockReason) async {
    return await _dataSource.update(id, stockReason.toMap());
  }

  @override
  Future<bool> deleteStockReason(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 9. MONGO BRANCH REPOSITORY ───────────────────────────────────────────────
abstract class MongoBranchRepository {
  Future<List<BranchModel>> getAllBranches();
  Future<BranchModel?> getBranchById(String id);
}

class MongoBranchRepositoryImpl implements MongoBranchRepository {
  final BranchMongoDataSource _dataSource = BranchMongoDataSource();

  @override
  Future<List<BranchModel>> getAllBranches() async {
    final list = await _dataSource.getAll();
    return list.map((map) => BranchModel.fromJson(map)).toList();
  }

  @override
  Future<BranchModel?> getBranchById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return BranchModel.fromJson(map);
  }
}

// ── 10. MONGO USER REPOSITORY ────────────────────────────────────────────────
abstract class MongoUserRepository {
  Future<List<AppUser>> getAllUsers();
  Future<AppUser?> getUserById(String id);
}

class MongoUserRepositoryImpl implements MongoUserRepository {
  final UserMongoDataSource _dataSource = UserMongoDataSource();

  @override
  Future<List<AppUser>> getAllUsers() async {
    final list = await _dataSource.getAll();
    return list.map((map) {
      final id = map['_id'] is ObjectId ? (map['_id'] as ObjectId).toHexString() : map['id']?.toString() ?? '';
      return AppUser.empty().copyWith(
        id: id,
        email: map['email']?.toString() ?? '',
        name: map['name']?.toString() ?? map['fullName']?.toString() ?? map['username']?.toString(),
        brandId: map['brandId']?.toString(),
        branchId: map['branchId']?.toString(),
        role: map['role']?.toString(),
      );
    }).toList();
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    final mapId = map['_id'] is ObjectId ? (map['_id'] as ObjectId).toHexString() : map['id']?.toString() ?? '';
    return AppUser.empty().copyWith(
      id: mapId,
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? map['fullName']?.toString() ?? map['username']?.toString(),
      brandId: map['brandId']?.toString(),
      branchId: map['branchId']?.toString(),
      role: map['role']?.toString(),
    );
  }
}
