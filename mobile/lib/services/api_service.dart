import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
        // 🟢 ĐÃ SỬA: Parse thẳng thành List thay vì Map
        List<dynamic> productsJson = jsonDecode(response.body);
        
        try {
          return productsJson.map((item) {
            try {
              return Product.fromJson(item);
            } catch (e, stackTrace) {
              print('API PARSE ERROR: Failed to parse product item: $item');
              print('Error: $e');
              print(stackTrace);
              rethrow;
            }
          }).toList();
        } catch (e, stackTrace) {
          print('API PARSE ERROR: $e');
          print(stackTrace);
          rethrow;
        }
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('API FETCH ERROR: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Lấy danh sách tất cả danh mục.
  static Future<List<Category>> fetchCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        List<dynamic> list = [];
        
        // 🟢 Tương tự: Đề phòng Backend categories cũng trả thẳng về List
        if (decodedData is List) {
          list = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('categories')) {
          list = decodedData['categories'];
        }
        
        return list.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// xử lý lỗi khi token hết hạn
  static Future<http.Response> getAuthorized(String url) async {
    final headers = await _getAuthHeaders(); 
    final response = await http.get(Uri.parse(url), headers: headers);
    
    if (response.statusCode == 401) {
      // TỰ ĐỘNG ĐĂNG XUẤT NẾU TOKEN HẾT HẠN
      // _handleUnauthorized(); 
    }
    return response;
  }
}