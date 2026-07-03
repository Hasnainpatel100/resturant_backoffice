import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/inventory/stock_transfer_repository.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository.dart';
import 'package:back_office/data/repositories/inventory/item_repository.dart';
import 'state_transfer.dart';

class CubitTransfer extends Cubit<StateTransfer> {
  final StockTransferRepository _transferRepository;
  final WarehouseRepository _warehouseRepository;
  final ItemRepository _itemRepository;

  CubitTransfer({
    required StockTransferRepository transferRepository,
    required WarehouseRepository warehouseRepository,
    required ItemRepository itemRepository,
  })  : _transferRepository = transferRepository,
        _warehouseRepository = warehouseRepository,
        _itemRepository = itemRepository,
        super(const StateTransfer());

  Future<void> loadTransfers(String brandId) async {
    emit(state.copyWith(status: TransferStatus.loading));
    final result = await _transferRepository.getTransfers(brandId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: TransferStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: TransferStatus.loaded,
        transfers: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> loadFormDropdowns(String brandId) async {
    emit(state.copyWith(status: TransferStatus.loading));
    final whResult = await _warehouseRepository.getWarehouses(brandId);
    final itemResult = await _itemRepository.getItems(brandId, limit: 100);

    whResult.fold(
      (failure) => emit(state.copyWith(
        status: TransferStatus.error,
        errorMessage: failure.message,
      )),
      (whResponse) {
        itemResult.fold(
          (failure) => emit(state.copyWith(
            status: TransferStatus.error,
            errorMessage: failure.message,
          )),
          (itemResponse) {
            emit(state.copyWith(
              status: TransferStatus.loaded,
              warehouses: whResponse.items,
              items: itemResponse.items,
            ));
          },
        );
      },
    );
  }

  Future<void> createTransfer(String brandId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: TransferStatus.loading));
    final result = await _transferRepository.createTransfer(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: TransferStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: TransferStatus.success)),
    );
  }
}
