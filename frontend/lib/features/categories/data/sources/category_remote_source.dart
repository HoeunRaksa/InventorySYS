import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import '../models/category_model.dart';

class CategoryRemoteSource {
  Future<List<CategoryModel>> getAll({String? search}) async {
    final params = <String, String>{};
    if (search != null && search.trim().isNotEmpty) params['search'] = search;
    // We removed 'lang' param in backend since we get both now
    final data = await ApiClient.get(ApiEndpoints.categories, params: params);
    return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<CategoryModel> create(String name, String? nameEn, String description) async {
    final data = await ApiClient.post(
      ApiEndpoints.categories,
      {'name': name, 'name_en': nameEn, 'description': description},
    );
    return CategoryModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CategoryModel> update(int id, String name, String? nameEn, String description) async {
    final data = await ApiClient.put(
      ApiEndpoints.category(id),
      {'name': name, 'name_en': nameEn, 'description': description},
    );
    return CategoryModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => ApiClient.delete(ApiEndpoints.category(id));
}
