import 'package:get/get.dart';
import 'package:back_office/data/models/restaurant_inventory/indent_model.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_transfer_model.dart';
import 'package:back_office/data/repositories/restaurant_inventory/internal_movement_repositories.dart';

// ── INDENT CONTROLLER ────────────────────────────────────────────────────────
class IndentController extends GetxController {
  final IndentRepository repository;
  IndentController({required this.repository});

  final indents = <IndentModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadIndents() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllIndents();
      indents.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createIndent(IndentModel indent) async {
    isLoading.value = true;
    try {
      await repository.createIndent(indent);
      await loadIndents();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateIndent(String id, IndentModel indent) async {
    isLoading.value = true;
    try {
      final success = await repository.updateIndent(id, indent);
      if (success) {
        await loadIndents();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteIndent(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteIndent(id);
      if (success) {
        await loadIndents();
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

// ── STOCK TRANSFER CONTROLLER ────────────────────────────────────────────────
class StockTransferController extends GetxController {
  final StockTransferRepository repository;
  StockTransferController({required this.repository});

  final transfers = <StockTransferModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadTransfers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllTransfers();
      transfers.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTransfer(StockTransferModel transfer) async {
    isLoading.value = true;
    try {
      await repository.createTransfer(transfer);
      await loadTransfers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTransfer(String id, StockTransferModel transfer) async {
    isLoading.value = true;
    try {
      final success = await repository.updateTransfer(id, transfer);
      if (success) {
        await loadTransfers();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTransfer(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteTransfer(id);
      if (success) {
        await loadTransfers();
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
