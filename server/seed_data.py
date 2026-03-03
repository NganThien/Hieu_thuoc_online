# -*- coding: utf-8 -*-
"""
Script seed dữ liệu mẫu: 1 user Admin + danh mục + sản phẩm mẫu.
Chạy từ thư mục server: python seed_data.py
"""
import sys
import os
import random

# Đảm bảo có thể import app khi chạy từ thư mục server
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models import User, Product, Category
from werkzeug.security import generate_password_hash


def seed():
    app = create_app()
    with app.app_context():
        # Tạo đầy đủ các bảng (users, products, categories, orders, ...) nếu chưa có
        db.create_all()

        # --- 1. User Admin (nếu chưa có) ---
        admin_phone = '0900000000'
        admin = User.query.filter_by(phone=admin_phone).first()
        if not admin:
            admin = User(
                phone=admin_phone,
                password=generate_password_hash('123456', method='pbkdf2:sha256'),
                full_name='Quản trị viên',
                role='admin',
                address=''
            )
            db.session.add(admin)
            db.session.commit()
            print('Created Admin user: phone=%s, password=123456' % admin_phone)
        else:
            print('Admin user already exists: %s' % admin_phone)

        # --- 2. Danh mục mẫu (4-5 danh mục theo yêu cầu) ---
        categories_data = [
            ('Thuốc tây',),
            ('Thực phẩm chức năng',),
            ('Dụng cụ y tế',),
            ('Mẹ & Bé',),
            ('Thuốc bổ & Vitamin',),
        ]
        for (name,) in categories_data:
            cat = Category.query.filter_by(name=name).first()
            if not cat:
                db.session.add(Category(name=name))
        db.session.commit()
        category_objs = Category.query.all()
        print('Categories ready: %d' % len(category_objs))

        # --- 3. Sản phẩm mẫu (nếu chưa có sản phẩm nào) ---
        if Product.query.count() == 0:
            products_data = [
                ('Paracetamol 500mg', 25000, 'Thuốc hạ sốt, giảm đau thông thường.', None),
                ('Tylenol Cold', 45000, 'Thuốc cảm, hạ sốt, giảm đau.', None),
                ('Berberis 30ml', 85000, 'Thuốc hỗ trợ tiêu hóa, giảm đau bụng.', None),
                ('Vitamin C 1000mg', 120000, 'Tăng sức đề kháng.', None),
                ('Efferalgan 500mg', 35000, 'Hạ sốt, giảm đau.', None),
                ('Nhiệt kế điện tử', 85000, 'Dụng cụ đo nhiệt độ cơ thể.', None),
                ('Siro ho Prospan', 95000, 'Thuốc ho cho trẻ em.', None),
            ]
            for name, price, desc, img in products_data:
                cat = random.choice(category_objs) if category_objs else None
                p = Product(
                    name=name,
                    price=price,
                    description=desc,
                    image_url=img,
                    category_id=cat.id if cat else None
                )
                db.session.add(p)
            db.session.commit()
            print('Created %d sample products (random categories).' % len(products_data))
        else:
            # Gán random danh mục cho các sản phẩm đã có
            all_products = Product.query.all()
            if category_objs:
                for p in all_products:
                    p.category_id = random.choice(category_objs).id
                db.session.commit()
                print('Assigned random categories to %d existing products.' % len(all_products))
            else:
                print('Products already in DB, skipped sample products.')

    print('Seed done.')


if __name__ == '__main__':
    seed()
