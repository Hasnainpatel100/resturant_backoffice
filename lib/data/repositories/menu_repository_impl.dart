import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/menu_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/repositories/menu_repository.dart';
import 'package:back_office/utils/utils.dart';

class MenuRepositoryImpl implements MenuRepository {
  // ==================== CATEGORIES ====================

  @override
  FutureEither<ListResponse<CategoryModel>> createCategories(
    String brandId,
    List<Map<String, dynamic>> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/menu/categories',
        data: data.map((e) => {'brandId': brandId, ...e}).toList(),
      );
      final responseData = response.data!['data'] as List;
      return ListResponse<CategoryModel>.fromJsonList(
        responseData.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList(),
        response.data!,
      );
    }, requiresNetwork: true);
  }

  @override
  FutureEither<ListResponse<CategoryModel>> getCategories(
    String brandId,
    String branchId, {
    int page = 1,
    int limit = 20,
  }) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/menu/categories',
        queryParameters: {
          'brandId': brandId,
          'branchId': branchId,
          'page': page,
          'limit': limit,
        },
      );
      return ListResponse<CategoryModel>.fromJson(
        response.data!,
        (json) => CategoryModel.fromJson(json),
      );
    });
  }

  @override
  FutureEither<CategoryModel> getCategory(String categoryId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/menu/categories/$categoryId',
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return CategoryModel.fromJson(data);
    });
  }

  @override
  FutureEither<CategoryModel> updateCategory(
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>(
        '/api/menu/categories/$categoryId',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return CategoryModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteCategory(String categoryId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>('/api/menu/categories/$categoryId');
    }, requiresNetwork: true);
  }

  // ==================== MENU ITEMS ====================

  @override
  FutureEither<ListResponse<MenuItemResponse>> createMenuItems(
    String brandId,
    List<Map<String, dynamic>> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/menu/items',
        data: data.map((e) => {'brandId': brandId, ...e}).toList(),
      );
      final responseData = response.data!['data'] as List;
      return ListResponse<MenuItemResponse>.fromJsonList(
        responseData.map((e) => MenuItemResponse.fromJson(e as Map<String, dynamic>)).toList(),
        response.data!,
      );
    }, requiresNetwork: true);
  }

  @override
  FutureEither<ListResponse<MenuItemResponse>> getMenuItems(
    String brandId,
    String branchId, {
    String? categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/menu/items',
        queryParameters: {
          'brandId': brandId,
          'branchId': branchId,
          if (categoryId != null) 'categoryId': categoryId,
          'page': page,
          'limit': limit,
        },
      );
      return ListResponse<MenuItemResponse>.fromJson(
        response.data!,
        (json) => MenuItemResponse.fromJson(json),
      );
    });
  }

  @override
  FutureEither<MenuItemResponse> getMenuItem(String itemId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/menu/items/$itemId',
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return MenuItemResponse.fromJson(data);
    });
  }

  @override
  FutureEither<MenuItemResponse> updateMenuItem(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>(
        '/api/menu/items/$itemId',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return MenuItemResponse.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<MenuItemResponse> toggleAvailability(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.patch<Map<String, dynamic>>(
        '/api/menu/items/$itemId/availability',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return MenuItemResponse.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteMenuItem(String itemId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>('/api/menu/items/$itemId');
    }, requiresNetwork: true);
  }
}