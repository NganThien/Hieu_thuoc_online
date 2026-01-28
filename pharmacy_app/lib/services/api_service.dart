import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000/api";

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        // 1. Giải mã cục JSON to đùng
        Map<String, dynamic> data = jsonDecode(response.body);

        // 2. Lấy cái danh sách bên trong chìa khóa "products"
        List<dynamic> productsJson = data['products'];

        // 3. Biến đổi thành danh sách Product của App
        return productsJson.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}
