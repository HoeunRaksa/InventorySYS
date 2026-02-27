import 'product_model.dart';

class ProductPagedResponse {
  final List<ProductModel> items;
  final int total;
  final int page;
  final int totalPages;
  final bool hasMore;

  const ProductPagedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.hasMore,
  });

  factory ProductPagedResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    final totalPages = pagination['total_pages'] as int;
    final currentPage = pagination['page'] as int;

    return ProductPagedResponse(
      items: (json['data'] as List).map((e) => ProductModel.fromJson(e)).toList(),
      total: pagination['total'] as int,
      page: currentPage,
      totalPages: totalPages,
      hasMore: currentPage < totalPages,
    );
  }
}
