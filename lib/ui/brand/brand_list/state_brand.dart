import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/brand_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum BrandStatus { initial, loading, loaded, error }

class StateBrand extends Equatable {
  final BrandStatus status;
  final BrandModel? brand;
  final List<BrandBasicModel> brands;
  final MetaData? meta;
  final List<Map<String, dynamic>> planHistory;
  final String? errorMessage;

  const StateBrand({
    this.status = BrandStatus.initial,
    this.brand,
    this.brands = const [],
    this.meta,
    this.planHistory = const [],
    this.errorMessage,
  });

  StateBrand copyWith({
    BrandStatus? status,
    BrandModel? brand,
    List<BrandBasicModel>? brands,
    MetaData? meta,
    List<Map<String, dynamic>>? planHistory,
    String? errorMessage,
  }) {
    return StateBrand(
      status: status ?? this.status,
      brand: brand ?? this.brand,
      brands: brands ?? this.brands,
      meta: meta ?? this.meta,
      planHistory: planHistory ?? this.planHistory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, brand, brands, meta, planHistory, errorMessage];
}