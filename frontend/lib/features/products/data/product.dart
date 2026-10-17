class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.description,
  });

  final int id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? description;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        category: json['category'] as String,
        price: (json['price'] as num).toDouble(),
        stock: (json['stock'] as num).toInt(),
        description: json['description'] as String?,
      );
}
