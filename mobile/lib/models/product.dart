class Product {
  final String id;
  final String name;
  final int price;
  final String category;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Không tên',
      price: json['price'] is int
          ? json['price'] as int
          : int.tryParse(json['price'].toString()) ?? 0,
      category: json['category'] ?? 'Khác',
      description: json['description'] ?? 'Không có mô tả',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
