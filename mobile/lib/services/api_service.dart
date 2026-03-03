import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../configs.dart';

class ApiService {
  static String get baseUrl => Configs.baseUrl;

  /// [search] Tìm kiếm theo tên. [categoryId] Lọc theo danh mục (null = tất cả).
  static Future<List<Product>> fetchProducts({
    String? search,
    int? categoryId,
  }) async {
    try {
      final params = <String, String>{};
      if (search != null && search.trim().isNotEmpty) params['q'] = search.trim();
      if (categoryId != null) params['category_id'] = categoryId.toString();
      final uri = Uri.parse('$baseUrl/products').replace(
        queryParameters: params.isEmpty ? null : params,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> productsJson = data['products'];
        return productsJson.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Lấy danh sách tất cả danh mục.
  static Future<List<Category>> fetchCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> list = data['categories'] ?? [];
        return list.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}
