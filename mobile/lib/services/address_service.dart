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

    if (addressesString != null) {
      final addressesData = jsonDecode(addressesString) as List;
      _addressList.clear();
      _addressList.addAll(addressesData.cast<Map<String, dynamic>>());
    } else {
      // Load default addresses for new users
      _addressList.addAll([
        {
          'fullName': 'Nguyen Van A',
          'phone': _currentUserPhone ?? '0901234567',
          'province': 'TP. Hồ Chí Minh',
          'district': 'Quận 1',
          'ward': 'Phường Bến Nghé',
          'street': '123 Đường ABC',
          'label': 'Nhà riêng',
          'isDefault': true,
        },
        {
          'fullName': 'Tran Thi B',
          'phone': _currentUserPhone ?? '0912345678',
          'province': 'Đà Nẵng',
          'district': 'Quận Hải Châu',
          'ward': 'Phường Hải Châu I',
          'street': 'Tòa nhà XYZ, 12 Nguyễn Huệ',
          'label': 'Công ty',
          'isDefault': false,
        },
      ]);
      await saveAddresses();
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
      return;
    }
    if (selectedIndex >= _addressList.length) {
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
