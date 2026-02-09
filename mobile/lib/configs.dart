import 'package:flutter/foundation.dart'; // Thư viện để check kIsWeb

class Configs {
  // Tự động chọn địa chỉ IP:
  // - Nếu là Web: Dùng 'localhost'
  // - Nếu là Android: Dùng '10.0.2.2'
  static String baseUrl = kIsWeb
      ? "http://127.0.0.1:5000/api"
      : "http://10.0.2.2:5000/api";
}
