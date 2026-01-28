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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER GIỐNG LONG CHÂU (Màu xanh + Tìm kiếm)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color(0xFF0056B3), // Màu xanh thương hiệu
              child: Column(
                children: [
                  // Hàng trên: Logo/Tên + Chuông thông báo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chào mừng bạn đến với",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Nhà thuốc 4.0",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Thanh tìm kiếm (Màu trắng bo tròn)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm tên thuốc, bệnh lý...",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. PHẦN NỘI DUNG CUỘN (Banner + Danh mục + Sản phẩm)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Banner (Giả lập)
                    Container(
                      margin: const EdgeInsets.all(12),
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://via.placeholder.com/600x200",
                          ), // Thay bằng link banner thật
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "BANNER QUẢNG CÁO",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Danh mục nhanh (Grid Icon tròn)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickIcon(
                            Icons.medication,
                            "Cần mua\nthuốc",
                            Colors.blue,
                          ),
                          _buildQuickIcon(
                            Icons.child_care,
                            "Mẹ và\nbé",
                            Colors.pink,
                          ),
                          _buildQuickIcon(
                            Icons.vaccines,
                            "Tiêm\nvắc xin",
                            Colors.purple,
                          ),
                          _buildQuickIcon(
                            Icons.receipt_long,
                            "Đơn của\ntôi",
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Tiêu đề danh sách thuốc
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Sản phẩm bán chạy",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text("Xem tất cả"),
                          ),
                        ],
                      ),
                    ),

                    // Lưới sản phẩm (Lấy từ Database Docker của bạn)
                    FutureBuilder<List<Product>>(
                      future: _futureProducts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const CircularProgressIndicator();
                        if (!snapshot.hasData || snapshot.data!.isEmpty)
                          return const Text("Chưa có thuốc nào");

                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          shrinkWrap:
                              true, // Quan trọng để nằm trong ScrollView
                          physics:
                              const NeverScrollableScrollPhysics(), // Tắt cuộn riêng của Grid
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) =>
                              _buildProductCard(snapshot.data![index]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Icon tròn danh mục
  Widget _buildQuickIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
            ],
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // Widget con: Thẻ sản phẩm
  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Icon(
                Icons.medication_liquid,
                size: 60,
                color: Colors.blue.shade200,
              ),
            ), // Thay bằng ảnh thật nếu có
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  formatCurrency(product.price),
                  style: const TextStyle(
                    color: Color(0xFF0056B3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0056B3),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: const Center(
              child: Text(
                "Chọn mua",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
