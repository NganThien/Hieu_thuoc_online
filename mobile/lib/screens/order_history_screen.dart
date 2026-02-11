import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../configs.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _orders = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user_data');

      if (userString == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.';
        });
        return;
      }

      final userData = jsonDecode(userString);
      final userId = userData['id'];

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Thiếu user_id. Vui lòng đăng nhập lại.';
        });
        return;
      }

      final url = Uri.parse('${Configs.baseUrl}/orders/history');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _orders = (data['orders'] as List<dynamic>? ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi server: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi kết nối: $e';
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'shipping':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0 VND';
    // Định dạng đơn giản: thêm dấu chấm phân cách hàng nghìn
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reversedIndex = str.length - i - 1;
      buffer.write(str[i]);
      if (reversedIndex % 3 == 0 && i != str.length - 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()} VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrderHistory,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 60,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ],
      );
    }

    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          Icon(
            Icons.receipt_long_outlined,
            color: Colors.grey,
            size: 60,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Bạn chưa có đơn hàng nào.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index] as Map<String, dynamic>;
        final id = order['id'];
        final totalAmount = (order['total_amount'] as num?) ?? 0;
        final status = (order['status'] as String?) ?? 'unknown';
        final createdAt = order['created_at'] as String?;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mã đơn #$id',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tổng tiền: ${_formatCurrency(totalAmount)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ngày tạo: $createdAt',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

