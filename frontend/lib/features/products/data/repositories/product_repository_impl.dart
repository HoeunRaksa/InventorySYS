import 'package:frontend/features/products/data/models/product_model.dart';
import 'package:frontend/features/products/data/models/product_paged_response.dart';
import 'package:frontend/features/products/data/sources/product_remote_source.dart';
import 'package:frontend/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteSource _source;
  ProductRepositoryImpl(this._source);

  @override
  Future<ProductPagedResponse> getAll({
    int page = 1,
    int limit = 20,
    String? search,
    String? sortBy,
    int? categoryId,
  }) => _source.getAll(page: page, limit: limit, search: search, sortBy: sortBy, categoryId: categoryId);

  @override
  Future<ProductModel> createWithImage({
    required String productCode,
    required String name,
    String? nameEn,
    required String description,
    required double price,
    required int categoryId,
    required String imagePath,
    required String imageName,
  }) => _source.createWithImage(
        productCode: productCode,
        name: name,
        nameEn: nameEn,
        description: description,
        price: price,
        categoryId: categoryId,
        imagePath: imagePath,
        imageName: imageName,
      );

  @override
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
  }) => _source.update(
        id: id,
        productCode: productCode,
        name: name,
        nameEn: nameEn,
        description: description,
        price: price,
        categoryId: categoryId,
        imagePath: imagePath,
        imageName: imageName,
        existingImageUrl: existingImageUrl,
      );

  @override
  Future<void> delete(int id) => _source.delete(id);
}
