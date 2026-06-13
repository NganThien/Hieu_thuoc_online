import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/cart.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1; // Mặc định mua 1 cái

  // Hàm định dạng tiền (VND)
  String formatCurrency(int price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
  }

  Future<void> _addCurrentProductToCart() async {
    try {
      await Cart.addToCart(widget.product, _quantity);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm vào giỏ hàng!'), 
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _buyNow() {
    final checkoutItems = [
      CartItem(product: widget.product, quantity: _quantity),
    ];
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    Navigator.pop(context);
    rootNavigator.push(
      MaterialPageRoute(builder: (_) => CheckoutScreen(items: checkoutItems)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ẢNH SẢN PHẨM LỚN
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Hero(
                tag: 'product_img_${widget.product.id}',
                child: Image.asset(
                  widget.product.imageUrl.isNotEmpty
                      ? widget.product.imageUrl
                      : "assets/images/placeholder.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // THÔNG TIN CHI TIẾT
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // 🟢 ĐÃ SỬA: Ghép Giá tiền và Đơn vị nằm ngang nhau
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(widget.product.price),
                        style: const TextStyle(
                          fontSize: 24, // Tăng size cho giống Long Châu
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF009688),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3), // Căn chữ /Vỉ cho ngang đáy với số tiền
                        child: Text(
                          '/ ${widget.product.unit}', // Lấy tự động từ Model
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  const Text(
                    "Mô tả sản phẩm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.product.description.isNotEmpty
                            ? widget.product.description
                            : "Chưa có mô tả chi tiết cho sản phẩm này.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // -----------------------------------------
                  // KHU VỰC CHỌN SỐ LƯỢNG VÀ TẠM TÍNH
                  // -----------------------------------------
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Số lượng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          _buildQuantityButton(Icons.remove, () {
                            if (_quantity > 1) setState(() => _quantity--);
                          }),
                          const SizedBox(width: 15),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 15),
                          _buildQuantityButton(Icons.add, () {
                            if (_quantity < 10) {
                              setState(() => _quantity++);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chỉ được chọn tối đa 10 sản phẩm!'),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          }),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // Phần Tạm tính (Giữ nguyên không thay đổi)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tạm tính',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        formatCurrency(widget.product.price * _quantity),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.teal),
                            foregroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            _addCurrentProductToCart(); 
                          },
                          child: const Text('Thêm vào giỏ', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            _buyNow();
                          },
                          child: const Text('Mua ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!), 
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}