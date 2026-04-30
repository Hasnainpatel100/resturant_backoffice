import 'package:equatable/equatable.dart';

class MetaData extends Equatable {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const MetaData({
    this.page = 1,
    this.pageSize = 20,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'pageSize': pageSize,
        'totalItems': totalItems,
        'totalPages': totalPages,
      };

  bool get hasNextPage => page < totalPages;
  bool get hasPrevPage => page > 1;

  @override
  List<Object?> get props => [page, pageSize, totalItems, totalPages];
}

class ApiResponse<T> extends Equatable {
  final T? data;
  final String? message;
  final MetaData? meta;

  const ApiResponse({
    this.data,
    this.message,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      data: fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T?,
      message: json['message'] as String?,
      meta: json['meta'] != null ? MetaData.fromJson(json['meta']) : null,
    );
  }

  @override
  List<Object?> get props => [data, message, meta];
}

class ApiErrorData extends Equatable {
  final String code;
  final String message;

  const ApiErrorData({
    required this.code,
    required this.message,
  });

  factory ApiErrorData.fromJson(Map<String, dynamic> json) {
    return ApiErrorData(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'An error occurred',
    );
  }

  @override
  List<Object?> get props => [code, message];
}

class ListResponse<T> extends Equatable {
  final List<T> items;
  final MetaData meta;

  const ListResponse({
    required this.items,
    this.meta = const MetaData(),
  });

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataWrapper = json['data'];
    List<dynamic> dataList;
    int page = 1;
    int pageSize = 20;
    int totalItems = 0;
    int totalPages = 1;

    if (dataWrapper is Map<String, dynamic>) {
      dataList = dataWrapper['data'] as List<dynamic>? ?? [];
      page = dataWrapper['page'] as int? ?? 1;
      pageSize = dataWrapper['limit'] as int? ?? 20;
      totalItems = dataWrapper['total'] as int? ?? 0;
      totalPages = dataWrapper['totalPages'] as int? ?? 1;
    } else {
      dataList = dataWrapper as List<dynamic>? ?? [];
    }

    return ListResponse(
      items: dataList.map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      meta: MetaData(
        page: page,
        pageSize: pageSize,
        totalItems: totalItems,
        totalPages: totalPages,
      ),
    );
  }

  /// Create ListResponse from a pre-parsed list (for batch responses)
  factory ListResponse.fromJsonList(List<T> items, Map<String, dynamic> rawJson) {
    return ListResponse(
      items: items,
      meta: rawJson['meta'] != null ? MetaData.fromJson(rawJson['meta']) : const MetaData(),
    );
  }

  @override
  List<Object?> get props => [items, meta];
}
