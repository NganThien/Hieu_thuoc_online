class Product {
  final String id;
  final String name;
  final int price;
  final String description;
  final String imageUrl;
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.unit = 'Hộp', 
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse price safely - handle string/double/int formats
    int parsedPrice = 0;
    try {
      if (json['price'] is int) {
        parsedPrice = json['price'] as int;
      } else {
        final priceStr = json['price']?.toString() ?? '0';
        final priceDouble = double.tryParse(priceStr);
        if (priceDouble != null) {
          parsedPrice = priceDouble.round();
        } else {
          parsedPrice = int.tryParse(priceStr) ?? 0;
        }
      }
    } catch (e) {
      print('API PARSE ERROR: Failed to parse price: $e');
      parsedPrice = 0;
    }

    return Product(
      // Các khiên bảo vệ ?.toString() ?? '' sẽ chặn đứng mọi lỗi Null
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Sản phẩm',
      price: parsedPrice,
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      
      // 🟢 ĐÂY CHÍNH LÀ CHỖ CỨU APP CỦA BẠN KHỎI MÀN HÌNH ĐỎ:
      unit: json['unit']?.toString() ?? 'Hộp', 
    );
  }
}