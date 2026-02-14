class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Không tên',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      // Trong JSON không có mô tả thì để trống
      description: json['description'] ?? 'Không có mô tả',
      // Sửa 'image_url' thành 'image' cho khớp với server của bạn
      imageUrl: json['image_url'] ?? json['image'] ?? '',
    );
  }
}
