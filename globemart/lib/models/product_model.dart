class ProductModel {
  final int id;
  final String title;
  final String description;
  final int price;
  final String thumbnail;
  final String category;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final num rawPrice = json['price'];
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: rawPrice.toInt(),
      thumbnail: json['thumbnail'] as String,
      category: json['category'] as String,
    );
  }
}
