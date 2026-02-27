import '../../data/models/product_model.dart';
import '../../data/models/product_paged_response.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repo;
  GetProductsUseCase(this._repo);

  Future<ProductPagedResponse> call({
    int page = 1,
    int limit = 20,
    String? search,
    String? sortBy,
    int? categoryId,
  }) => _repo.getAll(page: page, limit: limit, search: search, sortBy: sortBy, categoryId: categoryId);
}

class CreateProductWithImageUseCase {
  final ProductRepository _repo;
  CreateProductWithImageUseCase(this._repo);

  Future<ProductModel> call({
    required String productCode,
    required String name,
    String? nameEn,
    required String description,
    required double price,
    required int categoryId,
    required String imagePath,
    required String imageName,
  }) => _repo.createWithImage(
        productCode: productCode,
        name: name,
        nameEn: nameEn,
        description: description,
        price: price,
        categoryId: categoryId,
        imagePath: imagePath,
        imageName: imageName,
      );
}

class UpdateProductUseCase {
  final ProductRepository _repo;
  UpdateProductUseCase(this._repo);

  Future<ProductModel> call({
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
  }) => _repo.update(
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
}

class DeleteProductUseCase {
  final ProductRepository _repo;
  DeleteProductUseCase(this._repo);

  Future<void> call(int id) => _repo.delete(id);
}
