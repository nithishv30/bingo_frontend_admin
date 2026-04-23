class ProductModel {
  final int id;
  final String mainCategory;
  final String subCategory;
  final String image;

  ProductModel({
    required this.id,
    required this.mainCategory,
    required this.subCategory,
    required this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      mainCategory: json['mainCategory'] ?? '',
      subCategory: json['subCategory'] ?? '',
      image: json['image'] ?? '',
    );
  }
}