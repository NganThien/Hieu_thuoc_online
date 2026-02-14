import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../configs.dart';

class ApiService {
  static String get baseUrl => Configs.baseUrl;

  /// [search] Nếu có, gọi API với query `q` để tìm kiếm theo tên sản phẩm.
  static Future<List<Product>> fetchProducts({String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/products').replace(
        queryParameters: (search != null && search.trim().isNotEmpty)
            ? {'q': search.trim()}
            : null,
      );
      final response = await http.get(uri);

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
