import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart'; // Import cái giỏ hàng
import '../configs.dart'; // Để lấy địa chỉ IP Server

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Hàm định dạng tiền
  String formatCurrency(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
  }

  // Hàm cập nhật lại giao diện khi xóa/sửa
  void _updateCart() {
    setState(
      () {},
    ); // Lệnh này bắt Flutter vẽ lại màn hình để cập nhật tổng tiền
  }

  // --- HÀM XỬ LÝ ĐẶT HÀNG (MỚI THÊM) ---
  Future<void> _placeOrder() async {
    // 1. Kiểm tra giỏ hàng
    if (Cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Giỏ hàng đang trống!")));
      return;
    }

    // 2. Lấy thông tin User đang đăng nhập
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user_data');

    if (userString == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn cần đăng nhập để đặt hàng!")),
      );
      return;
    }

    final user = jsonDecode(userString);
    final userId = user['id']; // Lấy ID của người dùng
    final address = user['address']; // Lấy địa chỉ

    try {
      // 3. Chuẩn bị dữ liệu để gửi đi (Đóng gói)
      final orderData = {
        'user_id': userId,
        'total_amount': Cart.getTotalPrice(),
        'address': address,
        'items': Cart.items
            .map(
              (item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
              },
            )
            .toList(),
      };

      // 4. Gửi lên Server
      final response = await http.post(
        Uri.parse('${Configs.baseUrl}/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      // 5. Xử lý kết quả
      if (response.statusCode == 201) {
        // Thành công -> Xóa giỏ hàng -> Báo tin vui
        setState(() {
          Cart.items.clear();
        });

        if (!mounted) return;

        // Hiện hộp thoại thông báo đẹp
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Thành công!"),
            content: const Text("Đơn hàng của bạn đã được gửi đến dược sĩ."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Lỗi server: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đặt hàng thất bại: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text("Giỏ hàng của bạn"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Cart.items.isEmpty
          ? const Center(child: Text("Giỏ hàng đang trống!"))
          : Column(
              children: [
                // 1. DANH SÁCH HÀNG
                Expanded(
                  child: ListView.builder(
                    itemCount: Cart.items.length,
                    padding: const EdgeInsets.all(15),
                    itemBuilder: (context, index) {
                      final item = Cart.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              // Ảnh nhỏ
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.network(
                                  item.product.imageUrl.isNotEmpty
                                      ? item.product.imageUrl
                                      : "https://cdn-icons-png.flaticon.com/512/883/883407.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Thông tin
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      formatCurrency(item.product.price),
                                      style: const TextStyle(
                                        color: Color(0xFF009688),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Số lượng: ${item.quantity}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Nút Xóa
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  Cart.removeFromCart(index); // Xóa khỏi bộ nhớ
                                  _updateCart(); // Vẽ lại màn hình
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. PHẦN TỔNG TIỀN VÀ THANH TOÁN
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng cộng:",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            formatCurrency(Cart.getTotalPrice()),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          // --- GỌI HÀM ĐẶT HÀNG Ở ĐÂY ---
                          onPressed: _placeOrder,
                          // -------------------------------
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009688),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "TIẾN HÀNH ĐẶT HÀNG",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
