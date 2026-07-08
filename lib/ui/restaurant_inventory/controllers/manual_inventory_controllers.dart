import 'package:get/get.dart';
import 'package:back_office/data/models/restaurant_inventory/manual_stock_entry_model.dart';
import 'package:back_office/data/models/restaurant_inventory/manual_stock_out_model.dart';
import 'package:back_office/data/repositories/restaurant_inventory/manual_inventory_repositories.dart';

// ── 1. MANUAL STOCK ENTRY CONTROLLER ─────────────────────────────────────────
class ManualStockEntryController extends GetxController {
  final ManualStockEntryRepository repository;
  ManualStockEntryController({required this.repository});

  final entries = <ManualStockEntryModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadEntries() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllEntries();
      entries.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createEntry(ManualStockEntryModel entry) async {
    isLoading.value = true;
    try {
      await repository.createEntry(entry);
      await loadEntries();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateEntry(String id, ManualStockEntryModel entry) async {
    isLoading.value = true;
    try {
      final success = await repository.updateEntry(id, entry);
      if (success) {
        await loadEntries();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteEntry(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteEntry(id);
      if (success) {
        await loadEntries();
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

// ── 2. MANUAL STOCK OUT CONTROLLER ───────────────────────────────────────────
class ManualStockOutController extends GetxController {
  final ManualStockOutRepository repository;
  ManualStockOutController({required this.repository});

  final outs = <ManualStockOutModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadOuts() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllOuts();
      outs.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createOut(ManualStockOutModel out) async {
    isLoading.value = true;
    try {
      await repository.createOut(out);
      await loadOuts();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateOut(String id, ManualStockOutModel out) async {
    isLoading.value = true;
    try {
      final success = await repository.updateOut(id, out);
      if (success) {
        await loadOuts();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteOut(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteOut(id);
      if (success) {
        await loadOuts();
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
