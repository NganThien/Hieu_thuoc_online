from flask import Blueprint, jsonify, request
from .models import Product
from . import db

# Tạo một "nhóm" đường dẫn tên là main
main = Blueprint('main', __name__)

@main.route('/api/products', methods=['GET'])
def get_products():
    # Lấy từ khóa tìm kiếm ?q=...
    query = request.args.get('q')
    
    if query:
        # Tìm kiếm theo tên (gần đúng)
        products = Product.query.filter(Product.name.ilike(f'%{query}%')).all()
    else:
        # Lấy tất cả
        products = Product.query.all()
        
    # Trả về format chuẩn JSON {"products": [...]}
    return jsonify({
        "products": [p.to_dict() for p in products],
        "count": len(products)
    })