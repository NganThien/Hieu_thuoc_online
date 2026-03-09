import 'package:flutter/foundation.dart'; // Thư viện để check kIsWeb

class Configs {
  // ĐỊA CHỈ SERVER:
  // - Web: chạy trên cùng máy với server => dùng localhost
  // - Mobile (Android/iOS thật): phải dùng IP LAN của máy chạy server (VD: 192.168.1.100)
  //
  // TODO: ĐỔI '192.168.1.100' THÀNH ĐỊA CHỈ IP THỰC TẾ CỦA MÁY CHẠY FLASK TRONG MẠNG LAN.
  static const String _lanIp = "192.168.1.249";

  static String baseUrl = kIsWeb
      ? "http://127.0.0.1:5000/api"
      : "http://$_lanIp:5000/api";

  /// Địa chỉ trang Quản trị (Admin) - dùng với url_launcher
  static String get adminUrl =>
      kIsWeb ? "http://127.0.0.1:5000/admin" : "http://$_lanIp:5000/admin";

  /// Gốc URL server (để nối với đường dẫn ảnh tương đối, ví dụ /uploads/...)
  static String get staticBaseUrl =>
      kIsWeb ? "http://127.0.0.1:5000" : "http://$_lanIp:5000";
}
