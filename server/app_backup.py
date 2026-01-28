from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from datetime import datetime

app = Flask(__name__)
CORS(app) # Cho phép App Mobile gọi vào

# --- CẤU HÌNH KẾT NỐI DB ---
# Thay 'root', 'password' bằng user/pass MySQL của bạn
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+mysqlconnector://root:123456@db/pharmacy_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# --- MODELS (Ánh xạ bảng trong DB thành Class Python) ---
class Product(db.Model):
    __tablename__ = 'products'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    price = db.Column(db.Numeric(10, 2), nullable=False)
    image_url = db.Column(db.Text)
    # category_id = db.Column(db.Integer)

class Order(db.Model):
    __tablename__ = 'orders'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer)
    total_amount = db.Column(db.Numeric(10, 2))
    status = db.Column(db.String(50), default='pending')
    shipping_address = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class OrderDetail(db.Model):
    __tablename__ = 'order_details'
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'))
    product_id = db.Column(db.Integer)
    quantity = db.Column(db.Integer)
    price_at_purchase = db.Column(db.Numeric(10, 2))

# --- API ENDPOINTS (Cái mà Mobile App sẽ gọi) ---

# 1. API Lấy danh sách thuốc
@app.route('/api/products', methods=['GET'])
def get_products():
    products = Product.query.all()
    output = []
    for product in products:
        product_data = {
            'id': product.id,
            'name': product.name,
            'price': float(product.price), # Convert Decimal to Float for JSON
            'image': product.image_url
        }
        output.append(product_data)
    return jsonify({'products': output})

# 2. API Tạo đơn hàng (Mobile gửi cục JSON danh sách mua lên đây)
@app.route('/api/create_order', methods=['POST'])
def create_order():
    data = request.json
    
    # Tạo đơn hàng mới
    new_order = Order(
        user_id=data['user_id'],
        total_amount=data['total_amount'],
        shipping_address=data['address']
    )
    db.session.add(new_order)
    db.session.flush() # Để lấy được new_order.id ngay lập tức

    # Lưu chi tiết từng món hàng
    for item in data['cart_items']:
        detail = OrderDetail(
            order_id=new_order.id,
            product_id=item['product_id'],
            quantity=item['quantity'],
            price_at_purchase=item['price']
        )
        db.session.add(detail)
    
    db.session.commit()
    return jsonify({'message': 'Order created successfully', 'order_id': new_order.id}), 201

# --- CHẠY SERVER ---
if __name__ == '__main__':
    # Port 5000 là port nội bộ trong container
    app.run(debug=True, host='0.0.0.0', port=5000)