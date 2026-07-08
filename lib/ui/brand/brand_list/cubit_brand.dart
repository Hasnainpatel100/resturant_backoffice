import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/brand_repository.dart';
import 'state_brand.dart';

class CubitBrand extends Cubit<StateBrand> {
  final BrandRepository _repository;

  CubitBrand({required BrandRepository repository})
      : _repository = repository,
        super(const StateBrand());

  Future<void> loadBrand(String brandId) async {
    emit(state.copyWith(status: BrandStatus.loading));
    final result = await _repository.getBrand(brandId);
    result.fold(
      (failure) => emit(state.copyWith(status: BrandStatus.error, errorMessage: failure.message)),
      (brand) => emit(state.copyWith(status: BrandStatus.loaded, brand: brand)),
    );
  }

  Future<void> loadBrands({int page = 1, int limit = 20}) async {
    emit(state.copyWith(status: BrandStatus.loading));
    final result = await _repository.getBrands(page: page, limit: limit);
    result.fold(
      (failure) => emit(state.copyWith(status: BrandStatus.error, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        status: BrandStatus.loaded,
        brands: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> createBrand(Map<String, dynamic> data) async {
    emit(state.copyWith(status: BrandStatus.loading));
    final result = await _repository.createBrand(data);
    result.fold(
      (failure) => emit(state.copyWith(status: BrandStatus.error, errorMessage: failure.message)),
      (brand) => emit(state.copyWith(status: BrandStatus.success, brand: brand)),
    );
  }


  Future<void> updateBrand(String brandId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: BrandStatus.loading));
    final result = await _repository.updateBrand(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(status: BrandStatus.error, errorMessage: failure.message)),
      (brand) => emit(state.copyWith(status: BrandStatus.success, brand: brand)),
    );
  }

  Future<void> deleteBrand(String brandId) async {
    emit(state.copyWith(status: BrandStatus.loading));
    final result = await _repository.deleteBrand(brandId);
    result.fold(
      (failure) => emit(state.copyWith(status: BrandStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: BrandStatus.success, brand: null)),
    );
  }

  Future<void> loadPlanHistory(String brandId, {int page = 1, int limit = 20}) async {
    final result = await _repository.getPlanHistory(brandId, page: page, limit: limit);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (response) => emit(state.copyWith(planHistory: response.items)),
    );
  }
}
