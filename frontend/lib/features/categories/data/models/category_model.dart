class CategoryModel {
  final int id;
  final String name;
  final String? nameEn;
  final String description;

  const CategoryModel({
    required this.id,
    required this.name,
    this.nameEn,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as int,
        name: json['name'] as String,
        nameEn: json['name_en'] as String?,
        description: (json['description'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_en': nameEn,
        'description': description,
      };

  String get displayName => nameEn != null && nameEn!.isNotEmpty ? '$name ($nameEn)' : name;
}
