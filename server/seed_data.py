# -*- coding: utf-8 -*-
"""
Script seed dữ liệu mẫu: 1 user Admin + danh mục + sản phẩm mẫu.
Chạy từ thư mục server: python seed_data.py
"""
import sys
import os

# Đảm bảo có thể import app khi chạy từ thư mục server
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models import User, Product, Category
from werkzeug.security import generate_password_hash


def seed():
    app = create_app()
    with app.app_context():
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
            print('Đã tạo user Admin: phone=%s, password=123456' % admin_phone)
        else:
            print('User Admin đã tồn tại: %s' % admin_phone)

        # --- 2. Danh mục mẫu ---
        categories_data = [
            ('Thuốc cảm',),
            ('Thuốc tiêu hóa',),
            ('Thuốc giảm đau',),
            ('Vitamin & Thực phẩm chức năng',),
        ]
        for (name,) in categories_data:
            cat = Category.query.filter_by(name=name).first()
            if not cat:
                db.session.add(Category(name=name))
        db.session.commit()
        print('Đã kiểm tra/tạo danh mục.')

        # --- 3. Sản phẩm mẫu (nếu chưa có sản phẩm nào) ---
        if Product.query.count() == 0:
            cat_cam = Category.query.filter_by(name='Thuốc cảm').first()
            cat_tieu_hoa = Category.query.filter_by(name='Thuốc tiêu hóa').first()
            cat_dau = Category.query.filter_by(name='Thuốc giảm đau').first()
            cat_vitamin = Category.query.filter_by(name='Vitamin & Thực phẩm chức năng').first()

            products_data = [
                ('Paracetamol 500mg', 25000, 'Thuốc hạ sốt, giảm đau thông thường.', None, cat_dau),
                ('Tylenol Cold', 45000, 'Thuốc cảm, hạ sốt, giảm đau.', None, cat_cam),
                ('Berberis 30ml', 85000, 'Thuốc hỗ trợ tiêu hóa, giảm đau bụng.', None, cat_tieu_hoa),
                ('Vitamin C 1000mg', 120000, 'Tăng sức đề kháng.', None, cat_vitamin),
                ('Efferalgan 500mg', 35000, 'Hạ sốt, giảm đau.', None, cat_dau),
            ]
            for name, price, desc, img, cat in products_data:
                p = Product(
                    name=name,
                    price=price,
                    description=desc,
                    image_url=img,
                    category_id=cat.id if cat else None
                )
                db.session.add(p)
            db.session.commit()
            print('Đã tạo %d sản phẩm mẫu.' % len(products_data))
        else:
            print('Đã có sản phẩm trong DB, bỏ qua tạo sản phẩm mẫu.')

    print('Seed hoàn tất.')


if __name__ == '__main__':
    seed()
