import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../configs.dart';
import 'login_screen.dart'; // Để khi đăng xuất thì quay về đây
import 'order_history_screen.dart';

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
  bool isAdmin = false;

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
        isAdmin = userData['is_admin'] == true;
      });
    }
  }

  /// Mở trang Quản trị trong trình duyệt
  Future<void> _openAdminPage() async {
    final uri = Uri.parse(Configs.adminUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở trang Quản trị')),
      );
    }
  }

  void _openOrderHistory({String? initialStatus}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(initialStatus: initialStatus),
      ),
    );
  }

  // --- HÀM 2: ĐĂNG XUẤT (XÓA VÍ) ---
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Xóa sạch dữ liệu trong ví (gồm cả is_admin trong user_data)
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
            // --- CARD TRUY CẬP QUẢN TRỊ (chỉ hiển thị khi is_admin) ---
            if (isAdmin) ...[
              Card(
                elevation: 3,
                color: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: _openAdminPage,
                  borderRadius: BorderRadius.circular(15),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 40,
                          color: Colors.white,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Truy cập trang Quản Trị",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Icon(Icons.open_in_browser, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
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
            const SizedBox(height: 24),

            // --- PHẦN THỐNG KÊ ĐƠN HÀNG (Đơn của tôi) ---
            _buildOrderStatusSection(),

            const SizedBox(height: 24),

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

  /// Widget thống kê trạng thái đơn hàng: tiêu đề "Đơn của tôi", nút "Xem tất cả", hàng 4 trạng thái.
  Widget _buildOrderStatusSection() {
    const blueIcon = Color(0xFF2196F3);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng tiêu đề + "Xem tất cả"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Đơn của tôi",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _openOrderHistory(),
                  child: const Text(
                    "Xem tất cả",
                    style: TextStyle(
                      color: Color(0xFF009688),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Hàng 4 trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusItem(
                  icon: Icons.assignment_outlined,
                  label: "Đang xử lý",
                  color: blueIcon,
                  onTap: () => _openOrderHistory(initialStatus: 'pending'),
                ),
                _buildStatusItem(
                  icon: Icons.local_shipping_outlined,
                  label: "Đang giao",
                  color: blueIcon,
                  onTap: () => _openOrderHistory(initialStatus: 'shipping'),
                ),
                _buildStatusItem(
                  icon: Icons.check_circle_outlined,
                  label: "Đã giao",
                  color: blueIcon,
                  onTap: () => _openOrderHistory(initialStatus: 'completed'),
                ),
                _buildStatusItem(
                  icon: Icons.restore_page_outlined,
                  label: "Đổi/Trả",
                  color: blueIcon,
                  onTap: () => _openOrderHistory(initialStatus: 'cancelled'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget phụ để vẽ mấy dòng thông tin cho đỡ lặp code
  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    final row = Row(
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
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: row,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: row,
    );
  }
}
