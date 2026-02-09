import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Để khi đăng xuất thì quay về đây

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Khai báo các biến để hứng dữ liệu từ "Ví" ra
  String fullName = "Đang tải...";
  String phone = "";
  String address = "";

  @override
  void initState() {
    super.initState();
    // Vừa mở màn hình lên là phải thò tay vào ví lấy thẻ ra đọc ngay
    _loadUserData();
  }

  // --- HÀM 1: ĐỌC DỮ LIỆU TỪ VÍ ---
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy chuỗi JSON đã lưu lúc đăng nhập (Key là 'user_data')
    final userString = prefs.getString('user_data');

    if (userString != null) {
      // Giải mã JSON thành dạng Map (giống Dictionary trong Python)
      final userData = jsonDecode(userString);

      // Cập nhật lên màn hình (phải dùng setState để App vẽ lại giao diện)
      setState(() {
        fullName = userData['full_name'] ?? "Chưa cập nhật";
        phone = userData['phone'] ?? "";
        address = userData['address'] ?? "Chưa có địa chỉ";
      });
    }
  }

  // --- HÀM 2: ĐĂNG XUẤT (XÓA VÍ) ---
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Xóa sạch dữ liệu trong ví
    await prefs.remove('user_data');

    if (!mounted) return;

    // 2. Đá người dùng về màn hình Đăng nhập
    // (pushReplacement nghĩa là thay thế hoàn toàn, không cho bấm nút Back để quay lại)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài khoản của tôi"),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- PHẦN 1: AVATAR VÀ TÊN ---
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE0F2F1),
                child: Icon(Icons.person, size: 60, color: Color(0xFF009688)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              fullName, // Biến tên lấy từ ví
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              phone, // Biến sđt lấy từ ví
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // --- PHẦN 2: THÔNG TIN CHI TIẾT (Card) ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.location_on, "Địa chỉ", address),
                    const Divider(),
                    _buildInfoRow(
                      Icons.shopping_bag,
                      "Đơn hàng",
                      "Xem lịch sử mua hàng",
                    ),
                    const Divider(),
                    _buildInfoRow(Icons.help, "Hỗ trợ", "Liên hệ dược sĩ"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- PHẦN 3: NÚT ĐĂNG XUẤT ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout, // Gọi hàm đăng xuất
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50], // Màu nền đỏ nhạt
                  foregroundColor: Colors.red, // Màu chữ đỏ
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Đăng xuất"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget phụ để vẽ mấy dòng thông tin cho đỡ lặp code
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
