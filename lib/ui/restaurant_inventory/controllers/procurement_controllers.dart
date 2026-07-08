import 'package:get/get.dart';
import 'package:back_office/data/models/restaurant_inventory/purchase_order_model.dart';
import 'package:back_office/data/models/restaurant_inventory/goods_receipt_model.dart';
import 'package:back_office/data/models/restaurant_inventory/supplier_invoice_model.dart';
import 'package:back_office/data/repositories/restaurant_inventory/procurement_repositories.dart';

// ── 1. PURCHASE ORDER CONTROLLER ─────────────────────────────────────────────
class PurchaseOrderController extends GetxController {
  final PurchaseOrderRepository repository;
  PurchaseOrderController({required this.repository});

  final pos = <PurchaseOrderModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadPOs() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllPOs();
      pos.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createPO(PurchaseOrderModel po) async {
    isLoading.value = true;
    try {
      await repository.createPO(po);
      await loadPOs();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePO(String id, PurchaseOrderModel po) async {
    isLoading.value = true;
    try {
      final success = await repository.updatePO(id, po);
      if (success) {
        await loadPOs();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deletePO(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deletePO(id);
      if (success) {
        await loadPOs();
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

// ── 2. GOODS RECEIPT CONTROLLER ──────────────────────────────────────────────
class GoodsReceiptController extends GetxController {
  final GoodsReceiptRepository repository;
  GoodsReceiptController({required this.repository});

  final grns = <GoodsReceiptModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadGRNs() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllGRNs();
      grns.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createGRN(GoodsReceiptModel grn) async {
    isLoading.value = true;
    try {
      await repository.createGRN(grn);
      await loadGRNs();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateGRN(String id, GoodsReceiptModel grn) async {
    isLoading.value = true;
    try {
      final success = await repository.updateGRN(id, grn);
      if (success) {
        await loadGRNs();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteGRN(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteGRN(id);
      if (success) {
        await loadGRNs();
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

// ── 3. SUPPLIER INVOICE CONTROLLER ───────────────────────────────────────────
class SupplierInvoiceController extends GetxController {
  final SupplierInvoiceRepository repository;
  SupplierInvoiceController({required this.repository});

  final invoices = <SupplierInvoiceModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadInvoices() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await repository.getAllInvoices();
      invoices.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createInvoice(SupplierInvoiceModel invoice) async {
    isLoading.value = true;
    try {
      await repository.createInvoice(invoice);
      await loadInvoices();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateInvoice(String id, SupplierInvoiceModel invoice) async {
    isLoading.value = true;
    try {
      final success = await repository.updateInvoice(id, invoice);
      if (success) {
        await loadInvoices();
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteInvoice(String id) async {
    isLoading.value = true;
    try {
      final success = await repository.deleteInvoice(id);
      if (success) {
        await loadInvoices();
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
