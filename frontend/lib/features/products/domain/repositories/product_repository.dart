import '../../data/models/product_model.dart';
import '../../data/models/product_paged_response.dart';

abstract class ProductRepository {
  Future<ProductPagedResponse> getAll({
    int page = 1,
    int limit = 20,
    String? search,
    String? sortBy,
    int? categoryId,
  });

  Future<ProductModel> createWithImage({
    required String productCode,
    required String name,
    String? nameEn,
    required String description,
    required double price,
    required int categoryId,
    required String imagePath,
    required String imageName,
  });

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
  });

  Future<void> delete(int id);
}
