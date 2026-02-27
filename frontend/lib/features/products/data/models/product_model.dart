class ProductModel {
  final int id;
  final String productCode;
  final String name;
  final String? nameEn;
  final String description;
  final double price;
  final int categoryId;
  final String? imageUrl;
  final String categoryName;
  final String? categoryNameEn;

  const ProductModel({
    required this.id,
    required this.productCode,
    required this.name,
    this.nameEn,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    required this.categoryName,
    this.categoryNameEn,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as int,
        productCode: json['product_code'] as String,
        name: json['name'] as String,
        nameEn: json['name_en'] as String?,
        description: (json['description'] ?? '') as String,
        price: (json['price'] as num).toDouble(),
        categoryId: json['category_id'] as int,
        imageUrl: json['image_url'] as String?,
        categoryName: (json['category_name'] ?? 'Uncategorized') as String,
        categoryNameEn: json['category_name_en'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_code': productCode,
        'name': name,
        'name_en': nameEn,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'image_url': imageUrl,
        'category_name': categoryName,
        'category_name_en': categoryNameEn,
      };
}
