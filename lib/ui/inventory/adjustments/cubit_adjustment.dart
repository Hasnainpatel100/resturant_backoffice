import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/inventory/stock_adjustment_repository.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository.dart';
import 'package:back_office/data/repositories/inventory/item_repository.dart';
import 'state_adjustment.dart';

class CubitAdjustment extends Cubit<StateAdjustment> {
  final StockAdjustmentRepository _adjustmentRepository;
  final WarehouseRepository _warehouseRepository;
  final ItemRepository _itemRepository;

  CubitAdjustment({
    required StockAdjustmentRepository adjustmentRepository,
    required WarehouseRepository warehouseRepository,
    required ItemRepository itemRepository,
  })  : _adjustmentRepository = adjustmentRepository,
        _warehouseRepository = warehouseRepository,
        _itemRepository = itemRepository,
        super(const StateAdjustment());

  Future<void> loadAdjustments(String brandId) async {
    emit(state.copyWith(status: AdjustmentStatus.loading));
    final result = await _adjustmentRepository.getAdjustments(brandId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdjustmentStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: AdjustmentStatus.loaded,
        adjustments: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> loadFormDropdowns(String brandId) async {
    emit(state.copyWith(status: AdjustmentStatus.loading));
    final whResult = await _warehouseRepository.getWarehouses(brandId);
    final itemResult = await _itemRepository.getItems(brandId, limit: 100);

    whResult.fold(
      (failure) => emit(state.copyWith(
        status: AdjustmentStatus.error,
        errorMessage: failure.message,
      )),
      (whResponse) {
        itemResult.fold(
          (failure) => emit(state.copyWith(
            status: AdjustmentStatus.error,
            errorMessage: failure.message,
          )),
          (itemResponse) {
            emit(state.copyWith(
              status: AdjustmentStatus.loaded,
              warehouses: whResponse.items,
              items: itemResponse.items,
            ));
          },
        );
      },
    );
  }

  Future<void> createAdjustment(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: AdjustmentStatus.loading));
    final result = await _adjustmentRepository.createAdjustment(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdjustmentStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AdjustmentStatus.success)),
    );
  }
}
