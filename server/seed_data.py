from app import create_app, db
from app.models import Category, Product, User, Order, OrderDetail
from werkzeug.security import generate_password_hash
import json
import os

app = create_app()

def seed_database():
    with app.app_context():
        # 1. Xóa dữ liệu cũ
        print("Đang xóa dữ liệu cũ...")
        OrderDetail.query.delete()
        Order.query.delete()
        Product.query.delete()
        Category.query.delete()
        db.session.commit()

        # 2. Tạo tài khoản Admin (nếu chưa có)
        admin = User.query.filter_by(phone='0900000000').first()
        if not admin:
            admin = User(
                full_name='Quản trị viên',
                phone='0900000000',
                password_hash=generate_password_hash('123456'),
                role='admin',
                address='Hà Nội'
            )
            db.session.add(admin)

        # 3. Tạo 8 Danh mục (Categories)
        print("Đang tạo danh mục...")
        categories_data = [
            {"name": "Tủ Thuốc Gia Đình", "image_url": "https://placehold.co/400x400/e2f0fc/2a5298.png?text=Tu+Thuoc"},
            {"name": "Bồi Bổ & Đề Kháng", "image_url": "https://placehold.co/400x400/e8f5e9/2e7d32.png?text=De+Khang"},
            {"name": "Dạ Dày & Tiêu Hóa", "image_url": "https://placehold.co/400x400/fff3e0/ef6c00.png?text=Tieu+Hoa"},
            {"name": "Thiết Bị Y Tế", "image_url": "https://placehold.co/400x400/fce4ec/c2185b.png?text=Thiet+Bi"},
            {"name": "Chăm Sóc Cá Nhân", "image_url": "https://placehold.co/400x400/f3e5f5/6a1b9a.png?text=Cham+Soc"},
            {"name": "Mẹ & Bé", "image_url": "https://placehold.co/400x400/ffe0b2/e65100.png?text=Me+va+Be"},
            {"name": "Cơ - Xương - Khớp", "image_url": "https://placehold.co/400x400/dcedc8/33691e.png?text=Xuong+Khop"},
            {"name": "Hỗ Trợ Làm Đẹp", "image_url": "https://placehold.co/400x400/f8bbd0/880e4f.png?text=Lam+Dep"}
        ]
        
        categories = []
        for cat_info in categories_data:
            cat = Category(name=cat_info['name'], image_url=cat_info['image_url'])
            db.session.add(cat)
            categories.append(cat)
        
        db.session.commit()

        # 4. Tạo Sản phẩm từ mock_medicines.json
        print("Đang tạo sản phẩm từ mock_medicines.json...")
        
        # Đọc dữ liệu từ file JSON
        json_file_path = os.path.join(os.path.dirname(__file__), 'mock_medicines.json')
        try:
            with open(json_file_path, 'r', encoding='utf-8') as f:
                products_json = json.load(f)
            
            # Mapping category names from JSON to category IDs
            # Use actual database IDs from the created category objects
            category_mapping = {
                "Thuốc không kê đơn": categories[0].id,  # Tủ thuốc gia đình
                "Thực phẩm chức năng": categories[1].id,  # Bồi bổ & Đề kháng
                "Thiết bị, Vật tư y tế": categories[3].id,  # Thiết Bị Y Tế
                "Bồi Bổ & Đề Kháng": categories[1].id,  # Bồi bổ & Đề kháng
                "Chăm Sóc Cá Nhân": categories[4].id,  # Chăm Sóc Cá Nhân
                "Mẹ & Bé": categories[5].id,  # Mẹ & Bé
                "Cơ - Xương - Khớp": categories[6].id,  # Cơ - Xương - Khớp
                "Dạ Dày & Tiêu Hóa": categories[2].id,  # Dạ Dày & Tiêu Hóa
                "Hỗ Trợ Làm Đẹp": categories[7].id,  # Hỗ Trợ Làm Đẹp
            }
            
            for p in products_json:
                category_name = p.get('category', 'Khác')
                category_id = category_mapping.get(category_name, categories[0].id)  # Default to first category
                
                product = Product(
                    name=p['name'],
                    price=p['price'],
                    description=p['description'],
                    image_url=p['imageUrl'],
                    category_id=category_id
                )
                db.session.add(product)
            
            db.session.commit()
            print(f"🎉 Nạp dữ liệu thành công! Đã có {len(categories)} Danh mục và {len(products_json)} Sản phẩm từ mock_medicines.json.")
            
        except FileNotFoundError:
            print("⚠️  Không tìm thấy file mock_medicines.json, sử dụng dữ liệu mặc định...")
            # Fallback to default data if JSON file not found
            products_data = [
                {"name": "Thuốc giảm đau Panadol Extra", "price": 18000, "desc": "Giảm đau, hạ sốt nhanh chóng.", "cat_id": categories[0].id},
                {"name": "Thuốc ho bổ phế Bảo Thanh", "price": 45000, "desc": "Trị ho khan, ho có đờm, viêm họng.", "cat_id": categories[0].id},
            ]
            
            for p in products_data:
                image_url = f"https://placehold.co/400x400/eeeeee/333333.png?text={p['name'].replace(' ', '+')[:15]}"
                product = Product(
                    name=p['name'],
                    price=p['price'],
                    description=p['desc'],
                    image_url=image_url,
                    category_id=p['cat_id']
                )
                db.session.add(product)
            
            db.session.commit()
            print("🎉 Nạp dữ liệu mặc định thành công!")

if __name__ == '__main__':
    seed_database()