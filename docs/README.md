# Trạm thuốc | Hệ thống Ứng dụng Bán Thuốc Online 💊

## 1. Tổng quan
Trạm thuốc là hệ thống thương mại điện tử chuyên biệt dành cho nhà thuốc được thiết kế theo mô hình Client-Server. Hệ thống cung cấp luồng mua sắm khép kín: Khách hàng đặt thuốc qua Mobile App, Chủ nhà thuốc quản lý và xét duyệt đơn hàng qua Web Admin.

## 2. Kiến trúc hệ thống

Dự án được triển khai container hóa hoàn toàn cho phần Backend và Database.

┌────────────────────┐          ┌──────────────────────┐          ┌─────────────┐
│    Mobile App      │          │     Flask Server     │          │    MySQL    │
│  (Flutter Client)  │ ◄──────► │    (RESTful API)     │ ◄──────► │ (Database)  │
└────────────────────┘  JSON    └──────────────────────┘          └─────────────┘
                                           ▲                             │
                                           │           docker            │
                                           ▼                             │
                                ┌──────────────────────┐                 │
                                │      Web Admin       │ ◄───────────────┘
                                │    (Flask-Admin)     │
                                └──────────────────────┘

## 3. Chức năng chính

**A. Mobile App (Khách hàng)**
* **Xác thực:** Đăng nhập, đăng ký, phân quyền truy cập.
* **Mua sắm:** Xem danh sách thuốc, lọc theo danh mục, tìm kiếm theo tên.
* **Giỏ hàng & Đặt đơn:** Quản lý sản phẩm trong giỏ, checkout đơn hàng.
* **Quản lý cá nhân:** Xem lịch sử đơn hàng, theo dõi trạng thái, hủy đơn (khi đang chờ xử lý).

**B. Web Admin (Quản trị viên)**
* **Quản lý Kho hàng:** Thêm/Sửa/Xóa sản phẩm, danh mục y tế.
* **Quản lý Đơn hàng:** Xem toàn bộ đơn hàng, cập nhật trạng thái (Chờ xử lý ➔ Đang giao ➔ Đã giao).
* **Quản lý Người dùng:** Giám sát tài khoản khách hàng.

## 4. Công nghệ sử dụng

| Layer | Công nghệ |
| :--- | :--- |
| **Mobile Frontend** | Flutter, Dart, Provider (State Management) |
| **Backend API & Web** | Python, Flask, Flask-SQLAlchemy, Flask-Admin |
| **Database** | MySQL 8.0 |
| **Deployment** | Docker, Docker Compose |

## 5. Hướng dẫn chạy dự án

### Backend (Server + Database)
Hệ thống sử dụng Docker để khởi chạy môi trường tự động. Tại thư mục `server`:

```bash
# 1. Khởi động các services (MySQL + Flask)
docker compose up -d --build

# 2. Nạp dữ liệu mẫu (Tạo DB, Danh mục, Sản phẩm, Tài khoản Admin)
docker compose exec web python seed_data.py

Trang Web Admin: http://localhost:5000/admin

Tài khoản Admin mặc định: 0900000000 / 123456

Mobile App
Mở máy ảo Android (Emulator) hoặc cắm thiết bị thật. Tại thư mục mobile:

Bash
flutter clean
flutter pub get
flutter run
6. Database Models (Core)
User: id, phone, password, full_name, role (user/admin), address

Category: id, name, image_url

Product: id, category_id, name, price, image_url, description

Order: id, user_id, total_amount, status (pending/shipping/completed/cancelled)

OrderDetail: id, order_id, product_id, quantity, price