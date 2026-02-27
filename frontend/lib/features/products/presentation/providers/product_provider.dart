import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/sources/product_remote_source.dart';
import '../../domain/usecases/product_usecases.dart';


class ProductProvider with ChangeNotifier {
  late final GetProductsUseCase _getProducts;
  late final DeleteProductUseCase _deleteProduct;
  late final UpdateProductUseCase _updateProduct;

  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _requestCount = 0;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  ProductProvider() {
    final repo = ProductRepositoryImpl(ProductRemoteSource());
    _getProducts = GetProductsUseCase(repo);
    _deleteProduct = DeleteProductUseCase(repo);
    _updateProduct = UpdateProductUseCase(repo);
  }

  Future<void> fetchProducts({
    bool refresh = false,
    String? search,
    String? sortBy,
    int? categoryId,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
      _isLoading = false; // Reset loading to allow new refresh search
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error = null;
    final int requestToken = ++_requestCount;
    notifyListeners();

    try {
      final response = await _getProducts(
        page: _currentPage,
        search: search,
        sortBy: sortBy,
        categoryId: categoryId,
      );

      if (requestToken != _requestCount) return;

      _products.addAll(response.items);
      _hasMore = response.hasMore;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      debugPrint('ProductProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProduct({
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
    try {
      final updated = await _updateProduct(
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
      
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('updateProduct: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('deleteProduct: $e');
      return false;
    }
  }
}
