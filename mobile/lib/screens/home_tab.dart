import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = ApiService.fetchProducts();
  }

  String formatCurrency(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
  }

  @override
  Widget build(BuildContext context) {
    // Màu chủ đạo: Teal pha chút xanh dương (Gradient)
    final List<Color> brandGradient = [
      const Color(0xFF009688), // Teal đậm
      const Color(0xFF4DB6AC), // Teal nhạt
    ];

    return Scaffold(
      backgroundColor: const Color(
        0xFFF7F9FC,
      ), // Nền xám xanh cực nhạt (sang hơn trắng)
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER CONG + TÌM KIẾM THẢ NỔI ---
            Stack(
              clipBehavior: Clip.none, // Cho phép tìm kiếm thò ra ngoài
              children: [
                // Nền Header Cong
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: brandGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Xin chào,",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Nhà thuốc 4.0",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Thanh tìm kiếm (Thả nổi ở giữa)
                Positioned(
                  bottom: -25,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Bạn đang tìm thuốc gì...",
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.black38),
                            ),
                          ),
                        ),
                        Icon(Icons.qr_code_scanner, color: Color(0xFF009688)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40), // Cách ra cho thanh tìm kiếm thở
            // --- 2. BANNER SLIDER (Dùng PageView) ---
            SizedBox(
              height: 140,
              child: PageView(
                controller: PageController(
                  viewportFraction: 0.9,
                ), // Để lộ 1 chút 2 bên
                children: [
                  _buildBannerItem(Colors.blue[100]!, "Tư vấn F0\nMiễn phí"),
                  _buildBannerItem(Colors.orange[100]!, "Giao thuốc\n24/7"),
                  _buildBannerItem(Colors.green[100]!, "Vitamin C\nGiảm 50%"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. DANH MỤC HIỆN ĐẠI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryItem(
                    Icons.medication_outlined,
                    "Thuốc",
                    const Color(0xFFE0F2F1),
                  ),
                  _buildCategoryItem(
                    Icons.health_and_safety_outlined,
                    "Sức khỏe",
                    const Color(0xFFFFF3E0),
                  ),
                  _buildCategoryItem(
                    Icons.face_retouching_natural,
                    "Làm đẹp",
                    const Color(0xFFFCE4EC),
                  ),
                  _buildCategoryItem(
                    Icons.local_hospital_outlined,
                    "Thiết bị",
                    const Color(0xFFE3F2FD),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- 4. SẢN PHẨM BÁN CHẠY (Grid) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Sản phẩm mới",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Xem tất cả",
                      style: TextStyle(color: Color(0xFF009688)),
                    ),
                  ),
                ],
              ),
            ),

            FutureBuilder<List<Product>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Đang cập nhật kho thuốc..."),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72, // Tinh chỉnh tỷ lệ thẻ
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) =>
                      _buildModernProductCard(snapshot.data![index]),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON (Được thiết kế lại) ---

  Widget _buildBannerItem(Color color, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.medical_services,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color bgColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18), // Bo góc mềm hơn hình tròn
          ),
          child: Icon(icon, color: Colors.black87, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildModernProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ảnh sản phẩm
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Image.network(
                product.imageUrl.isNotEmpty
                    ? product.imageUrl
                    : "https://cdn-icons-png.flaticon.com/512/883/883407.png", // Icon thuốc dự phòng
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          // 2. Thông tin + Nút Add
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrency(product.price),
                      style: const TextStyle(
                        color: Color(0xFF009688),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    // Nút Add nhỏ gọn
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF009688),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
