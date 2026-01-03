import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IP lấy từ máy của bạn. Đảm bảo điện thoại và máy tính chung Wifi
  static const String baseUrl = "http://172.23.143.174:5000/api";

  // 1. Lấy danh sách thuốc
  static Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['products'];
      } else {
        print("Lỗi Server: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      rethrow; // Ném lỗi ra để giao diện biết mà hiện thông báo
    }
  }

  // 2. Gửi đơn hàng (Chức năng Mua Ngay)
  static Future<bool> createOrder(
    int userId,
    double totalAmount,
    String address,
    int productId,
    int quantity,
    double price,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create_order'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userId, // Tạm thời hardcode là 1
          "total_amount": totalAmount,
          "address": address,
          "cart_items": [
            {"product_id": productId, "quantity": quantity, "price": price},
          ],
        }),
      );
      return response.statusCode == 201; // 201 là thành công
    } catch (e) {
      print("Lỗi đặt hàng: $e");
      return false;
    }
  }
}
