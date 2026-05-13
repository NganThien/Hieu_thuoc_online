import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static final List<Map<String, dynamic>> _orders = [];
  static String? _currentUserPhone;

  static Future<void> init(String userPhone) async {
    _currentUserPhone = userPhone;
    await loadOrders();
  }

  static Future<void> loadOrders() async {
    if (_currentUserPhone == null) return;

    final prefs = await SharedPreferences.getInstance();
    final ordersKey = 'orders_$_currentUserPhone';
    final ordersString = prefs.getString(ordersKey);

    if (ordersString != null) {
      final ordersData = jsonDecode(ordersString) as List;
      _orders.clear();
      _orders.addAll(ordersData.cast<Map<String, dynamic>>());
    }
  }

  static Future<void> saveOrders() async {
    if (_currentUserPhone == null) return;

    final prefs = await SharedPreferences.getInstance();
    final ordersKey = 'orders_$_currentUserPhone';
    await prefs.setString(ordersKey, jsonEncode(_orders));
  }

  static void addOrder(Map<String, dynamic> order) {
    _orders.insert(0, order);
    saveOrders();
  }

  static List<Map<String, dynamic>> getAllOrders() {
    return List<Map<String, dynamic>>.from(_orders);
  }

  static void clearData() {
    _orders.clear();
    _currentUserPhone = null;
  }
}
