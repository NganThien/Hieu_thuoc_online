import 'package:flutter/foundation.dart'; // Thư viện để check kIsWeb

class Configs {
  // Tự động chọn địa chỉ IP:
  // - Nếu là Web: Dùng 'localhost'
  // - Nếu là Android: Dùng '10.0.2.2'
  static String baseUrl = kIsWeb
      ? "http://127.0.0.1:5000/api"
      : "http://10.0.2.2:5000/api";

  /// Địa chỉ trang Quản trị (Admin) - dùng với url_launcher
  static String get adminUrl =>
      kIsWeb ? "http://127.0.0.1:5000/admin" : "http://10.0.2.2:5000/admin";

  /// Gốc URL server (để nối với đường dẫn ảnh tương đối, ví dụ /uploads/...)
  static String get staticBaseUrl =>
      kIsWeb ? "http://127.0.0.1:5000" : "http://10.0.2.2:5000";
}
