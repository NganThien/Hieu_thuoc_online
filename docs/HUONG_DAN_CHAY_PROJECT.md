# Hướng dẫn chạy project Hieu_thuoc_online

## Yêu cầu

- **Python 3** (khuyến nghị 3.10+)
- **MySQL** (đã tạo sẵn database)
- **Flutter SDK** (để chạy app mobile)
- **Node/npm** không bắt buộc (backend dùng Flask, không dùng Node)

---

## 1. Cấu hình Database (MySQL)

Tạo database và user (chạy trong MySQL):

```sql
CREATE DATABASE pharmacy_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- Nếu cần user riêng:
-- CREATE USER 'pharmacy'@'localhost' IDENTIFIED BY '123456';
-- GRANT ALL ON pharmacy_db.* TO 'pharmacy'@'localhost';
-- FLUSH PRIVILEGES;
```

Mặc định backend dùng: user `root`, password `123456`, host `localhost`, database `pharmacy_db`.  
Nếu khác, set biến môi trường (xem mục 2).

---

## 2. Backend (Server – Flask)

### 2.1. Vào thư mục server

```powershell
cd d:\Prj_IoT\Hieu_thuoc_online\server
```

### 2.2. Tạo môi trường ảo (khuyến nghị)

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

*(Nếu bị lỗi execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`)*

### 2.3. Cài đặt thư viện

```powershell
pip install -r requirements.txt
```

### 2.4. Biến môi trường (tùy chọn)

Chỉ cần set nếu MySQL không dùng mặc định:

```powershell
$env:MYSQL_USER = "root"
$env:MYSQL_ROOT_PASSWORD = "123456"
$env:MYSQL_HOST = "localhost"
$env:MYSQL_DATABASE = "pharmacy_db"
```

### 2.5. Chạy migration (tạo/cập nhật bảng)

```powershell
flask db upgrade
```

### 2.6. Seed dữ liệu mẫu (admin, danh mục, sản phẩm)

```powershell
python seed_data.py
```

### 2.7. Khởi động server

```powershell
python run.py
```

Server chạy tại: **http://127.0.0.1:5000**

- API: `http://127.0.0.1:5000/api/...`
- Trang Admin: **http://127.0.0.1:5000/admin**

---

## 3. Mobile App (Flutter)

### 3.1. Vào thư mục mobile

```powershell
cd d:\Prj_IoT\Hieu_thuoc_online\mobile
```

### 3.2. Cài đặt package

```powershell
flutter pub get
```

### 3.3. Chạy app

- **Android (máy ảo hoặc thiết bị):**
  ```powershell
  flutter run
  ```
  App mặc định gọi API tại `http://10.0.2.2:5000/api` (Android emulator → localhost máy).

- **Chrome (Flutter Web):**
  ```powershell
  flutter run -d chrome
  ```
  App Web dùng `http://127.0.0.1:5000/api`.

- **Chọn thiết bị cụ thể:**
  ```powershell
  flutter devices
  flutter run -d <device_id>
  ```

Đổi địa chỉ API trong **`mobile/lib/configs.dart`** nếu server chạy ở IP/port khác.

---

## 4. Tóm tắt lệnh thường dùng

| Việc cần làm           | Lệnh (chạy trong thư mục tương ứng)   |
|------------------------|----------------------------------------|
| Cài dependency backend | `pip install -r requirements.txt`     |
| Cập nhật DB            | `flask db upgrade`                     |
| Tạo dữ liệu mẫu        | `python seed_data.py`                  |
| Chạy backend           | `python run.py`                        |
| Cài dependency Flutter | `flutter pub get`                      |
| Chạy app Android       | `flutter run`                          |
| Chạy app Web           | `flutter run -d chrome`                |

---

## 5. Thứ tự chạy project lần đầu

1. Bật **MySQL**, tạo database `pharmacy_db`.
2. Trong **server**: `pip install -r requirements.txt` → `flask db upgrade` → `python seed_data.py` → `python run.py`.
3. Trong **mobile**: `flutter pub get` → `flutter run` (hoặc `flutter run -d chrome`).

Sau đó mở app, đăng nhập (ví dụ số ĐT `0900000000`, mật khẩu `123456` nếu đã seed).
