import 'package:get/get.dart';
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
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

// ── 1. LOCATION CONTROLLER ───────────────────────────────────────────────────
class LocationController extends GetxController {
  final LocationRepository repository;
  LocationController({required this.repository});

  final locations = <LocationModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadLocations() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllLocations();
      locations.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createLocation(LocationModel location) async {
    isLoading.value = true;
    try {
      await repository.createLocation(location);
      await loadLocations();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateLocation(String id, LocationModel location) async {
    isLoading.value = true;
    try {
      final success = await repository.updateLocation(id, location);
      if (success) {
        await loadLocations();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteLocation(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteLocation(id);
      if (success) {
        await loadLocations();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

// ── 2. UNIT CONTROLLER ───────────────────────────────────────────────────────
class UnitController extends GetxController {
  final UnitRepository repository;
  UnitController({required this.repository});

  final units = <UnitModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadUnits() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllUnits();
      units.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createUnit(UnitModel unit) async {
    isLoading.value = true;
    try {
      await repository.createUnit(unit);
      await loadUnits();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateUnit(String id, UnitModel unit) async {
    isLoading.value = true;
    try {
      final success = await repository.updateUnit(id, unit);
      if (success) {
        await loadUnits();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteUnit(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteUnit(id);
      if (success) {
        await loadUnits();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

// ── 3. RAW MATERIAL GROUP CONTROLLER ──────────────────────────────────────────
class RawMaterialGroupController extends GetxController {
  final RawMaterialGroupRepository repository;
  RawMaterialGroupController({required this.repository});

  final groups = <RawMaterialGroupModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadGroups() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllGroups();
      groups.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createGroup(RawMaterialGroupModel group) async {
    isLoading.value = true;
    try {
      await repository.createGroup(group);
      await loadGroups();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateGroup(String id, RawMaterialGroupModel group) async {
    isLoading.value = true;
    try {
      final success = await repository.updateGroup(id, group);
      if (success) {
        await loadGroups();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteGroup(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteGroup(id);
      if (success) {
        await loadGroups();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

// ── 4. RAW MATERIAL TAX CONTROLLER ───────────────────────────────────────────
class RawMaterialTaxController extends GetxController {
  final RawMaterialTaxRepository repository;
  RawMaterialTaxController({required this.repository});

  final taxes = <RawMaterialTaxModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadTaxes() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllTaxes();
      taxes.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTax(RawMaterialTaxModel tax) async {
    isLoading.value = true;
    try {
      await repository.createTax(tax);
      await loadTaxes();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTax(String id, RawMaterialTaxModel tax) async {
    isLoading.value = true;
    try {
      final success = await repository.updateTax(id, tax);
      if (success) {
        await loadTaxes();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTax(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteTax(id);
      if (success) {
        await loadTaxes();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

// ── 5. RAW MATERIAL CONTROLLER ────────────────────────────────────────────────
class RawMaterialController extends GetxController {
  final RawMaterialRepository repository;
  RawMaterialController({required this.repository});

  final materials = <RawMaterialModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadMaterials() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllMaterials();
      materials.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createMaterial(RawMaterialModel material) async {
    isLoading.value = true;
    try {
      await repository.createMaterial(material);
      await loadMaterials();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMaterial(String id, RawMaterialModel material) async {
    isLoading.value = true;
    try {
      final success = await repository.updateMaterial(id, material);
      if (success) {
        await loadMaterials();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteMaterial(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteMaterial(id);
      if (success) {
        await loadMaterials();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

// ── 6. VENDOR CONTROLLER ─────────────────────────────────────────────────────
class VendorController extends GetxController {
  final VendorRepository repository;
  VendorController({required this.repository});

  final vendors = <VendorModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadVendors() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllVendors();
      vendors.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createVendor(VendorModel vendor) async {
    isLoading.value = true;
    try {
      await repository.createVendor(vendor);
      await loadVendors();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateVendor(String id, VendorModel vendor) async {
    isLoading.value = true;
    try {
      final success = await repository.updateVendor(id, vendor);
      if (success) {
        await loadVendors();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteVendor(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteVendor(id);
      if (success) {
        await loadVendors();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

// ── 7. BILL TYPE CONTROLLER ──────────────────────────────────────────────────
class BillTypeController extends GetxController {
  final BillTypeRepository repository;
  BillTypeController({required this.repository});

  final billTypes = <BillTypeModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadBillTypes() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllBillTypes();
      billTypes.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createBillType(BillTypeModel billType) async {
    isLoading.value = true;
    try {
      await repository.createBillType(billType);
      await loadBillTypes();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateBillType(String id, BillTypeModel billType) async {
    isLoading.value = true;
    try {
      final success = await repository.updateBillType(id, billType);
      if (success) {
        await loadBillTypes();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteBillType(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteBillType(id);
      if (success) {
        await loadBillTypes();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

// ── 8. STOCK REASON CONTROLLER ───────────────────────────────────────────────
class StockReasonController extends GetxController {
  final StockReasonRepository repository;
  StockReasonController({required this.repository});

  final reasons = <StockReasonModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadReasons() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllStockReasons();
      reasons.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createReason(StockReasonModel reason) async {
    isLoading.value = true;
    try {
      await repository.createStockReason(reason);
      await loadReasons();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateReason(String id, StockReasonModel reason) async {
    isLoading.value = true;
    try {
      final success = await repository.updateStockReason(id, reason);
      if (success) {
        await loadReasons();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteReason(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteStockReason(id);
      if (success) {
        await loadReasons();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

// ── 9. MONGO BRANCH CONTROLLER ───────────────────────────────────────────────
class MongoBranchController extends GetxController {
  final MongoBranchRepository repository;
  MongoBranchController({required this.repository});

  final branches = <BranchModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadBranches() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllBranches();
      branches.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

// ── 10. MONGO USER CONTROLLER ────────────────────────────────────────────────
class MongoUserController extends GetxController {
  final MongoUserRepository repository;
  MongoUserController({required this.repository});

  final users = <AppUser>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllUsers();
      users.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
