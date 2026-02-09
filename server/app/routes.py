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

@main.route('/api/products/<int:id>', methods=['GET'])
def get_product_detail(id):
    # Tìm thuốc theo ID
    product = Product.query.get(id)
    
    if product:
        return jsonify(product.to_dict())
    else:
        return jsonify({'message': 'Không tìm thấy thuốc'}), 404
    