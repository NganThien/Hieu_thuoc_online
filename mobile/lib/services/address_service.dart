import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddressService {
  static final List<Map<String, dynamic>> _addressList = [];
  static String? _currentUserPhone;
  static int selectedIndex = 0;

  static Future<void> init(String userPhone) async {
    _currentUserPhone = userPhone;
    await loadAddresses();
  }

  static Future<void> loadAddresses() async {
    if (_currentUserPhone == null) return;

    final prefs = await SharedPreferences.getInstance();
    final addressesKey = 'addresses_$_currentUserPhone';
    final addressesString = prefs.getString(addressesKey);

    _addressList.clear(); 

    if (addressesString != null) {
      try {
        final addressesData = jsonDecode(addressesString) as List;
        _addressList.addAll(
          addressesData.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      } catch (e) {
        print('Lỗi nạp địa chỉ: $e');
      }
    }

    // 🟢 THÊM LOGIC ĐỒNG BỘ BACKEND: 
    // Nếu danh sách điện thoại trống, thử lấy địa chỉ từ Database của Server trả về lúc Đăng nhập
    if (_addressList.isEmpty) {
      final userString = prefs.getString('user_data');
      if (userString != null) {
        final userData = jsonDecode(userString);
        final dbAddress = userData['address'];
        
        // Nếu Backend có lưu địa chỉ -> Tạo ngay 1 địa chỉ mặc định trên App
        if (dbAddress != null && dbAddress.toString().trim().isNotEmpty) {
          _addressList.add({
            'name': userData['full_name'] ?? 'Khách hàng',
            'phone': userData['phone'] ?? _currentUserPhone,
            'address': dbAddress,
            'isDefault': true,
          });
          await saveAddresses(); // Lưu lại vào máy luôn
        }
      }
    }
  }

  static Future<void> saveAddresses() async {
    if (_currentUserPhone == null) return;

    final prefs = await SharedPreferences.getInstance();
    final addressesKey = 'addresses_$_currentUserPhone';
    await prefs.setString(addressesKey, jsonEncode(_addressList));
  }

  static List<Map<String, dynamic>> getAddresses() {
    return _addressList;
  }

  static void addAddress(Map<String, dynamic> data) {
    if (data['isDefault'] as bool? ?? false) {
      for (final address in _addressList) {
        address['isDefault'] = false;
      }
    }

    if (_addressList.isEmpty) {
      data['isDefault'] = true;
    }

    _addressList.add(data);
    selectedIndex = _addressList.length - 1;
    saveAddresses(); 
  }

  static void updateAddress(int index, Map<String, dynamic> data) {
    if (index < 0 || index >= _addressList.length) return;

    if (data['isDefault'] as bool? ?? false) {
      for (final address in _addressList) {
        address['isDefault'] = false;
      }
    }
    _addressList[index] = data;
    selectedIndex = index;
    saveAddresses();
  }

  static Map<String, dynamic>? getDefaultAddress() {
    if (_addressList.isEmpty) return null;
    for (final address in _addressList) {
      if (address['isDefault'] as bool? ?? false) {
        return address;
      }
    }
    return _addressList.first;
  }

  static void deleteAddress(int index) {
    if (index < 0 || index >= _addressList.length) return;

    _addressList.removeAt(index);
    if (_addressList.isEmpty) {
      selectedIndex = 0;
    } else if (selectedIndex >= _addressList.length) {
      selectedIndex = _addressList.length - 1;
    }
    saveAddresses();
  }

  static void clearData() {
    _addressList.clear();
    _currentUserPhone = null;
    selectedIndex = 0;
  }
}