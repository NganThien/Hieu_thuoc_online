from . import db
from datetime import datetime

# 1. Bảng DANH MỤC
class Category(db.Model):
    __tablename__ = 'categories'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    # Quan hệ: Một danh mục có nhiều thuốc
    products = db.relationship('Product', backref='category', lazy=True)

# 2. Bảng THUỐC (Cập nhật thêm category_id)
class Product(db.Model):
    __tablename__ = 'products'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    price = db.Column(db.Numeric(10, 2), nullable=False)
    description = db.Column(db.Text, nullable=True)
    image_url = db.Column(db.Text, nullable=True)
    # Liên kết với Category
    category_id = db.Column(db.Integer, db.ForeignKey('categories.id'), nullable=True)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'price': float(self.price),
            'description': self.description,
            'image_url': self.image_url,
            'category_name': self.category.name if self.category else "Chưa phân loại"
        }

# 3. Bảng USER (Người dùng)
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(20), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    full_name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.Enum('admin', 'user', 'shipper'), default='user')
    address = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# 4. Bảng ĐƠN HÀNG
class Order(db.Model):
    __tablename__ = 'orders'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    total_amount = db.Column(db.Numeric(10, 2), default=0)
    status = db.Column(db.Enum('pending', 'shipping', 'completed', 'cancelled'), default='pending')
    shipping_address = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    # Quan hệ: Một đơn hàng có nhiều chi tiết
    details = db.relationship('OrderDetail', backref='order', lazy=True)

# 5. Bảng CHI TIẾT ĐƠN HÀNG
class OrderDetail(db.Model):
    __tablename__ = 'order_details'
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    quantity = db.Column(db.Integer, default=1)
    price_at_purchase = db.Column(db.Numeric(10, 2), nullable=False)