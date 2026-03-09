from app import create_app, db
from app.models import Category, Product, User, Order, OrderDetail
from werkzeug.security import generate_password_hash

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

        # 4. Tạo 64 Sản phẩm (Products) - 8 sản phẩm mỗi danh mục
        print("Đang tạo sản phẩm...")
        products_data = [
            # 0: Tủ thuốc gia đình
            {"name": "Thuốc giảm đau Panadol Extra", "price": 18000, "desc": "Giảm đau, hạ sốt nhanh chóng.", "cat_id": categories[0].id},
            {"name": "Thuốc ho bổ phế Bảo Thanh", "price": 45000, "desc": "Trị ho khan, ho có đờm, viêm họng.", "cat_id": categories[0].id},
            {"name": "Thuốc nhỏ mắt Osla", "price": 22000, "desc": "Làm dịu mắt, trị mỏi mắt, khô mắt.", "cat_id": categories[0].id},
            {"name": "Thuốc chống dị ứng Telfast", "price": 60000, "desc": "Trị viêm mũi dị ứng, nổi mề đay.", "cat_id": categories[0].id},
            {"name": "Viên ngậm viêm họng Strepsils", "price": 35000, "desc": "Kháng khuẩn, làm dịu cổ họng.", "cat_id": categories[0].id},
            {"name": "Thuốc sát trùng Povidine 10%", "price": 15000, "desc": "Sát trùng vết thương ngoài da.", "cat_id": categories[0].id},
            {"name": "Miếng dán hạ sốt Bye Bye Fever", "price": 25000, "desc": "Hạ nhiệt nhanh, kéo dài 10 tiếng.", "cat_id": categories[0].id},
            {"name": "Kem bôi trị muỗi đốt Remos", "price": 38000, "desc": "Giảm ngứa, chống sưng viêm do côn trùng.", "cat_id": categories[0].id},

            # 1: Bồi bổ & Đề kháng
            {"name": "Viên sủi Vitamin C Berocca", "price": 85000, "desc": "Bổ sung Vitamin C, B, Canxi, Magie.", "cat_id": categories[1].id},
            {"name": "Dầu cá Omega-3 Nature's Way", "price": 450000, "desc": "Tốt cho não bộ, mắt và tim mạch.", "cat_id": categories[1].id},
            {"name": "Viên sắt Ferrovit", "price": 65000, "desc": "Bổ sung sắt và acid folic cho người thiếu máu.", "cat_id": categories[1].id},
            {"name": "Vitamin tổng hợp Centrum", "price": 320000, "desc": "Cung cấp đầy đủ vitamin và khoáng chất.", "cat_id": categories[1].id},
            {"name": "Nhân sâm tươi Hàn Quốc", "price": 850000, "desc": "Tăng cường sinh lực, phục hồi sức khỏe.", "cat_id": categories[1].id},
            {"name": "Viên uống Kẽm DHC Nhật Bản", "price": 120000, "desc": "Tăng cường hệ miễn dịch, giảm mụn.", "cat_id": categories[1].id},
            {"name": "Đông Trùng Hạ Thảo sấy thăng hoa", "price": 650000, "desc": "Hỗ trợ hô hấp, tăng cường thể trạng.", "cat_id": categories[1].id},
            {"name": "Sữa non Alpha Lipid Life", "price": 1250000, "desc": "Bổ sung kháng thể IgG, canxi và lợi khuẩn.", "cat_id": categories[1].id},

            # 2: Dạ dày & Tiêu hóa
            {"name": "Men vi sinh Enterogermina", "price": 160000, "desc": "Cân bằng hệ vi sinh đường ruột. 20 ống.", "cat_id": categories[2].id},
            {"name": "Thuốc trị tiêu chảy Smecta", "price": 38000, "desc": "Hỗ trợ điều trị tiêu chảy cấp.", "cat_id": categories[2].id},
            {"name": "Thuốc dạ dày chữ Y (Yumangel)", "price": 95000, "desc": "Giảm axit dạ dày, trị ợ chua.", "cat_id": categories[2].id},
            {"name": "Thuốc trị táo bón Duphalac", "price": 110000, "desc": "Làm mềm phân, nhuận tràng an toàn.", "cat_id": categories[2].id},
            {"name": "Men tiêu hóa Neopeptine", "price": 55000, "desc": "Giảm đầy hơi, chướng bụng.", "cat_id": categories[2].id},
            {"name": "Viên uống giải độc gan Boganic", "price": 95000, "desc": "Hỗ trợ chức năng gan, thanh nhiệt.", "cat_id": categories[2].id},
            {"name": "Hỗn dịch dạ dày Gaviscon", "price": 145000, "desc": "Trị trào ngược dạ dày thực quản.", "cat_id": categories[2].id},
            {"name": "Trà thanh nhiệt Actiso Thái Bảo", "price": 45000, "desc": "Mát gan, lợi mật, dễ ngủ.", "cat_id": categories[2].id},

            # 3: Thiết Bị Y Tế
            {"name": "Khẩu trang y tế 4 lớp (Hộp 50 cái)", "price": 35000, "desc": "Kháng khuẩn, chống bụi mịn.", "cat_id": categories[3].id},
            {"name": "Máy đo huyết áp điện tử Omron", "price": 850000, "desc": "Đo bắp tay, cảnh báo nhịp tim bất thường.", "cat_id": categories[3].id},
            {"name": "Nhiệt kế hồng ngoại Microlife", "price": 650000, "desc": "Đo trán không chạm, kết quả sau 1s.", "cat_id": categories[3].id},
            {"name": "Băng cá nhân Urgo (Hộp 100 miếng)", "price": 40000, "desc": "Bảo vệ vết thương nhỏ, thoáng khí.", "cat_id": categories[3].id},
            {"name": "Nước muối sinh lý Natri Clorid 0.9%", "price": 6000, "desc": "Chai 500ml, súc miệng, rửa vết thương.", "cat_id": categories[3].id},
            {"name": "Máy đo đường huyết Accu-Chek", "price": 1250000, "desc": "Kiểm tra đường huyết tại nhà chính xác.", "cat_id": categories[3].id},
            {"name": "Cồn y tế 70 độ VN Pharm", "price": 15000, "desc": "Sát khuẩn tay, dụng cụ y tế.", "cat_id": categories[3].id},
            {"name": "Bông y tế Bạch Tuyết 100g", "price": 25000, "desc": "Bông gòn thấm hút tốt, vô trùng.", "cat_id": categories[3].id},

            # 4: Chăm sóc cá nhân
            {"name": "Sữa rửa mặt Cetaphil 500ml", "price": 320000, "desc": "Dịu nhẹ, an toàn cho da nhạy cảm.", "cat_id": categories[4].id},
            {"name": "Nước súc miệng Listerine 750ml", "price": 85000, "desc": "Diệt vi khuẩn gây hôi miệng và mảng bám.", "cat_id": categories[4].id},
            {"name": "Kem chống nắng La Roche-Posay", "price": 450000, "desc": "Kiểm soát dầu, bảo vệ da khỏi tia UV.", "cat_id": categories[4].id},
            {"name": "Dầu gội trị gàu Selsun 1%", "price": 95000, "desc": "Trị nấm da đầu, sạch gàu hiệu quả.", "cat_id": categories[4].id},
            {"name": "Sữa tắm diệt khuẩn Lifebuoy", "price": 120000, "desc": "Bảo vệ khỏi 99.9% vi khuẩn gây bệnh.", "cat_id": categories[4].id},
            {"name": "Lăn khử mùi Vichy 50ml", "price": 250000, "desc": "Khử mùi hiệu quả suốt 48h.", "cat_id": categories[4].id},
            {"name": "Kem đánh răng Sensodyne", "price": 65000, "desc": "Giảm ê buốt răng tức thì.", "cat_id": categories[4].id},
            {"name": "Bàn chải điện Oral-B Vitality", "price": 450000, "desc": "Làm sạch mảng bám x2 bàn chải thường.", "cat_id": categories[4].id},

            # 5: Mẹ & Bé
            {"name": "Sữa bột Meiji số 1 (Nhật Bản)", "price": 550000, "desc": "Sữa công thức phát triển toàn diện cho bé 0-1 tuổi.", "cat_id": categories[5].id},
            {"name": "Bỉm tã dán Merries size M", "price": 380000, "desc": "Thấm hút siêu tốc, chống hăm tã.", "cat_id": categories[5].id},
            {"name": "Sữa tắm gội toàn thân Pigeon", "price": 120000, "desc": "Thành phần tự nhiên, không làm cay mắt bé.", "cat_id": categories[5].id},
            {"name": "Kem chống hăm Sudocrem", "price": 110000, "desc": "Bảo vệ và làm dịu vùng da nhạy cảm của bé.", "cat_id": categories[5].id},
            {"name": "Vitamin D3 K2 MK7 Lineabon", "price": 295000, "desc": "Hỗ trợ hấp thu canxi, phát triển chiều cao.", "cat_id": categories[5].id},
            {"name": "Nước rửa bình sữa D-nee", "price": 85000, "desc": "Làm sạch cặn sữa, an toàn cho bé.", "cat_id": categories[5].id},
            {"name": "Phấn rôm Johnson's Baby", "price": 45000, "desc": "Hút ẩm tốt, giúp da bé luôn khô thoáng.", "cat_id": categories[5].id},
            {"name": "Nước muối sinh lý Fysoline", "price": 145000, "desc": "Vệ sinh mũi, mắt hàng ngày cho trẻ sơ sinh.", "cat_id": categories[5].id},

            # 6: Cơ - Xương - Khớp
            {"name": "Viên uống Glucosamine Kirkland", "price": 650000, "desc": "Hỗ trợ tái tạo sụn khớp, giảm đau xương khớp.", "cat_id": categories[6].id},
            {"name": "Cao dán giảm đau Salonpas", "price": 15000, "desc": "Giảm đau mỏi cơ, đau lưng, bong gân.", "cat_id": categories[6].id},
            {"name": "Dầu nóng Trường Sơn", "price": 20000, "desc": "Trị cảm mạo, nhức mỏi, côn trùng cắn.", "cat_id": categories[6].id},
            {"name": "Viên uống Jex Max sụn khớp", "price": 350000, "desc": "Bảo vệ xương khớp, giảm viêm khớp.", "cat_id": categories[6].id},
            {"name": "Chai xịt giảm đau Starbalm", "price": 180000, "desc": "Xịt lạnh giảm đau chấn thương thể thao.", "cat_id": categories[6].id},
            {"name": "Viên Canxi D3 Nature Made", "price": 420000, "desc": "Phòng chống loãng xương, chắc khỏe xương.", "cat_id": categories[6].id},
            {"name": "Gel bôi trơn khớp Voltaren", "price": 85000, "desc": "Giảm đau, kháng viêm tại chỗ.", "cat_id": categories[6].id},
            {"name": "Dầu tràm trà nguyên chất", "price": 120000, "desc": "Phòng cảm lạnh, xoa bóp nhức mỏi.", "cat_id": categories[6].id},

            # 7: Hỗ Trợ Làm Đẹp
            {"name": "Viên uống trắng da Transino", "price": 1450000, "desc": "Hỗ trợ trị nám, tàn nhang, trắng da từ bên trong.", "cat_id": categories[7].id},
            {"name": "Nước uống Collagen DHC", "price": 650000, "desc": "Giúp da căng bóng, chống lão hóa hiệu quả.", "cat_id": categories[7].id},
            {"name": "Nước tẩy trang Bioderma 500ml", "price": 450000, "desc": "Làm sạch sâu, dịu nhẹ cho mọi loại da.", "cat_id": categories[7].id},
            {"name": "Mặt nạ giấy dưỡng ẩm Innisfree", "price": 25000, "desc": "Chiết xuất thiên nhiên, cấp ẩm tức thì.", "cat_id": categories[7].id},
            {"name": "Serum cấp nước HA L'Oreal", "price": 320000, "desc": "Cấp ẩm sâu, mờ nếp nhăn.", "cat_id": categories[7].id},
            {"name": "Son dưỡng môi Vaseline", "price": 65000, "desc": "Trị nẻ môi, làm mềm môi tức thì.", "cat_id": categories[7].id},
            {"name": "Nước hoa hồng Thayers", "price": 280000, "desc": "Cân bằng độ pH, se khít lỗ chân lông.", "cat_id": categories[7].id},
            {"name": "Tẩy tế bào chết Cure Natural", "price": 550000, "desc": "Tẩy sạch tế bào chết nhẹ nhàng, làm sáng da.", "cat_id": categories[7].id},
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
        print("🎉 Nạp dữ liệu thành công! Đã có 8 Danh mục và 64 Sản phẩm tuyệt đẹp.")

if __name__ == '__main__':
    seed_database()