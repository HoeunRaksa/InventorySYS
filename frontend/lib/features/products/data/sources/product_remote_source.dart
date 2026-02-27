import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/product_paged_response.dart';

class ProductRemoteSource {
  Future<ProductPagedResponse> getAll({
    int page = 1,
    int limit = 20,
    String? search,
    String? sortBy,
    int? categoryId,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.trim().isNotEmpty) params['search'] = search;
    if (sortBy != null) params['sort_by'] = sortBy;
    if (categoryId != null) params['category_id'] = categoryId.toString();

    final data = await ApiClient.get(ApiEndpoints.products, params: params);
    return ProductPagedResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<ProductModel> createWithImage({
    required String productCode,
    required String name,
    String? nameEn,
    required String description,
    required double price,
    required int categoryId,
    required String imagePath,
    required String imageName,
  }) async {
    final res = await ApiClient.multipart(
      ApiEndpoints.products,
      fields: {
        'product_code': productCode,
        'name': name,
        'name_en': nameEn ?? '',
        'description': description,
        'price': price.toString(),
        'category_id': categoryId.toString(),
      },
      file: await http.MultipartFile.fromPath('image', imagePath, filename: imageName),
    );

    final responseBody = await res.stream.bytesToString();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ProductModel.fromJson(jsonDecode(responseBody));
    }
    throw Exception('Failed to create product: $responseBody');
  }

  Future<ProductModel> update({
    required int id,
    required String productCode,
    required String name,
    String? nameEn,
    required String description,
    required double price,
    required int categoryId,
    String? imagePath,
    String? imageName,
    String? existingImageUrl,
  }) async {
    final res = await ApiClient.multipart(
      ApiEndpoints.product(id),
      method: 'PUT',
      fields: {
        'product_code': productCode,
        'name': name,
        'name_en': nameEn ?? '',
        'description': description,
        'price': price.toString(),
        'category_id': categoryId.toString(),
        'image_url': existingImageUrl ?? '',
      },
      file: (imagePath != null && imageName != null)
          ? await http.MultipartFile.fromPath('image', imagePath, filename: imageName)
          : null,
    );

    final responseBody = await res.stream.bytesToString();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ProductModel.fromJson(jsonDecode(responseBody));
    }
    throw Exception('Failed to update product: $responseBody');
  }

  Future<void> delete(int id) => ApiClient.delete(ApiEndpoints.product(id));
}
